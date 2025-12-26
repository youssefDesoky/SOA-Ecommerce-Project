package com.ecommerce.servlets;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import com.ecommerce.config.AppConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/notification/*")
public class NotificationServlet extends HttpServlet {

    private static final String NOTIFICATION_SERVICE_URL = AppConfig.getNotificationServiceUrl();

    // ======================================================
    // POST /notification/send
    // ======================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /send

        if (pathInfo == null || !"/send".equals(pathInfo)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String customerId = request.getParameter("customer_id");
        String orderId = request.getParameter("order_id");
        String type = request.getParameter("type");
        String message = request.getParameter("message");

        if (customerId == null || message == null || type == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Missing required fields");
            return;
        }

        String jsonPayload = String.format(
                "{ \"customer_id\": %s, \"order_id\": %s, \"notification_type\": \"%s\", \"message\": \"%s\" }",
                customerId,
                (orderId != null ? orderId : "null"),
                escapeJson(type),
                escapeJson(message)
        );

        HttpRequest flaskReq = HttpRequest.newBuilder()
                .uri(URI.create(NOTIFICATION_SERVICE_URL + "/send"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                .build();

        try {
            HttpResponse<String> flaskRes =
                    HttpClient.newHttpClient()
                              .send(flaskReq, HttpResponse.BodyHandlers.ofString());

            response.setStatus(flaskRes.statusCode());
            response.setContentType("application/json");
            response.getWriter().write(flaskRes.body());

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            response.sendError(500, "Notification request interrupted");
        }
    }

    private String escapeJson(String value) {
        return value == null ? "" :
                value.replace("\\", "\\\\")
                     .replace("\"", "\\\"");
    }
}
