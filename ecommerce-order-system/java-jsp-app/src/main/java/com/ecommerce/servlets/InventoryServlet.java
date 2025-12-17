package com.ecommerce.servlets;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

import com.ecommerce.model.Product;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class InventoryServlet extends HttpServlet {
    private static final String INVENTORY_SERVICE_URL = "http://172.17.0.1:5002/api/inventory";
    private static final HttpClient client = HttpClient.newHttpClient();
    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            HttpRequest flaskRequest = HttpRequest.newBuilder()
                    .uri(URI.create(INVENTORY_SERVICE_URL))
                    .timeout(Duration.ofSeconds(10))
                    .GET()
                    .build();

            HttpResponse<String> flaskResponse = client
                    .send(flaskRequest, HttpResponse.BodyHandlers.ofString());

            // Parse JSON and convert to List of Product objects
            String jsonString = flaskResponse.body();
            List<Product> products = new ArrayList<>();

            JsonNode jsonArray = objectMapper.readTree(jsonString);

            for (JsonNode jsonNode : jsonArray) {
                Product product = new Product();

                // Map JSON fields to Product object
                if (jsonNode.has("product_id")) {
                    product.setProduct_id(jsonNode.get("product_id").asInt());
                }

                if (jsonNode.has("product_name")) {
                    product.setProduct_name(jsonNode.get("product_name").asText());
                }

                // Handle both "unit_price" and "price" fields
                if (jsonNode.has("unit_price")) {
                    product.setPrice(jsonNode.get("unit_price").asDouble());
                } else if (jsonNode.has("price")) {
                    product.setPrice(jsonNode.get("price").asDouble());
                }

                // Handle both "quantity_available" and "stock_quantity" fields
                if (jsonNode.has("quantity_available")) {
                    product.setStock_quantity(jsonNode.get("quantity_available").asInt());
                } else if (jsonNode.has("stock_quantity")) {
                    product.setStock_quantity(jsonNode.get("stock_quantity").asInt());
                }

                // Set default values for other fields
                product.setCategory(jsonNode.has("category") ? jsonNode.get("category").asText() : "Electronics");

                // Use product_image_url from database, fallback to default image
                if (jsonNode.has("product_image_url") && !jsonNode.get("product_image_url").isNull()) {
                    product.setImage(jsonNode.get("product_image_url").asText());
                } else if (jsonNode.has("image")) {
                    product.setImage(jsonNode.get("image").asText());
                } else {
                    product.setImage(
                            "https://images.unsplash.com/photo-1505740420928-5e560c06b30e?w=500&auto=format&fit=crop");
                }

                product.setDescription(jsonNode.has("description") ? jsonNode.get("description").asText()
                        : "Premium electronic product");

                products.add(product);
            }

            // Set products as request attribute
            request.setAttribute("products", products);

            // Forward to JSP
            request.getRequestDispatcher("/WEB-INF/index.jsp").forward(request, response);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new ServletException("Request interrupted", e);
        } catch (Exception e) {
            throw new ServletException("Failed to load inventory", e);
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if ("/update".equals(pathInfo)) {
            try {
                String productId = request.getParameter("product_id");
                String quantityDelta = request.getParameter("quantity_delta");

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