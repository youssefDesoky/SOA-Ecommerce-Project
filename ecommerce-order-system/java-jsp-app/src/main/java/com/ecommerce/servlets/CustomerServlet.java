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

@WebServlet("/customers/*")
public class CustomerServlet extends HttpServlet {
    private static final String CUSTOMER_SERVICE_URL = "http://127.0.0.1:5004/api/customers";
    private static final String ORDER_SERVICE_URL = "http://127.0.0.1:5001/api/orders";

    // GET /customers or /customers/{customer_id} OR /customers/{customer_id}/orders
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /{customer_id}/orders or /{customer_id} or null

        // If no path info, forward to customer profile page
        if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("/profile")) {
            request.getRequestDispatcher("/WEB-INF/customer-profile.jsp").forward(request, response);
            return;
        }

        if (pathInfo.length() > 1) {
            String[] parts = pathInfo.substring(1).split("/"); // ["123", "orders"] or ["123"]
            String customerId = parts[0];

            String url;
            if (parts.length > 1 && "orders".equals(parts[1])) {
                // GET /api/customers/{customer_id}/orders - Call Order Service
                url = ORDER_SERVICE_URL + "?customer_id=" + customerId;
            } else {
                // GET /api/customers/{customer_id}
                url = CUSTOMER_SERVICE_URL + "/" + customerId;
            }

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
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Customer ID required");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        String jsonPayload = String.format(
                "{\"name\":\"%s\",\"email\":\"%s\",\"phone\":\"%s\",\"address\":\"%s\"}",
                name, email, phone, address);

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest flaskRequest = HttpRequest.newBuilder()
                .uri(URI.create(CUSTOMER_SERVICE_URL))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
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
    }

    // PUT /api/customers/{customer_id}/loyalty
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /{customer_id}/loyalty

        if (pathInfo != null && pathInfo.contains("/loyalty")) {
            String customerId = pathInfo.substring(1).split("/")[0]; // Extract customer_id
            String loyaltyPoints = request.getParameter("loyalty_points");

            String jsonPayload = String.format("{\"loyalty_points\":%s}", loyaltyPoints);

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest flaskRequest = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/" + customerId + "/loyalty"))
                    .header("Content-Type", "application/json")
                    .PUT(HttpRequest.BodyPublishers.ofString(jsonPayload))
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
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Endpoint not found");
        }
    }
}