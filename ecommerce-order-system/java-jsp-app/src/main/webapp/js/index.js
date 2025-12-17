const contextPath = window.APP_CONTEXT || '';
let cart = JSON.parse(localStorage.getItem('nexusCart')) || [];

// DOM Elements
const productsContainer = document.getElementById('products-container');
const cartSidebar = document.getElementById('cart-sidebar');
const cartToggle = document.getElementById('cart-toggle');
const closeCart = document.getElementById('close-cart');
const cartItems = document.getElementById('cart-items');
const cartCount = document.getElementById('cart-count');
const cartTotal = document.getElementById('cart-total');
const checkoutBtn = document.getElementById('checkout-btn');

// Wire add to cart buttons
function wireAddToCartButtons() {
  document.querySelectorAll('.product-card .add-to-cart').forEach((btn) => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const id = btn.getAttribute('data-id');
      const name = btn.getAttribute('data-name');
      const price = parseFloat(btn.getAttribute('data-price'));
      const image = btn.getAttribute('data-image');
      addToCart(id, name, price, image);
    });
  });
}

// Initialize add to cart buttons when DOM loads
document.addEventListener('DOMContentLoaded', wireAddToCartButtons);

// Cart functions
function addToCart(productId, productName, price, image) {
  const existingItem = cart.find(item => item.id === productId);
  if (existingItem) {
    existingItem.quantity += 1;
  } else {
    cart.push({ 
      id: productId, 
      name: productName, 
      price: price, 
      image: image, 
      quantity: 1 
    });
  }
  updateCart();
  showNotification(`${productName} added to cart!`);
}

function removeFromCart(productId) {
  cart = cart.filter(item => item.id !== productId);
  updateCart();
  showNotification('Item removed from cart');
}

function updateCart() {
  localStorage.setItem('nexusCart', JSON.stringify(cart));
  const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
  cartCount.textContent = totalItems;
  cartCount.style.display = totalItems > 0 ? 'flex' : 'none';

  if (cart.length === 0) {
    cartItems.innerHTML = `
      <div class="cart-empty">
        <i class="fas fa-shopping-bag"></i>
        <h3>Your cart is empty</h3>
        <p>Add some products to get started</p>
      </div>
    `;
  } else {
    cartItems.innerHTML = cart.map(item => `
      <div class="cart-item">
        <img src="${item.image}" alt="${item.name}" class="cart-item-image">
        <div class="cart-item-details">
          <div class="cart-item-name">${item.name}</div>
          <div class="cart-item-price">$${(item.price * item.quantity).toFixed(2)}</div>
          <div class="cart-item-quantity">
            <button class="quantity-btn" onclick="updateQuantity('${item.id}', ${item.quantity - 1})">-</button>
            <span class="quantity">${item.quantity}</span>
            <button class="quantity-btn" onclick="updateQuantity('${item.id}', ${item.quantity + 1})">+</button>
            <button class="remove-item" onclick="removeFromCart('${item.id}')"><i class="fas fa-trash"></i></button>
          </div>
        </div>
      </div>
    `).join('');
  }

  const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  cartTotal.textContent = `$${total.toFixed(2)}`;
}

function updateQuantity(productId, newQuantity) {
  if (newQuantity < 1) return removeFromCart(productId);
  const item = cart.find(item => item.id === productId);
  if (item) {
    item.quantity = newQuantity;
    updateCart();
  }
}

async function checkout() {
  try {
    const res = await fetch(`${contextPath}/api/orders/create`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        customer_id: 1, // You should get this from session
        items: cart
      })
    });

    if (res.ok) {
      const data = await res.json();
      window.location.href = `${contextPath}/confirmation?orderId=${data.id}`;
    } else {
      showNotification('Checkout failed. Please try again.', 'error');
    }
  } catch (error) {
    showNotification('Checkout error. Please try again.', 'error');
    console.error('Checkout error:', error);
  }
}

// UI wiring
function wireCartSidebar() {
  cartToggle.addEventListener('click', () => cartSidebar.classList.add('active'));
  closeCart.addEventListener('click', () => cartSidebar.classList.remove('active'));
  document.addEventListener('click', (e) => {
    if (!cartSidebar.contains(e.target) && !cartToggle.contains(e.target) && cartSidebar.classList.contains('active')) {
      cartSidebar.classList.remove('active');
    }
  });
  
  checkoutBtn.addEventListener('click', checkout);
}

// Notifications
function showNotification(message, type = 'success') {
  const notification = document.createElement('div');
  notification.style.cssText = `
    position: fixed; top: 20px; right: 20px;
    background: ${type === 'error' ? '#ef4444' : '#10b981'};
    color: white; padding: 12px 24px; border-radius: 8px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.2); z-index: 10000;
    animation: slideIn 0.3s ease; font-weight: 500;
  `;
  notification.textContent = message;
  document.body.appendChild(notification);
  setTimeout(() => {
    notification.style.animation = 'slideOut 0.3s ease';
    setTimeout(() => notification.remove(), 300);
  }, 3000);
}

// Initialize cart on page load
document.addEventListener('DOMContentLoaded', () => {
  updateCart();
  wireCartSidebar();
  
  const style = document.createElement('style');
  style.textContent = `
    @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
    @keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(100%); opacity: 0; } }
  `;
  document.head.appendChild(style);
});