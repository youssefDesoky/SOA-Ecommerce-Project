package com.ecommerce.servlets;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/orders/*" })
public class OrderServlet extends HttpServlet {

    private static final String ORDER_SERVICE_URL = "http://127.0.0.1:5001/api/orders";
    private static final String CUSTOMER_SERVICE_URL = "http://127.0.0.1:5004/api/customers";

    // =======================
    // GET HANDLER
    // =======================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /view/123

        if (pathInfo != null && pathInfo.startsWith("/view/")) {
            viewOrder(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void viewOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /view/123
        String orderId = pathInfo.replace("/view/", "");

        HttpClient client = HttpClient.newHttpClient();

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

            // Pass raw JSON to JSP (or parse if you prefer)
            request.setAttribute("orderJson", orderResponse.body());

            request.getRequestDispatcher("/WEB-INF/order-details.jsp")
                    .forward(request, response);

        } catch (IOException e) {
            response.sendError(500, "Failed to fetch order: " + e.getMessage());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            response.sendError(500, "Failed to fetch order");
        }
    }

    // =======================
    // POST HANDLER
    // =======================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if ("/create".equals(pathInfo)) {
            previewOrder(request, response);
        } else if ("/submit".equals(pathInfo)) {
            submitOrder(request, response);
        } else if ("/cancel".equals(pathInfo)) {
            cancelOrder(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =======================
    // STEP 1: PREVIEW ORDER
    // =======================
    private void previewOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // Save form data to session (NO DB WRITE)
        session.setAttribute("cartData", request.getParameter("cart_data"));
        session.setAttribute("paymentMethod", request.getParameter("payment_method"));
        session.setAttribute("firstName", request.getParameter("first_name"));
        session.setAttribute("lastName", request.getParameter("last_name"));
        session.setAttribute("email", request.getParameter("email"));
        session.setAttribute("phone", request.getParameter("phone"));
        session.setAttribute("shippingAddress",
                request.getParameter("address") + ", " +
                        request.getParameter("city") + ", " +
                        request.getParameter("government"));

        // Pass data to confirmation page
        request.setAttribute("customerName",
                request.getParameter("first_name") + " " + request.getParameter("last_name"));
        request.setAttribute("email", request.getParameter("email"));
        request.setAttribute("paymentMethod", request.getParameter("payment_method"));
        request.setAttribute("shippingAddress", session.getAttribute("shippingAddress"));

        request.getRequestDispatcher("/WEB-INF/confirmation.jsp").forward(request, response);
    }

    // =======================
    // STEP 2: SUBMIT ORDER
    // =======================
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

        HttpClient client = HttpClient.newHttpClient();

        try {
            // 1️⃣ Create or find customer
            String customerPayload = String.format(
                    "{\"first_name\":\"%s\",\"last_name\":\"%s\",\"email\":\"%s\",\"phone\":\"%s\"}",
                    escapeJson(firstName), escapeJson(lastName),
                    escapeJson(email), escapeJson(phone));

            HttpRequest customerReq = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(customerPayload))
                    .build();

            HttpResponse<String> customerRes = client.send(customerReq, HttpResponse.BodyHandlers.ofString());

            if (customerRes.statusCode() != 200 && customerRes.statusCode() != 201) {
                throw new RuntimeException("Customer creation failed");
            }

            String customerId = customerRes.body().replaceAll("\\D+", "");

            // 2️⃣ Create order
            String orderPayload = String.format(
                    "{\"customer_id\":%s,\"products\":%s,\"shipping_address\":\"%s\",\"payment_method\":\"%s\"}",
                    customerId, cartData, escapeJson(shippingAddress), escapeJson(paymentMethod));

            HttpRequest orderReq = HttpRequest.newBuilder()
                    .uri(URI.create(ORDER_SERVICE_URL + "/create"))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(orderPayload))
                    .build();

            HttpResponse<String> orderRes = client.send(orderReq, HttpResponse.BodyHandlers.ofString());

            if (orderRes.statusCode() != 200 && orderRes.statusCode() != 201) {
                throw new RuntimeException("Order creation failed");
            }

            String orderId = orderRes.body().replaceAll("\\D+", "");

            // Cleanup
            session.invalidate();

            // Show success
            request.setAttribute("orderId", orderId);
            request.getRequestDispatcher("/WEB-INF/confirmation-success.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Failed to submit order");
        }
    }

    // =======================
    // STEP 3: CANCEL ORDER
    // =======================
    private void cancelOrder(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/inventory");
    }

    // =======================
    // JSON ESCAPE
    // =======================
    private String escapeJson(String input) {
        if (input == null)
            return "";
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
