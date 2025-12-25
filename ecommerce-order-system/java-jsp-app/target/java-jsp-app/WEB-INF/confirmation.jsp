<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmation | Nexus</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/confirmation.css">

    <script>
      window.APP_CONTEXT = '<%= request.getContextPath() %>';
    </script>
    <script src="<%= request.getContextPath() %>/js/confirmation.js" defer></script>
</head>

<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <nav class="nav">
                <a href="${pageContext.request.contextPath}/inventory" class="logo">
                    <div class="logo-icon">N</div>
                    <span class="logo-text">Nexus</span>
                </a>

                <a href="<%= request.getContextPath() %>/customers" class="user-profile-btn" id="user-profile-btn" title="My Profile">
                    <span id="user-initials">GU</span>
                </a>
            </nav>
        </div>
    </header>

    <!-- Main Content -->
    <div class="confirmation-container">
        <div class="confirmation-card">
            <!-- Success Icon -->
            <div class="success-icon">
                <i class="fas fa-bag-shopping"></i>
                <i class="fas fa-check icon-overlay"></i>
            </div>

            
            <!-- Confirmation Title -->
            <h1 class="confirmation-title">Confirm Order</h1>
            <p class="confirmation-subtitle">
                Please review your order details below before finalizing your purchase.
            </p>
            
            <!-- Order Details -->
            <div class="order-details">
                <h3 style="font-family: 'Plus Jakarta Sans', sans-serif; font-size: 1.5rem; margin-bottom: 20px; color: var(--dark);">
                    Order Details
                </h3>
                
                <div class="details-grid" id="orderDetails">
                    <!-- Customer Information -->
                    <div class="detail-group">
                        <h4>Customer Information</h4>
                        <p id="customerName"><%= request.getAttribute("customerName") != null ? request.getAttribute("customerName") : "Customer" %></p>
                        <p id="customerEmail" style="color: var(--gray); font-weight: normal; margin-top: 5px;"><%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %></p>
                        <p id="customerPhone" style="color: var(--gray); font-weight: normal; margin-top: 5px;"></p>
                    </div>
                    
                    <!-- Shipping Address -->
                    <div class="detail-group">
                        <h4>Shipping Address</h4>
                        <p id="shippingAddress">
                            <%= request.getAttribute("shippingAddress") != null ? request.getAttribute("shippingAddress") : "" %>
                        </p>
                    </div>
                    
                    <!-- Payment Method -->
                    <div class="detail-group">
                        <h4>Payment Method</h4>
                        <p id="paymentMethod" class="highlight"><%= request.getAttribute("paymentMethod") != null ? request.getAttribute("paymentMethod").toString().replace("_", " ") : "Cash on Delivery" %></p>
                        <p style="color: var(--gray); font-weight: normal; margin-top: 5px; font-size: 0.9rem;">
                            Pay when you receive your order
                        </p>
                    </div>
                    
                    <!-- Order Date -->
                    <div class="detail-group">
                        <h4>Order Date</h4>
                        <p id="orderDate"><%= new java.text.SimpleDateFormat("MMMM dd, yyyy").format(new java.util.Date()) %></p>
                        <p id="orderTime" style="color: var(--gray); font-weight: normal; margin-top: 5px;">
                            <%= new java.text.SimpleDateFormat("hh:mm a").format(new java.util.Date()) %>
                        </p>
                    </div>
                </div>
            </div>
            
            <!-- Products Summary -->
            <div class="products-summary" id="productsSummary">
                <h3 class="summary-title">
                    <i class="fas fa-box"></i>
                    Order Summary
                </h3>
                <div id="orderItems">
                    <!-- Order items will be loaded here -->
                </div>
            </div>
            

            <!-- Order Total -->
            <div class="order-total">
                <div class="total-row">
                    <span>Subtotal</span>
                    <span id="orderSubtotal">$0.00</span>
                </div>
                <div class="total-row">
                    <span>Discount</span>
                    <span id="orderDiscount" style="color: var(--success);">$0.00</span>
                </div>
                <div class="total-row">
                    <span>Tax</span>
                    <span id="orderTax">$0.00</span>
                </div>
                <div class="total-row grand-total">
                    <span>Total</span>
                    <span class="amount" id="orderTotal">$0.00</span>
                </div>
            </div>
            
            <div class="action-buttons">

                <form action="<%= request.getContextPath() %>/orders/submit" method="post">
                    <button class="btn btn-primary">
                        <i class="fas fa-check"></i>
                        Submit Order
                    </button>
                </form>

                <form action="<%= request.getContextPath() %>/orders/cancel" method="post">
                    <button class="btn btn-danger">
                        <i class="fas fa-times"></i>
                        Cancel Order
                    </button>
                </form>

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