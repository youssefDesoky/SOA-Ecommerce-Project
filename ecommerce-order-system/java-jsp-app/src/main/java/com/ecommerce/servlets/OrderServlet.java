package com.ecommerce.servlets;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orders/*")
public class OrderServlet extends HttpServlet {

    private static final String ORDER_SERVICE_URL = "http://127.0.0.1:5001/api/orders";
    private static final String CUSTOMER_SERVICE_URL = "http://127.0.0.1:5004/api/customers";

    private final HttpClient client = HttpClient.newHttpClient();
    private final ObjectMapper mapper = new ObjectMapper();

    // ======================================================
    // GET
    // ======================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getPathInfo();

        if (path != null && path.startsWith("/view/")) {
            viewOrder(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ======================================================
    // VIEW ORDER DETAILS
    // ======================================================
    private void viewOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        String orderId = pathInfo.replace("/view/", "");

        HttpRequest orderRequest = HttpRequest.newBuilder()
                .uri(URI.create(ORDER_SERVICE_URL + "/" + orderId))
                .GET()
                .build();

        try {
            HttpResponse<String> orderResponse = client.send(orderRequest, HttpResponse.BodyHandlers.ofString());

            if (orderResponse.statusCode() != 200) {
                response.sendError(404, "Order not found");
                return;
            }

            request.setAttribute("orderJson", orderResponse.body());
            request.getRequestDispatcher("/WEB-INF/order-details.jsp").forward(request, response);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            response.sendError(500, "Failed to fetch order");
        }
    }

    // ======================================================
    // POST
    // ======================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getPathInfo();

        if ("/create".equals(path)) {
            previewOrder(request, response);
        } else if ("/submit".equals(path)) {
            submitOrder(request, response);
        } else if ("/cancel".equals(path)) {
            cancelOrder(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ======================================================
    // STEP 1: PREVIEW ORDER (NO DB WRITE)
    // ======================================================
    private void previewOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(true);

        // -----------------------
        // Read checkout form
        // -----------------------
        String cartData = request.getParameter("cart_data");
        String paymentMethod = request.getParameter("payment_method");

        String firstName = request.getParameter("first_name");
        String lastName  = request.getParameter("last_name");
        String email     = request.getParameter("email");
        String phone     = request.getParameter("phone");

        String shippingAddress =
                request.getParameter("address") + ", " +
                request.getParameter("city") + ", " +
                request.getParameter("government");

        // -----------------------
        // Save to session
        // -----------------------
        session.setAttribute("cartData", cartData);
        session.setAttribute("paymentMethod", paymentMethod);
        session.setAttribute("firstName", firstName);
        session.setAttribute("lastName", lastName);
        session.setAttribute("email", email);
        session.setAttribute("phone", phone);
        session.setAttribute("shippingAddress", shippingAddress);

        // -----------------------
        // Call ORDER SERVICE (PREVIEW)
        // -----------------------
        String previewPayload = String.format(
            "{\n  \"products\": %s,\n  \"shipping_address\": \"%s\",\n  \"payment_method\": \"%s\"\n}",
            cartData,
            escapeJson(shippingAddress),
            escapeJson(paymentMethod)
        );

        HttpRequest previewReq = HttpRequest.newBuilder()
                .uri(URI.create(ORDER_SERVICE_URL + "/preview"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(previewPayload))
                .build();

        try {
            HttpResponse<String> previewRes =
                    client.send(previewReq, HttpResponse.BodyHandlers.ofString());

            if (previewRes.statusCode() != 200) {
                response.sendError(500, "Failed to preview order");
                return;
            }

            JsonNode order = mapper.readTree(previewRes.body());

            // Convert items JsonNode → List
            List<Map<String, Object>> items =
                    mapper.convertValue(
                            order.get("items"),
                            new com.fasterxml.jackson.core.type.TypeReference<List<Map<String, Object>>>() {}
                    );

            // Pass data to JSP
            request.setAttribute("customerName", firstName + " " + lastName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);
            request.setAttribute("shippingAddress", shippingAddress);
            request.setAttribute("paymentMethod", paymentMethod);

            request.setAttribute("items", items);
            request.setAttribute("subtotal", String.format("%.2f", order.get("subtotal").asDouble()));
            request.setAttribute("discount", String.format("%.2f", order.get("discount").asDouble()));
            request.setAttribute("tax", String.format("%.2f", order.get("tax").asDouble()));
            request.setAttribute("total", String.format("%.2f", order.get("total_amount").asDouble()));

            request.getRequestDispatcher("/WEB-INF/confirmation.jsp")
                    .forward(request, response);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            response.sendError(500, "Order preview interrupted");
        }
    }

    // ======================================================
    // STEP 2: SUBMIT ORDER (FINAL)
    // ======================================================
    private void submitOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/inventory");
            return;
        }

        String cartData = (String) session.getAttribute("cartData");
        String paymentMethod = (String) session.getAttribute("paymentMethod");
        String firstName = (String) session.getAttribute("firstName");
        String lastName = (String) session.getAttribute("lastName");
        String email = (String) session.getAttribute("email");
        String phone = (String) session.getAttribute("phone");
        String shippingAddress = (String) session.getAttribute("shippingAddress");

        try {
            // -----------------------
            // Create or fetch customer
            // -----------------------
            String customerPayload = String.format(
                    "{\n  \"first_name\": \"%s\",\n  \"last_name\": \"%s\",\n  \"email\": \"%s\",\n  \"phone\": \"%s\"\n}",
                    escapeJson(firstName),
                    escapeJson(lastName),
                    escapeJson(email),
                    escapeJson(phone)
            );

            HttpRequest customerReq = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(customerPayload))
                    .build();

            HttpResponse<String> customerRes =
                    client.send(customerReq, HttpResponse.BodyHandlers.ofString());

            if (customerRes.statusCode() != 200 && customerRes.statusCode() != 201) {
                response.sendError(500, "Customer service error");
                return;
            }

            JsonNode customer = mapper.readTree(customerRes.body());
            String customerId = customer.get("customer_id").asText();

            // -----------------------
            // Create order
            // -----------------------
            String orderPayload = String.format(
                "{\n  \"customer_id\": %s,\n  \"products\": %s,\n  \"shipping_address\": \"%s\",\n  \"payment_method\": \"%s\"\n}",
                customerId,
                cartData,
                escapeJson(shippingAddress),
                escapeJson(paymentMethod)
            );

            HttpRequest orderReq = HttpRequest.newBuilder()
                    .uri(URI.create(ORDER_SERVICE_URL + "/create"))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(orderPayload))
                    .build();

            HttpResponse<String> orderRes =
                    client.send(orderReq, HttpResponse.BodyHandlers.ofString());

            if (orderRes.statusCode() != 200 && orderRes.statusCode() != 201) {
                response.sendError(500, "Order creation failed");
                return;
            }

            JsonNode order = mapper.readTree(orderRes.body());
            String orderId = order.get("order_id").asText();

            // -----------------------
            // Cleanup
            // -----------------------
            session.invalidate();

            request.setAttribute("orderId", orderId);
            request.getRequestDispatcher("/WEB-INF/confirmation-success.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Failed to submit order");
        }
    }

    // ======================================================
    // STEP 3: CANCEL
    // ======================================================
    private void cancelOrder(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        response.sendRedirect(request.getContextPath() + "/inventory");
    }

    // ======================================================
    // JSON ESCAPE
    // ======================================================
    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
