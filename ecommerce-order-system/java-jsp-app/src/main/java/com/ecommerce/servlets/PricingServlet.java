package com.ecommerce.servlets;

import java.io.BufferedReader;
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

@WebServlet("/pricing/*")
public class PricingServlet extends HttpServlet {

    private static final String PRICING_SERVICE_URL = "http://172.17.0.1:5003/api/pricing";

    // POST /pricing/calculate
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /calculate

        if (pathInfo != null && pathInfo.equals("/calculate")) {
            // Read JSON body from request
            StringBuilder jsonBody = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    jsonBody.append(line);
                }
            }

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest flaskRequest = HttpRequest.newBuilder()
                    .uri(URI.create(PRICING_SERVICE_URL + "/calculate"))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody.toString()))
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