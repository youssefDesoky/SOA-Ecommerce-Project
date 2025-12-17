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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if ("/create".equals(pathInfo)) {
            // Get form parameters
            String customerId = request.getParameter("customer_id");
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

            // Build JSON payload for Flask service
            String jsonPayload = String.format(
                    "{\"customer_id\": %s, \"products\": %s, \"shipping_address\": \"%s\", \"payment_method\": \"%s\"}",
                    customerId, cartData, shippingAddress, paymentMethod);

            // Call Flask Order Service
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest flaskRequest = HttpRequest.newBuilder()
                    .uri(URI.create(ORDER_SERVICE_URL + "/create"))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                    .build();

            try {
                HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());

                if (flaskResponse.statusCode() == 200 || flaskResponse.statusCode() == 201) {
                    // Parse order_id from response (simple string parsing)
                    String responseBody = flaskResponse.body();
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
                    request.setAttribute("error", "Failed to create order: " + flaskResponse.body());
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