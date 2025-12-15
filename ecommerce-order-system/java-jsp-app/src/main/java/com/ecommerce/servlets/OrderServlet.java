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

@WebServlet("/submitOrder")
public class OrderServlet extends HttpServlet {
    private static final String ORDER_SERVICE_URL = "http://localhost:5001/api/orders";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        if (pathInfo == null && pathInfo.equals("/create")) {
            // Get form parameters
            String customerId = request.getParameter("customer_id");
            String productId = request.getParameter("product_id");
            String quantity = request.getParameter("quantity");

            // Build JSON payload (quote IDs as strings)
            String jsonPayload = String.format(
                    "{\"customer_id\":\"%s\",\"products\":[{\"product_id\":\"%s\",\"quantity\":%s}]}",
                    customerId, productId, quantity);

            // Call Flask Order Service
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest flaskRequest = HttpRequest.newBuilder()
                    .uri(URI.create(ORDER_SERVICE_URL + "/create"))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                    .build();

            try {
                HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());

                // Forward to confirmation page
                request.setAttribute("orderResponse", flaskResponse.body());
                request.getRequestDispatcher("/confirmation.jsp").forward(request, response);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Request interrupted");
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Endpoint not found");
        }
    }

    // @Override
    // protected void doPost(HttpServletRequest request, HttpServletResponse response)
    //         throws ServletException, IOException {
        
    //     // Get form parameters
    //     String customerId = request.getParameter("customer_id");
    //     String productId = request.getParameter("product_id");
    //     String quantity = request.getParameter("quantity");

    //     // Mock successful order response
    //     String mockOrderId = String.valueOf(System.currentTimeMillis());
    //     String mockResponse = String.format(
    //         "{\"status\":\"success\",\"order_id\":\"%s\",\"message\":\"Order placed successfully\"}",
    //         mockOrderId
    //     );

    //     // Set attributes for confirmation page
    //     request.setAttribute("orderResponse", mockResponse);
    //     request.setAttribute("statusCode", 201);
    //     request.setAttribute("customerId", customerId);
    //     request.setAttribute("productId", productId);
    //     request.setAttribute("quantity", quantity);

    //     // Forward to confirmation page
    //     request.getRequestDispatcher("confirmation.jsp").forward(request, response);
    // }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    
        String pathInfo = request.getPathInfo();

        if (pathInfo != null && pathInfo.length() > 1) {
            String orderId = pathInfo.substring(1);
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