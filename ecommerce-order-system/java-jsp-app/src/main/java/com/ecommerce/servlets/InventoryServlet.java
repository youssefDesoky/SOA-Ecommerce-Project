package com.ecommerce.servlets;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class InventoryServlet extends HttpServlet {
    // Use Docker bridge IP to reach Flask on the host from inside Docker container
    private static final String INVENTORY_SERVICE_URL = "http://172.17.0.1:5002/api/inventory";
    private static final HttpClient client = HttpClient.newHttpClient();

    // GET /api/inventory OR /api/inventory/check/{product_id}
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /check/123 or null
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            // If path is /check/{product_id}
            if (pathInfo != null && pathInfo.startsWith("/check/")) {
                String productId = pathInfo.substring(7); // "/check/".length()
                String url = INVENTORY_SERVICE_URL + "/check/" + productId;
                String quantity = request.getParameter("quantity");

                if (quantity != null) {
                    url += "?quantity=" + quantity;
                }

                HttpRequest flaskRequest = HttpRequest.newBuilder()
                        .uri(URI.create(url))
                        .timeout(Duration.ofSeconds(10))
                        .GET()
                        .build();

                HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());
                response.setStatus(flaskResponse.statusCode());
                response.getWriter().write(flaskResponse.body());

            } else {
                // Return all inventory from Flask service
                HttpRequest flaskRequest = HttpRequest.newBuilder()
                        .uri(URI.create(INVENTORY_SERVICE_URL))
                        .timeout(Duration.ofSeconds(10))
                        .GET()
                        .build();

                HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());
                response.setStatus(flaskResponse.statusCode());
                response.getWriter().write(flaskResponse.body());
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Request interrupted\"}");
        } catch (java.net.ConnectException e) {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            response.getWriter().write("{\"error\":\"Inventory service unavailable\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    // PUT /api/inventory/update
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /update
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if ("/update".equals(pathInfo)) {
            try {
                String productId = request.getParameter("product_id");
                String quantityDelta = request.getParameter("quantity_delta"); // align with Flask

                String jsonPayload = String.format(
                        "{\"product_id\":%s,\"quantity_delta\":%s}",
                        productId, quantityDelta);

                HttpRequest flaskRequest = HttpRequest.newBuilder()
                        .uri(URI.create(INVENTORY_SERVICE_URL + "/update"))
                        .header("Content-Type", "application/json")
                        .timeout(Duration.ofSeconds(10))
                        .PUT(HttpRequest.BodyPublishers.ofString(jsonPayload))
                        .build();

                HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());
                response.setStatus(flaskResponse.statusCode());
                response.getWriter().write(flaskResponse.body());

            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"Request interrupted\"}");
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
            }
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Endpoint not found");
        }
    }
}