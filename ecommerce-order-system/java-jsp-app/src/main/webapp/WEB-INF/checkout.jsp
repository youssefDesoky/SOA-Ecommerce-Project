<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout | Nexus</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/checkout.css">
    <!-- NEW: moved inline styles to separate file -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/checkout.css">

    <script src="<%= request.getContextPath() %>/js/checkout.js" defer></script>
</head>

<%
    String cartData = (String) request.getAttribute("cartData");
    if (cartData == null) cartData = "[]";

    String cartDataEsc = cartData
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");

    boolean cartEmpty = "[]".equals(cartData.trim()) || cartData.trim().isEmpty();
%>

<body data-cart-empty="<%= cartEmpty %>">

<header class="header">
    <div class="container">
        <nav class="nav">
            <a href="${pageContext.request.contextPath}/inventory" class="logo">
                <div class="logo-icon">N</div>
                <span class="logo-text">Nexus</span>
            </a>

            <a href="<%= request.getContextPath() %>/customers" class="user-profile-btn" id="user-profile-btn" title="My Profile">
                <span id="user-initials">P</span>
            </a>
        </nav>
    </div>
</header>

<div class="container">
    <div class="checkout-progress">
        <div class="progress-step active" id="step-1-indicator">
            <div class="step-circle">1</div>
            <div class="step-label">Information</div>
        </div>
        <div class="progress-step" id="step-2-indicator">
            <div class="step-circle">2</div>
            <div class="step-label">Payment</div>
        </div>
        <div class="progress-step" id="step-3-indicator">
            <div class="step-circle">3</div>
            <div class="step-label">Confirmation</div>
        </div>
    </div>

    <div class="checkout-layout checkout-layout-single">
        <form id="checkoutForm" action="<%= request.getContextPath() %>/orders/create" method="POST">
            <input type="hidden" id="cartData" name="cart_data" value="<%= cartDataEsc %>">

            <div class="checkout-steps">

                <% if (cartEmpty) { %>
                <div class="cart-empty-alert">
                    Your cart is empty. Please add products before checking out.
                </div>
                <% } %>

                <!-- Step 1 -->
                <div class="step-content active" id="step-1">
                    <h2 class="step-title">
                        <i class="fas fa-user-circle"></i>
                        Customer Information
                    </h2>
                    <p class="step-description">
                        Please provide your details so we can process your order and keep you updated on its status.
                    </p>

                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">First Name <span class="required">*</span></label>
                            <input type="text" class="form-input" id="firstName" name="first_name" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Last Name <span class="required">*</span></label>
                            <input type="text" class="form-input" id="lastName" name="last_name" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Email Address <span class="required">*</span></label>
                            <input type="email" class="form-input" id="email" name="email" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Phone Number <span class="required">*</span></label>
                            <input type="tel" class="form-input" id="phone" name="phone" placeholder="+201234567890" required>
                        </div>
                    </div>

                    <h3 class="step-title shipping-title">
                        <i class="fas fa-truck"></i>
                        Shipping Address
                    </h3>

                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label">Government <span class="required">*</span></label>
                            <select class="form-input" id="government" name="government" required>
                                <option value="">Select Government</option>
                                <option value="Cairo">Cairo</option>
                                <option value="Giza">Giza</option>
                                <option value="Alexandria">Alexandria</option>
                                <option value="Dakahlia">Dakahlia</option>
                                <option value="Red Sea">Red Sea</option>
                                <option value="Beheira">Beheira</option>
                                <option value="Faiyum">Faiyum</option>
                                <option value="Gharbia">Gharbia</option>
                                <option value="Ismailia">Ismailia</option>
                                <option value="Monufia">Monufia</option>
                                <option value="Minya">Minya</option>
                                <option value="Qalyubia">Qalyubia</option>
                                <option value="New Valley">New Valley</option>
                                <option value="Suez">Suez</option>
                                <option value="Aswan">Aswan</option>
                                <option value="Asyut">Asyut</option>
                                <option value="Beni Suef">Beni Suef</option>
                                <option value="Port Said">Port Said</option>
                                <option value="Damietta">Damietta</option>
                                <option value="Sharqia">Sharqia</option>
                                <option value="South Sinai">South Sinai</option>
                                <option value="Kafr El Sheikh">Kafr El Sheikh</option>
                                <option value="Matrouh">Matrouh</option>
                                <option value="Luxor">Luxor</option>
                                <option value="Qena">Qena</option>
                                <option value="North Sinai">North Sinai</option>
                                <option value="Sohag">Sohag</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">City <span class="required">*</span></label>
                            <input type="text" class="form-input" id="city" name="city" required>
                        </div>

                        <div class="form-group full-width">
                            <label class="form-label">Street Address <span class="required">*</span></label>
                            <input type="text" class="form-input" id="address" name="address"
                                   placeholder="Street name, Building number, Floor, Apartment" required>
                        </div>
                    </div>

                    <div class="step-navigation">
                        <a href="${pageContext.request.contextPath}/inventory" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i>
                            Continue Shopping
                        </a>
                        <button type="button" class="btn btn-primary" id="next-step-1" <%= cartEmpty ? "disabled" : "" %>>
                            Proceed to Payment
                            <i class="fas fa-arrow-right"></i>
                        </button>
                    </div>
                </div>

                <!-- Step 2 -->
                <div class="step-content" id="step-2">
                    <h2 class="step-title">
                        <i class="fas fa-credit-card"></i>
                        Payment Method
                    </h2>

                    <div class="payment-methods">
                        <label class="payment-method selected" id="cashOnDeliveryMethod">
                            <input type="radio" name="payment_method" value="cash_on_delivery" checked>
                            <div class="payment-icon"><i class="fas fa-money-bill-wave"></i></div>
                            <div class="payment-info">
                                <div class="payment-name">Cash on Delivery</div>
                                <div class="payment-description">Pay with cash when your order arrives.</div>
                            </div>
                        </label>

                        <label class="payment-method" id="creditCardMethod">
                            <input type="radio" name="payment_method" value="credit_card">
                            <div class="payment-icon"><i class="far fa-credit-card"></i></div>
                            <div class="payment-info">
                                <div class="payment-name">Credit/Debit Card</div>
                                <div class="payment-description">Pay securely with your card.</div>
                            </div>
                        </label>
                    </div>

                    <div class="card-details" id="cardDetails">
                        <h3 class="card-details-title">Card Details</h3>

                        <div class="card-row">
                            <div class="form-group">
                                <label class="form-label">Card Number <span class="required">*</span></label>
                                <input type="text" class="form-input" id="cardNumber" placeholder="1234 5678 9012 3456" maxlength="19">
                            </div>
                        </div>

                        <div class="card-row">
                            <div class="form-group">
                                <label class="form-label">Name on Card <span class="required">*</span></label>
                                <input type="text" class="form-input" id="cardName" placeholder="Mohamed Salah">
                            </div>

                            <div class="form-group">
                                <label class="form-label">Expiry Date <span class="required">*</span></label>
                                <input type="text" class="form-input" id="cardExpiry" placeholder="MM/YY" maxlength="5">
                            </div>
                        </div>

                        <div class="card-row">
                            <div class="form-group">
                                <label class="form-label">CVV <span class="required">*</span></label>
                                <input type="text" class="form-input" id="cardCvv" placeholder="123" maxlength="4">
                            </div>
                        </div>
                    </div>

                    <div class="terms-checkbox">
                        <label class="terms-label">
                            <input type="checkbox" id="terms">
                            <div class="terms-text">
                                I agree to the <a href="#">Terms and Conditions</a> and
                                <a href="#">Privacy Policy</a>.
                            </div>
                        </label>
                        <div class="error-message" id="termsError">
                            You must agree to the terms and conditions
                        </div>
                    </div>

                    <div class="step-navigation">
                        <button type="button" class="btn btn-secondary" id="prev-step-2">
                            <i class="fas fa-arrow-left"></i>
                            Back to Information
                        </button>
                        <button type="submit" class="btn btn-primary" id="place-order-btn" <%= cartEmpty ? "disabled" : "" %>>
                            <i class="fas fa-lock"></i>
                            Place Order
                        </button>
                    </div>
                </div>

            </div>
        </form>
    </div>
</div>

<div class="loading-overlay" id="loadingOverlay">
    <div class="spinner"></div>
    <div class="loading-title">Processing your order...</div>
    <div class="loading-subtitle">Please don't close this window</div>
</div>

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
