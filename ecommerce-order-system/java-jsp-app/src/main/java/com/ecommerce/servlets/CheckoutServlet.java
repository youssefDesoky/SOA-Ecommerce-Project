package com.ecommerce.servlets;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String cartData = (session != null) ? (String) session.getAttribute("cartData") : null;

        if (cartData == null || cartData.trim().isEmpty() || "[]".equals(cartData.trim())) {
            // No cart stored on server -> go back to inventory
            response.sendRedirect(request.getContextPath() + "/inventory");
            return;
        }

        request.setAttribute("cartData", cartData);
        request.setAttribute("cartEmpty", false);
        request.getRequestDispatcher("/WEB-INF/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Cart comes from inventory via normal form POST (no fetch, no browser storage)
        String cartData = request.getParameter("cart_data");

        boolean empty = (cartData == null || cartData.trim().isEmpty() || "[]".equals(cartData.trim()));

        if (empty) {
            response.sendRedirect(request.getContextPath() + "/inventory");
            return;
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("cartData", cartData);

        request.setAttribute("cartData", cartData);
        request.setAttribute("cartEmpty", false);
        request.getRequestDispatcher("/WEB-INF/checkout.jsp").forward(request, response);
    }
}
