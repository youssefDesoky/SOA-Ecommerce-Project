<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order Successful | Nexus</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Fonts & Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700&display=swap" rel="stylesheet">

    <!-- Your CSS -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/confirmation.css">
</head>

<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <nav class="nav">
                <a href="<%= request.getContextPath() %>/inventory" class="logo">
                    <div class="logo-icon">N</div>
                    <span class="logo-text">Nexus</span>
                </a>
            </nav>
        </div>
    </header>

    <!-- Main Content -->
    <div class="confirmation-container">
        <div class="confirmation-card">

            <!-- Success Icon -->
            <div class="success-icon">
                <i class="fas fa-check-circle"></i>
            </div>

            <!-- Title -->
            <h1 class="confirmation-title">Order Placed Successfully!</h1>

            <p class="confirmation-subtitle">
                Thank you for shopping with Nexus.  
                Your order has been confirmed and is now being processed.
            </p>

            <!-- Order ID -->
            <div class="order-number">
                Order #
                <strong>
                    <%= request.getAttribute("orderId") != null ? request.getAttribute("orderId") : "N/A" %>
                </strong>
            </div>

            <!-- Divider -->
            <hr style="margin: 30px 0; border: none; border-top: 1px solid #e5e7eb;">

            <!-- Info -->
            <div class="order-info">
                <p>
                    <i class="fas fa-envelope"></i>
                    A confirmation email has been sent to you.
                </p>
                <p>
                    <i class="fas fa-truck"></i>
                    Your order will be shipped shortly.
                </p>
            </div>

            <!-- Actions -->
            <div class="action-buttons" style="margin-top: 30px;">
                <a href="<%= request.getContextPath() %>/inventory" class="btn btn-primary">
                    <i class="fas fa-shopping-bag"></i>
                    Continue Shopping
                </a>
            </div>

        </div>
    </div>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <div class="footer-content">
                <div class="footer-section">
                    <h3>Nexus</h3>
                    <p>Premium e-commerce platform for tech enthusiasts. Quality products, curated collections, and exceptional service.</p>
                </div>
                
                <div class="footer-section">
                    <h3>Contact</h3>
                    <ul class="footer-links">
                        <li><i class="fas fa-map-marker-alt"></i> 123 Tech Street, San Francisco</li>
                        <li><i class="fas fa-phone"></i> +1 (555) 123-4567</li>
                        <li><i class="fas fa-envelope"></i> support@nexus.com</li>
                    </ul>
                </div>
            </div>
            
            <div class="copyright">
                <p>&copy; 2024 Nexus. All rights reserved.</p>
            </div>
        </div>
    </footer>
</body>
</html>
