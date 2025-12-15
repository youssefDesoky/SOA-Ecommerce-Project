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
                <a href="index.jsp" class="logo">
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
                <i class="fas fa-check"></i>
            </div>
            
            <!-- Confirmation Title -->
            <h1 class="confirmation-title">Order Confirmed!</h1>
            <p class="confirmation-subtitle">
                Thank you for your purchase! Your order has been successfully placed and is being processed.
                We've sent a confirmation email with all the details.
            </p>
            
            <!-- Order Number -->
            <div class="order-number" id="orderNumber">
                Order #<span id="orderId">ORD-<%= request.getParameter("orderId") != null ? request.getParameter("orderId") : "N/A" %></span>
            </div>
            
            <!-- Order Details -->
            <div class="order-details">
                <h3 style="font-family: 'Plus Jakarta Sans', sans-serif; font-size: 1.5rem; margin-bottom: 20px; color: var(--dark);">
                    Order Details
                </h3>
                
                <div class="details-grid" id="orderDetails">
                    <!-- Customer Information -->
                    <div class="detail-group">
                        <h4>Customer Information</h4>
                        <p id="customerName">Mohamed Salah</p>
                        <p id="customerEmail" style="color: var(--gray); font-weight: normal; margin-top: 5px;">mohamed.salah@example.com</p>
                        <p id="customerPhone" style="color: var(--gray); font-weight: normal; margin-top: 5px;">+201234567890</p>
                    </div>
                    
                    <!-- Shipping Address -->
                    <div class="detail-group">
                        <h4>Shipping Address</h4>
                        <p id="shippingAddress">
                            123 Main Street,<br>
                            Nasr City, Cairo<br>
                            Egypt
                        </p>
                    </div>
                    
                    <!-- Payment Method -->
                    <div class="detail-group">
                        <h4>Payment Method</h4>
                        <p id="paymentMethod" class="highlight">Cash on Delivery</p>
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
            
            <!-- Delivery Estimate -->
            <div class="delivery-estimate">
                <div class="delivery-icon">
                    <i class="fas fa-shipping-fast"></i>
                </div>
                <div class="delivery-info">
                    <h4>Estimated Delivery</h4>
                    <p id="deliveryDate">
                        <%
                            java.util.Calendar cal = java.util.Calendar.getInstance();
                            cal.add(java.util.Calendar.DATE, 3);
                            String deliveryDate = new java.text.SimpleDateFormat("EEEE, MMMM dd").format(cal.getTime());
                        %>
                        <%= deliveryDate %> (3-5 business days)
                    </p>
                </div>
            </div>
            
            <!-- Order Total -->
            <div class="order-total">
                <div class="total-row">
                    <span>Subtotal</span>
                    <span id="orderSubtotal">$0.00</span>
                </div>
                <div class="total-row">
                    <span>Shipping</span>
                    <span id="orderShipping">$9.99</span>
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
            
            <!-- Next Steps -->
            <div class="next-steps">
                <h3 class="steps-title">
                    <i class="fas fa-list-check"></i>
                    What's Next?
                </h3>
                <ul class="steps-list">
                    <li>
                        <div class="step-number">1</div>
                        <div class="step-text">
                            <strong>Order Processing</strong><br>
                            We're preparing your items for shipment. You'll receive an email when your order ships.
                        </div>
                    </li>
                    <li>
                        <div class="step-number">2</div>
                        <div class="step-text">
                            <strong>Shipping</strong><br>
                            Your order will be shipped within 24 hours. Track your shipment using the link in your email.
                        </div>
                    </li>
                    <li>
                        <div class="step-number">3</div>
                        <div class="step-text">
                            <strong>Delivery</strong><br>
                            Expect your package within 3-5 business days. You'll receive a notification on delivery day.
                        </div>
                    </li>
                </ul>
            </div>
            
            <!-- Action Buttons -->
            <div class="action-buttons">
                <a href="index.jsp" class="btn btn-primary">
                    <i class="fas fa-shopping-bag"></i>
                    Continue Shopping
                </a>
                <button class="btn btn-secondary" onclick="printConfirmation()">
                    <i class="fas fa-print"></i>
                    Print Receipt
                </button>
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