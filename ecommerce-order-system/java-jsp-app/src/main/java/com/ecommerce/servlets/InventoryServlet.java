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

public class InventoryServlet extends HttpServlet {
    private static final String INVENTORY_SERVICE_URL = "http://localhost:5002/api/inventory";

    // GET /api/inventory OR /api/inventory/check/{product_id}
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /check/123 or null

        // If path is /check/{product_id}
        if (pathInfo != null && pathInfo.startsWith("/check/")) {
            String productId = pathInfo.substring(7); // Remove "/check/"
            String quantity = request.getParameter("quantity");

            String url = INVENTORY_SERVICE_URL + "/" + productId + "/check";
            if (quantity != null) {
                url += "?quantity=" + quantity;
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
            // Return all inventory from Flask service
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest flaskRequest = HttpRequest.newBuilder()
                    .uri(URI.create(INVENTORY_SERVICE_URL))
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
        }
    }

    // PUT /api/inventory/update
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /update

        if (pathInfo != null && pathInfo.equals("/update")) {
            String productId = request.getParameter("product_id");
            String quantityChange = request.getParameter("quantity_change");

            String jsonPayload = String.format(
                    "{\"product_id\":\"%s\",\"quantity_change\":%s}",
                    productId, quantityChange);

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest flaskRequest = HttpRequest.newBuilder()
                    .uri(URI.create(INVENTORY_SERVICE_URL + "/update"))
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