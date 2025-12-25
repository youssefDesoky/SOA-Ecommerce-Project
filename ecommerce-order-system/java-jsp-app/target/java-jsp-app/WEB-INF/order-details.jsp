<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Order Details | Nexus</title>

<!-- Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
/* --- Core Styles from Index Page --- */
:root {
    --primary: #3a36e0;
    --primary-dark: #2a27c9;
    --secondary: #ff6b82;
    --dark: #0f172a;
    --dark-light: #1e293b;
    --light: #f8fafc;
    --gray: #64748b;
    --gray-light: #e2e8f0;
    --success: #10b981;
    --warning: #f59e0b;
    --radius: 12px;
    --shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
    --card-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
    --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    background-color: #f9fafb;
    color: var(--dark);
    line-height: 1.6;
}

.container {
    max-width: 1200px; /* Slightly tighter for order details focus */
    margin: 0 auto;
    padding: 0 20px;
}

/* --- Header Styles (Matched) --- */
.header {
    background: white;
    box-shadow: 0 2px 15px rgba(0, 0, 0, 0.05);
    position: sticky;
    top: 0;
    z-index: 1000;
    padding: 15px 0;
}

.nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo {
    display: flex;
    align-items: center;
    gap: 10px;
    text-decoration: none;
}

.logo-icon {
    width: 36px;
    height: 36px;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: 800;
    font-size: 18px;
}

.logo-text {
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 24px;
    font-weight: 800;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

.header-actions {
    display: flex;
    align-items: center;
    gap: 20px;
}

.cart-btn {
    position: relative;
    background: none;
    border: none;
    font-size: 20px;
    color: var(--dark);
    cursor: pointer;
    padding: 8px;
    transition: var(--transition);
}

.cart-btn:hover {
    color: var(--primary);
}

.cart-count {
    position: absolute;
    top: -5px;
    right: -5px;
    background: var(--secondary);
    color: white;
    font-size: 12px;
    font-weight: 600;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.user-profile-btn {
    width: 42px;
    height: 42px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: 600;
    font-size: 0.9rem;
    cursor: pointer;
    border: 2px solid transparent;
    transition: var(--transition);
    text-transform: uppercase;
    text-decoration: none;
}

.user-profile-btn:hover {
    transform: scale(1.08);
    box-shadow: 0 4px 15px rgba(58, 54, 224, 0.4);
}

/* --- Order Details Specific Styles --- */
.page-header {
    margin: 40px 0 30px;
}

.breadcrumb {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--gray);
    font-size: 0.9rem;
    margin-bottom: 15px;
}

.breadcrumb a {
    color: var(--gray);
    text-decoration: none;
    transition: var(--transition);
}

.breadcrumb a:hover {
    color: var(--primary);
}

.page-title {
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 2rem;
    font-weight: 800;
    color: var(--dark);
    display: flex;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
}

.status-badge {
    font-size: 0.85rem;
    padding: 6px 16px;
    border-radius: 20px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-family: 'Inter', sans-serif;
}

.status-pending { background: #fff7ed; color: var(--warning); border: 1px solid #ffedd5; }
.status-shipped { background: #ecfdf5; color: var(--success); border: 1px solid #d1fae5; }
.status-cancelled { background: #fef2f2; color: var(--secondary); border: 1px solid #fee2e2; }

.order-layout {
    display: grid;
    grid-template-columns: 2fr 1fr 1fr;
    gap: 30px;
    margin-bottom: 60px;
}

.card {
    background: white;
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    padding: 30px;
    height: 100%;
    border: 1px solid rgba(255,255,255,0.5);
}

.card-title {
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 1.25rem;
    font-weight: 700;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid var(--gray-light);
    display: flex;
    justify-content: space-between;
    align-items: center;
}

/* Items List */
.order-items {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.order-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-bottom: 20px;
    border-bottom: 1px solid var(--gray-light);
}

.order-item:last-child {
    border-bottom: none;
    padding-bottom: 0;
}

.item-info {
    display: flex;
    align-items: center;
    gap: 20px;
}

.item-icon-placeholder {
    width: 60px;
    height: 60px;
    background: var(--light);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--gray);
    font-size: 1.2rem;
}

.item-details h4 {
    font-weight: 600;
    color: var(--dark);
    margin-bottom: 4px;
}

.item-meta {
    font-size: 0.9rem;
    color: var(--gray);
}

.item-price {
    font-weight: 700;
    font-size: 1.1rem;
    color: var(--dark);
}

/* Summary Section */
.summary-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 12px;
    color: var(--gray);
    font-size: 0.95rem;
}

.summary-row.total {
    margin-top: 20px;
    padding-top: 20px;
    border-top: 2px dashed var(--gray-light);
    color: var(--dark);
    font-weight: 800;
    font-size: 1.3rem;
}

.summary-row span:nth-child(2) {
    font-weight: 600;
}

.info-group {
    margin-bottom: 25px;
}

.info-label {
    font-size: 0.8rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: var(--gray);
    margin-bottom: 8px;
    font-weight: 600;
}

.info-value {
    color: var(--dark);
    font-weight: 500;
}

.action-btn {
    width: 100%;
    padding: 12px;
    border-radius: var(--radius);
    font-weight: 600;
    cursor: pointer;
    text-align: center;
    transition: var(--transition);
    border: none;
    text-decoration: none;
    display: inline-block;
}

.btn-primary {
    background: var(--primary);
    color: white;
}

.btn-primary:hover {
    background: var(--primary-dark);
    box-shadow: 0 4px 12px rgba(58, 54, 224, 0.3);
}

.btn-outline {
    background: transparent;
    border: 1px solid var(--gray-light);
    color: var(--dark);
    margin-top: 10px;
}

.btn-outline:hover {
    border-color: var(--primary);
    color: var(--primary);
    background: #f8fafc;
}

/* Footer (Matched) */
.footer {
    background: var(--dark);
    color: white;
    padding: 60px 0 30px;
    margin-top: auto;
}

.footer-content {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 40px;
    margin-bottom: 40px;
}

.footer-section h3 {
    font-family: 'Plus Jakarta Sans', sans-serif;
    font-size: 1.2rem;
    margin-bottom: 20px;
    color: white;
}

.footer-links {
    list-style: none;
}

.footer-links li {
    margin-bottom: 10px;
}

.footer-links a {
    color: #cbd5e1;
    text-decoration: none;
    transition: var(--transition);
}

.footer-links a:hover {
    color: white;
    padding-left: 5px;
}

.copyright {
    text-align: center;
    padding-top: 30px;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    color: #94a3b8;
    font-size: 0.9rem;
}

/* Loading/Error States */
.state-message {
    text-align: center;
    padding: 60px 20px;
    color: var(--gray);
}
.state-message i {
    font-size: 3rem;
    margin-bottom: 20px;
    color: var(--gray-light);
}

@media (max-width: 1024px) {
    .order-layout {
        grid-template-columns: 1fr;
    }
}
</style>
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
              
              <div class="header-actions">                    
                  <button class="cart-btn" id="cart-toggle">
                      <i class="fas fa-shopping-bag"></i>
                      <span class="cart-count">2</span>
                  </button>

                  <a href="#" class="user-profile-btn" title="My Profile">
                      <span>P</span>
                  </a>
              </div>
          </nav>
      </div>
  </header>

  <div class="container">
    
    <!-- Loading State -->
    <div id="loading" class="state-message">
        <i class="fas fa-circle-notch fa-spin" style="color: var(--primary)"></i>
        <h3>Loading order details...</h3>
    </div>

    <!-- Error State -->
    <div id="error" class="state-message" style="display:none;">
        <i class="fas fa-exclamation-circle" style="color: var(--secondary)"></i>
        <h3 id="error-text">Order not found</h3>
        <button class="action-btn btn-outline" style="max-width: 200px; margin: 20px auto;" onclick="window.location.reload()">Try Again</button>
    </div>

    <!-- Main Order Content -->
    <div id="orderCard" style="display:none;">
      
      <div class="page-header">
          <div class="breadcrumb">
              <a href="#"><i class="fas fa-arrow-left"></i> Back to Orders</a>
              <span>/</span>
              <span>Order Details</span>
          </div>
          <div class="page-title">
              <span id="orderIdDisplay">Order #Loading...</span>
              <span id="orderStatusBadge" class="status-badge status-pending">Loading...</span>
          </div>
          <p style="color: var(--gray); margin-top: 5px;" id="orderDateDisplay">Placed on ...</p>
      </div>

      <div class="order-layout">
          <!-- Left Column: Items -->
          <div class="card">
              <div class="card-title">
                  <span>Items</span>
                  <span style="font-size: 0.9rem; color: var(--gray); font-weight: 500;" id="itemCount">0 items</span>
              </div>
              <div id="items" class="order-items">
                  <!-- Items injected here -->
              </div>
          </div>
          
          <!-- Middle Column: Customer Details -->
          <div class="card">
              <div class="card-title">Customer Details</div>
              
              <div class="info-group">
                  <div class="info-label">Shipping Address</div>
                  <div class="info-value" id="shippingAddress"></div>
              </div>

              <div class="info-group">
                  <div class="info-label">Payment Method</div>
                  <div class="info-value" id="paymentMethod"></div>
              </div>
          </div>

          <!-- Right Column: Summary -->
          <div class="card">
              <div class="card-title">Order Summary</div>
              
              <div class="summary-row">
                  <span>Subtotal</span>
                  <span id="subtotal">$0.00</span>
              </div>
              <div class="summary-row">
                  <span>Shipping</span>
                  <span style="color: var(--success)">Free</span>
              </div>
              <div class="summary-row">
                  <span>Discount</span>
                  <span id="discount" style="color: var(--secondary)">-$0.00</span>
              </div>
              <div class="summary-row total">
                  <span>Total</span>
                  <span id="total" style="color: var(--primary)">$0.00</span>
              </div>
          </div>
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

<script>
const orderId = window.location.pathname.split('/').pop();
const ORDER_API = "http://localhost:5001/api/orders/" + orderId;
const INVENTORY_API = "http://localhost:5002/api/inventory";

async function fetchOrderAndInventory() {
    try {
        const [orderRes, inventoryRes] = await Promise.all([
            fetch(ORDER_API),
            fetch(INVENTORY_API)
        ]);

        if (!orderRes.ok) throw new Error("Order not found");
        if (!inventoryRes.ok) throw new Error("Inventory service error");

        const order = await orderRes.json();
        const inventory = await inventoryRes.json();

        renderOrder(order, inventory);
    } catch (err) {
        console.error(err);
        document.getElementById("loading").style.display = "none";
        document.getElementById("error").style.display = "block";
    }
}

function renderOrder(order, inventory) {
    console.log("Rendering order:", order);

    document.getElementById("loading").style.display = "none";
    document.getElementById("orderCard").style.display = "block";

    document.getElementById("orderIdDisplay").innerText = "Order #" + order.order_id;
    document.getElementById("shippingAddress").innerText = order.shipping_address;
    document.getElementById("paymentMethod").innerText = order.payment_method;

    // Status badge
    const badge = document.getElementById("orderStatusBadge");
    badge.innerText = order.status;
    badge.className = "status-badge " +
        (order.status === "completed" ? "status-shipped" :
         order.status === "cancelled" ? "status-cancelled" : "status-pending");

    // Date
    const date = new Date(order.order_date);
    document.getElementById("orderDateDisplay").innerText =
        "Placed on " + date.toLocaleString();

    // Inventory lookup map
    const inventoryMap = {};
    inventory.forEach(p => inventoryMap[p.product_id] = p.product_name);

    // Items
    const itemsDiv = document.getElementById("items");
    document.getElementById("itemCount").innerText =
        order.items.length + (order.items.length === 1 ? " item" : " items");

    itemsDiv.innerHTML = "";

    order.items.forEach(item => {
        const name = inventoryMap[item.product_id] || ("Product #" + item.product_id);

        itemsDiv.innerHTML += `
          <div class="order-item">
            <div class="item-info">
              <div class="item-icon-placeholder">
                <i class="fas fa-box"></i>
              </div>
              <div class="item-details">
                <h4>${name}</h4>
                <div class="item-meta">Qty: ${item.quantity}</div>
              </div>
            </div>
            <div class="item-price">$${Number(item.total_price).toFixed(2)}</div>
          </div>
        `;
    });

    // Summary
    document.getElementById("subtotal").innerText =
        "$" + (order.total_amount + order.total_discount).toFixed(2);

    document.getElementById("discount").innerText =
        "-$" + order.total_discount.toFixed(2);

    document.getElementById("total").innerText =
        "$" + order.total_amount.toFixed(2);
}

fetchOrderAndInventory();
</script>


</body>
</html>