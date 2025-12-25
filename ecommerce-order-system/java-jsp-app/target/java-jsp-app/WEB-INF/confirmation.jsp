<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order Confirmation | Nexus</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Fonts & Icons -->
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;600;700&family=Inter:wght@400;500;600&display=swap"
          rel="stylesheet">

    <!-- CSS -->
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/confirmation.css">
</head>

<body>

<!-- ================= HEADER ================= -->
<header class="header">
    <div class="container">
        <nav class="nav">
            <a href="${pageContext.request.contextPath}/inventory" class="logo">
                <div class="logo-icon">N</div>
                <span class="logo-text">Nexus</span>
            </a>

            <a href="${pageContext.request.contextPath}/customers"
               class="user-profile-btn"
               title="My Profile">
                <span>P</span>
            </a>
        </nav>
    </div>
</header>

<!-- ================= MAIN ================= -->
<div class="confirmation-container">
    <div class="confirmation-card">

        <!-- Icon -->
        <div class="success-icon">
            <i class="fas fa-bag-shopping"></i>
            <i class="fas fa-check icon-overlay"></i>
        </div>

        <!-- Title -->
        <h1 class="confirmation-title">Confirm Your Order</h1>
        <p class="confirmation-subtitle">
            Please review your order details before submitting.
        </p>

        <!-- ================= ORDER DETAILS ================= -->
        <div class="order-details">
            <h3>Order Details</h3>

            <div class="details-grid">

                <div class="detail-group">
                    <h4>Customer</h4>
                    <p>${customerName}</p>
                    <p class="muted">${email}</p>
                    <p class="muted">${phone}</p>
                </div>

                <div class="detail-group">
                    <h4>Shipping Address</h4>
                    <p>${shippingAddress}</p>
                </div>

                <div class="detail-group">
                    <h4>Payment Method</h4>
                    <p class="highlight">
                        ${paymentMethod}
                    </p>
                </div>

                <div class="detail-group">
                    <h4>Order Date</h4>
                    <p>
                        <%= new java.text.SimpleDateFormat("MMMM dd, yyyy")
                                .format(new java.util.Date()) %>
                    </p>
                    <p class="muted">
                        <%= new java.text.SimpleDateFormat("hh:mm a")
                                .format(new java.util.Date()) %>
                    </p>
                </div>

            </div>
        </div>

        <!-- ================= ITEMS ================= -->
        <div class="products-summary">
            <h3 class="summary-title">
                <i class="fas fa-box"></i>
                Order Summary
            </h3>

            <c:forEach var="item" items="${items}">
                <div class="product-item">
                    <div class="product-info">
                        <div class="product-name">
                            Name: ${item.product_name}
                        </div>
                        <div class="product-meta">
                            Quantity: ${item.quantity}
                        </div>
                    </div>

                    <div class="product-price">
                        $${item.total_price}
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- ================= TOTALS ================= -->
        <div class="order-total">

            <div class="total-row">
                <span>Subtotal</span>
                <span>$${subtotal}</span>
            </div>

            <div class="total-row">
                <span>Discount</span>
                <span style="color: var(--success)">
                    -$${discount}
                </span>
            </div>

            <div class="total-row">
                <span>Tax</span>
                <span>$${tax}</span>
            </div>

            <div class="total-row grand-total">
                <span>Total</span>
                <span class="amount">$${total}</span>
            </div>

        </div>

        <!-- ================= ACTIONS ================= -->
        <div class="action-buttons">

            <form action="${pageContext.request.contextPath}/orders/submit"
                  method="post">
                <button class="btn btn-primary">
                    <i class="fas fa-check"></i>
                    Submit Order
                </button>
            </form>

            <form action="${pageContext.request.contextPath}/orders/cancel"
                  method="post">
                <button class="btn btn-secondary">
                    <i class="fas fa-times"></i>
                    Cancel Order
                </button>
            </form>

        </div>

    </div>
</div>

<!-- ================= FOOTER ================= -->
<footer class="footer">
    <div class="container">
        <div class="footer-content">

            <div class="footer-section">
                <h3>Nexus</h3>
                <p>
                    Premium e-commerce platform for tech enthusiasts.
                </p>
            </div>

            <div class="footer-section">
                <h3>Contact</h3>
                <ul class="footer-links">
                    <li><i class="fas fa-map-marker-alt"></i> 123 Tech Street</li>
                    <li><i class="fas fa-phone"></i> +1 (555) 123-4567</li>
                    <li><i class="fas fa-envelope"></i> support@nexus.com</li>
                </ul>
            </div>

        </div>

        <div class="copyright">
            &copy; 2024 Nexus. All rights reserved.
        </div>
    </div>
</footer>

</body>
</html>
