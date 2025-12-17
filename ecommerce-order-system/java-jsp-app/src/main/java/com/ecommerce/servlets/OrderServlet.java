package com.ecommerce.servlets;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class OrderServlet extends HttpServlet {
    private static final String ORDER_SERVICE_URL = "http://172.17.0.1:5001/api/orders";
    private static final String CUSTOMER_SERVICE_URL = "http://172.17.0.1:5004/api/customers";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if ("/create".equals(pathInfo)) {
            // Get form parameters
            String cartData = request.getParameter("cart_data");
            String paymentMethod = request.getParameter("payment_method");
            String firstName = request.getParameter("first_name");
            String lastName = request.getParameter("last_name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String government = request.getParameter("government");
            String city = request.getParameter("city");
            String address = request.getParameter("address");

            // Build shipping address
            String shippingAddress = address + ", " + city + ", " + government;
            String fullAddress = shippingAddress;

            HttpClient client = HttpClient.newHttpClient();

            try {
                // Step 1: Create or find customer via Customer Service
                String customerPayload = String.format(
                        "{\"first_name\": \"%s\", \"last_name\": \"%s\", \"email\": \"%s\", \"phone\": \"%s\", \"address\": \"%s\"}",
                        escapeJson(firstName), escapeJson(lastName), escapeJson(email), escapeJson(phone),
                        escapeJson(fullAddress));

                HttpRequest customerRequest = HttpRequest.newBuilder()
                        .uri(URI.create(CUSTOMER_SERVICE_URL))
                        .header("Content-Type", "application/json")
                        .POST(HttpRequest.BodyPublishers.ofString(customerPayload))
                        .build();

                HttpResponse<String> customerResponse = client.send(customerRequest,
                        HttpResponse.BodyHandlers.ofString());

                if (customerResponse.statusCode() != 200 && customerResponse.statusCode() != 201) {
                    request.setAttribute("error", "Failed to create customer: " + customerResponse.body());
                    request.getRequestDispatcher("/WEB-INF/checkout.jsp").forward(request, response);
                    return;
                }

                // Parse customer_id from response
                String customerResponseBody = customerResponse.body();
                String customerId = "0";
                if (customerResponseBody.contains("customer_id")) {
                    int start = customerResponseBody.indexOf("customer_id") + 14;
                    int end = customerResponseBody.indexOf(",", start);
                    if (end == -1)
                        end = customerResponseBody.indexOf("}", start);
                    customerId = customerResponseBody.substring(start, end).trim();
                }

                // Step 2: Create order via Order Service
                String orderPayload = String.format(
                        "{\"customer_id\": %s, \"products\": %s, \"shipping_address\": \"%s\", \"payment_method\": \"%s\"}",
                        customerId, cartData, escapeJson(shippingAddress), escapeJson(paymentMethod));

                HttpRequest orderRequest = HttpRequest.newBuilder()
                        .uri(URI.create(ORDER_SERVICE_URL + "/create"))
                        .header("Content-Type", "application/json")
                        .POST(HttpRequest.BodyPublishers.ofString(orderPayload))
                        .build();

                HttpResponse<String> orderResponse = client.send(orderRequest, HttpResponse.BodyHandlers.ofString());

                if (orderResponse.statusCode() == 200 || orderResponse.statusCode() == 201) {
                    // Parse order_id from response
                    String responseBody = orderResponse.body();
                    String orderId = "0";
                    if (responseBody.contains("order_id")) {
                        int start = responseBody.indexOf("order_id") + 11;
                        int end = responseBody.indexOf(",", start);
                        if (end == -1)
                            end = responseBody.indexOf("}", start);
                        orderId = responseBody.substring(start, end).trim();
                    }

                    // Store customer info in request for confirmation page
                    request.setAttribute("orderId", orderId);
                    request.setAttribute("customerName", firstName + " " + lastName);
                    request.setAttribute("email", email);
                    request.setAttribute("shippingAddress", shippingAddress);
                    request.setAttribute("paymentMethod", paymentMethod);

                    // Forward to confirmation page
                    request.getRequestDispatcher("/WEB-INF/confirmation.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Failed to create order: " + orderResponse.body());
                    request.getRequestDispatcher("/WEB-INF/checkout.jsp").forward(request, response);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                request.setAttribute("error", "Request interrupted");
                request.getRequestDispatcher("/WEB-INF/checkout.jsp").forward(request, response);
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Endpoint not found");
        }
    }

    /**
     * Escape special characters for JSON string
     */
    private String escapeJson(String input) {
        if (input == null)
            return "";
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if (pathInfo != null && pathInfo.length() > 1) {
            String orderId = pathInfo.substring(1);
            if (orderId.isBlank()) {
                response.sendError(400, "Invalid order ID");
                return;
            }

            String url = ORDER_SERVICE_URL + "/" + orderId;

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest flaskRequest = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            try {
                HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());
                response.setContentType("application/json");
                response.setStatus(flaskResponse.statusCode());
                response.getWriter().write(flaskResponse.body());
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Request interrupted");
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order ID required");
        }
    }
}