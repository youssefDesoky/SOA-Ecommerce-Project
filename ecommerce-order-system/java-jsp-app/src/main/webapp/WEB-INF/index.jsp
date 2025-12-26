<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus | Premium E-Commerce</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">

    <script src="${pageContext.request.contextPath}/js/index.js" defer></script>
</head>

<body data-context-path="${pageContext.request.contextPath}">

<header class="header">
    <div class="container">
        <nav class="nav">
            <a href="${pageContext.request.contextPath}/inventory" class="logo">
                <div class="logo-icon">N</div>
                <span class="logo-text">Nexus</span>
            </a>

            <div class="header-actions">
                <button class="cart-btn" id="cart-toggle" type="button">
                    <i class="fas fa-shopping-bag"></i>
                    <span class="cart-count" id="cart-count">0</span>
                </button>

                <a href="${pageContext.request.contextPath}/customers"
                   class="user-profile-btn"
                   id="user-profile-btn"
                   title="My Profile">
                    <span id="user-initials">P</span>
                </a>
            </div>
        </nav>
    </div>
</header>

<section class="section">
    <div class="container">
        <div class="section-header">
            <div>
                <h2 class="section-title">Featured Products</h2>
                <p class="section-subtitle">Handpicked selection of premium electronics</p>
            </div>
        </div>

        <div class="product-grid" id="products-container">
            <c:choose>
                <c:when test="${not empty products}">
                    <c:forEach var="p" items="${products}">
                        <div class="product-card">
                            <c:if test="${p.stock_quantity == 0}">
                                <div class="product-badge">Out of Stock</div>
                            </c:if>

                            <img src="${p.image}" alt="${p.product_name}" class="product-image">

                            <div class="product-info">
                                <div class="product-category">${p.category}</div>
                                <h3 class="product-name">${p.product_name}</h3>

                                <div class="product-footer">
                                    <div>
                                        <div class="product-price">$${String.format("%.2f", p.price)}</div>
                                        <div class="product-stock">
                                            <i class="fas fa-check-circle"></i>
                                            ${p.stock_quantity} in stock
                                        </div>
                                    </div>
                                </div>

                                <button class="add-to-cart"
                                        type="button"
                                        data-id="${p.product_id}"
                                        data-name="${p.product_name}"
                                        data-price="${p.price}"
                                        data-image="${p.image}">
                                    <i class="fas fa-shopping-cart"></i> Add to Cart
                                </button>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>

                <c:otherwise>
                    <div class="no-products">
                        <i class="fas fa-box-open"></i>
                        <p>No products available at the moment.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</section>

<!-- Cart Sidebar -->
<div class="cart-dropdown" id="cart-sidebar">
    <div class="cart-header">
        <h3 class="cart-title">Your Cart</h3>
        <button class="close-cart" id="close-cart" type="button">
            <i class="fas fa-times"></i>
        </button>
    </div>

    <div class="cart-items" id="cart-items"></div>

    <div class="cart-footer">
        <div class="cart-total">
            <span>Total:</span>
            <span class="cart-total-amount" id="cart-total">$0.00</span>
        </div>
        <button class="checkout-btn" id="checkout-btn" type="button">
            <i class="fas fa-lock"></i>
            Proceed to Checkout
        </button>
    </div>
</div>

<!-- Hidden POST form (NO fetch, NO browser storage) -->
<form id="checkout-post-form"
      action="${pageContext.request.contextPath}/checkout"
      method="post"
      class="hidden-form">
    <input type="hidden" name="cart_data" id="checkout-cart-data" value="">
</form>

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
