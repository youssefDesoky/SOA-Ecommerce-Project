<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus | Premium E-Commerce</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/index.css">

    <script>
        window.APP_CONTEXT = '<%= request.getContextPath() %>';
    </script>
    <script src="<%= request.getContextPath() %>/js/index.js" defer></script>
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
                
                <div class="header-actions">
                    <div class="search-bar">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="search-input" placeholder="Search products...">
                    </div>
                    
                    <button class="cart-btn" id="cart-toggle">
                        <i class="fas fa-shopping-bag"></i>
                        <span class="cart-count" id="cart-count">${sessionScope.cartCount != null ? sessionScope.cartCount : 0}</span>
                    </button>

                    <a href="<%= request.getContextPath() %>/customer-profile.jsp" class="user-profile-btn" id="user-profile-btn" title="My Profile">
                        <span id="user-initials">GU</span>
                    </a>
                </div>
            </nav>
        </div>
    </header>

    <!-- Products Section -->
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
                      <img src="${empty p.image ? 'https://images.unsplash.com/photo-1505740420928-5e560c06b30e?w=500&auto=format&fit=crop' : p.image}" alt="${p.product_name}" class="product-image">
                      <div class="product-info">
                        <div class="product-category">${p.category}</div>
                        <h3 class="product-name">${p.product_name}</h3>
                        <p class="product-description">${p.description}</p>
                        <div class="product-footer">
                          <div>
                            <div class="product-price">$<c:out value="${p.price}" /></div>
                            <div class="product-stock">
                              <i class="fas fa-check-circle"></i>
                              <c:out value="${p.stock_quantity}" /> in stock
                            </div>
                          </div>
                        </div>
                        <form action="${pageContext.request.contextPath}/api/orders/create" method="post">
                          <input type="hidden" name="customer_id" value="${sessionScope.customerId}">
                          <input type="hidden" name="product_id" value="${p.product_id}">
                          <input type="hidden" name="quantity" value="1">
                          <button type="submit" class="add-to-cart"><i class="fas fa-shopping-cart"></i> Add to Cart</button>
                        </form>
                      </div>
                    </div>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <p style="color:#999;">No products available.</p>
                </c:otherwise>
              </c:choose>
            </div>
        </div>
    </section>

    <!-- Cart Sidebar -->
    <div class="cart-dropdown" id="cart-sidebar">
        <div class="cart-header">
            <h3 class="cart-title">Your Cart</h3>
            <button class="close-cart" id="close-cart">
                <i class="fas fa-times"></i>
            </button>
        </div>
        
        <div class="cart-items" id="cart-items">
            <!-- Cart items will be loaded here -->
        </div>
        
        <div class="cart-footer">
            <div class="cart-total">
                <span>Total:</span>
                <span class="cart-total-amount" id="cart-total">$0.00</span>
            </div>
            <button class="checkout-btn" id="checkout-btn">
                <i class="fas fa-lock"></i>
                Proceed to Checkout
            </button>
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