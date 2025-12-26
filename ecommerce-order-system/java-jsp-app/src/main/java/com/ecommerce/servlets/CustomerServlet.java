package com.ecommerce.servlets;

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

    private static final String CUSTOMER_SERVICE_URL = "http://localhost:5004/api/customers";

    private final HttpClient client = HttpClient.newHttpClient();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        // /customers , /customers/ , /customers/profile -> show page
        if (pathInfo == null || "/".equals(pathInfo) || "/profile".equals(pathInfo)) {
            request.getRequestDispatcher("/WEB-INF/customer-profile.jsp").forward(request, response);
            return;
        }

        // keep your existing proxy behavior if you still need it
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

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
            request.getRequestDispatcher("/WEB-INF/customer-profile.jsp").forward(request, response);
            return;
        }

        email = email.trim();
        request.setAttribute("searchedEmail", email);

        try {
            // 1) Get customer by email
            String encodedEmail = URLEncoder.encode(email, StandardCharsets.UTF_8);
            HttpRequest customerReq = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/email/" + encodedEmail))
                    .GET()
                    .build();

            HttpResponse<String> customerRes = client.send(customerReq, HttpResponse.BodyHandlers.ofString());

            if (customerRes.statusCode() == 404) {
                request.setAttribute("errorMessage", "Customer not found with this email");
                request.getRequestDispatcher("/WEB-INF/customer-profile.jsp").forward(request, response);
                return;
            }
            if (customerRes.statusCode() != 200) {
                request.setAttribute("errorMessage", "Failed to fetch customer data");
                request.getRequestDispatcher("/WEB-INF/customer-profile.jsp").forward(request, response);
                return;
            }

            JsonNode customerJson = mapper.readTree(customerRes.body());

            // Convert customer JsonNode to Map
            Map<String, Object> customer = mapper.convertValue(customerJson, new TypeReference<Map<String, Object>>() {});

            int customerId = customerJson.path("customer_id").asInt();

            // 2) Get orders for customer (Customer Service composition endpoint)
            HttpRequest ordersReq = HttpRequest.newBuilder()
                    .uri(URI.create(CUSTOMER_SERVICE_URL + "/" + customerId + "/orders"))
                    .GET()
                    .build();

            HttpResponse<String> ordersRes = client.send(ordersReq, HttpResponse.BodyHandlers.ofString());

            List<Map<String, Object>> orders = List.of(); // Initialize empty list

            if (ordersRes.statusCode() == 200) {
                JsonNode ordersRoot = mapper.readTree(ordersRes.body());

                // Your Flask returns: { "orders": [...] }
                JsonNode ordersArray = ordersRoot.has("orders") ? ordersRoot.get("orders") : ordersRoot;
                orders = mapper.convertValue(
                        ordersArray,
                        new TypeReference<List<Map<String, Object>>>() {}
                );
            }

            // Forward data to JSP
            request.setAttribute("customer", customer);
            request.setAttribute("orders", orders);
            request.setAttribute("successMessage", "Customer loaded successfully");

            request.getRequestDispatcher("/WEB-INF/customer-profile.jsp").forward(request, response);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            request.setAttribute("errorMessage", "Request interrupted");
            request.getRequestDispatcher("/WEB-INF/customer-profile.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Server error while loading customer");
            request.getRequestDispatcher("/WEB-INF/customer-profile.jsp").forward(request, response);
        }
    }
}
