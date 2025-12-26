package com.ecommerce.servlets;

import com.ecommerce.config.AppConfig;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

@WebServlet("/customers/*")
public class CustomerServlet extends HttpServlet {

    private static final String CUSTOMER_SERVICE_URL = AppConfig.getCustomerServiceUrl();
    private static final String NOTIFICATION_SERVICE_URL = AppConfig.getNotificationServiceUrl();

    private final HttpClient client = HttpClient.newHttpClient();
    private final ObjectMapper mapper = new ObjectMapper();

    // ======================================================
    // GET → show customer-profile.jsp
    // ======================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/customer-profile.jsp")
               .forward(request, response);
    }

    // ======================================================
    // POST /customers/lookup
    // ======================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo(); // /lookup

        if (pathInfo == null || !"/lookup".equals(pathInfo)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Please enter an email address");
            request.getRequestDispatcher("/WEB-INF/customer-profile.jsp")
                   .forward(request, response);
            return;
        }

        email = email.trim();
        request.setAttribute("searchedEmail", email);

        try {
            // ======================================================
            // 1) Fetch customer by email
            // ======================================================
            String encodedEmail = URLEncoder.encode(email, StandardCharsets.UTF_8);
            HttpRequest customerReq = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/email/" + encodedEmail))
                    .GET()
                    .build();

            HttpResponse<String> customerRes =
                    client.send(customerReq, HttpResponse.BodyHandlers.ofString());

            if (customerRes.statusCode() == 404) {
                request.setAttribute("errorMessage", "Customer not found");
                request.getRequestDispatcher("/WEB-INF/customer-profile.jsp")
                       .forward(request, response);
                return;
            }

            if (customerRes.statusCode() != 200) {
                request.setAttribute("errorMessage", "Failed to fetch customer data");
                request.getRequestDispatcher("/WEB-INF/customer-profile.jsp")
                       .forward(request, response);
                return;
            }

            JsonNode customerJson = mapper.readTree(customerRes.body());
            Map<String, Object> customer =
                    mapper.convertValue(customerJson,
                            new TypeReference<Map<String, Object>>() {});

            int customerId = customerJson.get("customer_id").asInt();

            // ======================================================
            // 2) Fetch orders for customer
            // ======================================================
            HttpRequest ordersReq = HttpRequest.newBuilder()
                    .uri(URI.create(
                            CUSTOMER_SERVICE_URL + "/" + customerId + "/orders"))
                    .GET()
                    .build();

            HttpResponse<String> ordersRes =
                    client.send(ordersReq, HttpResponse.BodyHandlers.ofString());

            List<Map<String, Object>> orders = List.of();

            if (ordersRes.statusCode() == 200) {
                JsonNode root = mapper.readTree(ordersRes.body());
                JsonNode ordersArray = root.has("orders")
                        ? root.get("orders")
                        : root;

                orders = mapper.convertValue(
                        ordersArray,
                        new TypeReference<List<Map<String, Object>>>() {});
            }

            // ======================================================
            // 3) Fetch notifications for customer
            // ======================================================
            HttpRequest notifReq = HttpRequest.newBuilder()
                    .uri(URI.create(
                            NOTIFICATION_SERVICE_URL + "/customer/" + customerId))
                    .GET()
                    .build();

            HttpResponse<String> notifRes =
                    client.send(notifReq, HttpResponse.BodyHandlers.ofString());

            List<Map<String, Object>> notifications = List.of();

            if (notifRes.statusCode() == 200) {
                JsonNode notifArray = mapper.readTree(notifRes.body());
                notifications = mapper.convertValue(
                        notifArray,
                        new TypeReference<List<Map<String, Object>>>() {});
            }

            // ======================================================
            // 4) Forward to JSP
            // ======================================================
            request.setAttribute("customer", customer);
            request.setAttribute("orders", orders);
            request.setAttribute("notifications", notifications);

            request.getRequestDispatcher("/WEB-INF/customer-profile.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Server error occurred");
            request.getRequestDispatcher("/WEB-INF/customer-profile.jsp")
                   .forward(request, response);
        }
    }
}
