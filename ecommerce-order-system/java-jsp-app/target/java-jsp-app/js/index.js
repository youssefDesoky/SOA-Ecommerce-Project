const contextPath = window.APP_CONTEXT || '';
let cart = JSON.parse(localStorage.getItem('nexusCart')) || [];
let isUpdatingCart = false;

// DOM Elements - initialized after DOM loads
let productsContainer, cartSidebar, cartToggle, closeCart, cartItems, cartCount, cartTotal, checkoutBtn;

function initDOMElements() {
  productsContainer = document.getElementById('products-container');
  cartSidebar = document.getElementById('cart-sidebar');
  cartToggle = document.getElementById('cart-toggle');
  closeCart = document.getElementById('close-cart');
  cartItems = document.getElementById('cart-items');
  cartCount = document.getElementById('cart-count');
  cartTotal = document.getElementById('cart-total');
  checkoutBtn = document.getElementById('checkout-btn');
}

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
  isUpdatingCart = true;
  cart = cart.filter(item => item.id !== productId);
  updateCart();
  showNotification('Item removed from cart');
  setTimeout(() => isUpdatingCart = false, 0);
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
            <button class="quantity-btn" onclick="event.stopPropagation(); updateQuantity('${item.id}', ${item.quantity - 1})">-</button>
            <span class="quantity">${item.quantity}</span>
            <button class="quantity-btn" onclick="event.stopPropagation(); updateQuantity('${item.id}', ${item.quantity + 1})">+</button>
            <button class="remove-item" onclick="event.stopPropagation(); removeFromCart('${item.id}')"><i class="fas fa-trash"></i></button>
          </div>
        </div>
      </div>
    `).join('');
  }

  const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  cartTotal.textContent = `$${total.toFixed(2)}`;
}

function updateQuantity(productId, newQuantity) {
  isUpdatingCart = true;
  if (newQuantity < 1) {
    removeFromCart(productId);
    setTimeout(() => isUpdatingCart = false, 0);
    return;
  }
  const item = cart.find(item => item.id === productId);
  if (item) {
    item.quantity = newQuantity;
    updateCart();
  }
  setTimeout(() => isUpdatingCart = false, 0);
}

function checkout() {
  if (cart.length === 0) {
    showNotification('Your cart is empty!', 'error');
    return;
  }
  // Redirect to checkout page - cart data is already in localStorage
  window.location.href = `${contextPath}/checkout`;
}

// UI wiring
function wireCartSidebar() {
  cartToggle.addEventListener('click', (e) => {
    e.stopPropagation();
    cartSidebar.classList.add('active');
  });
  
  closeCart.addEventListener('click', (e) => {
    e.stopPropagation();
    cartSidebar.classList.remove('active');
  });
  
  // Prevent clicks inside cart sidebar from closing it
  cartSidebar.addEventListener('click', (e) => {
    e.stopPropagation();
  });
  
  // Close cart when clicking outside
  document.addEventListener('click', (e) => {
    if (cartSidebar.classList.contains('active') && 
        !cartSidebar.contains(e.target) && 
        !cartToggle.contains(e.target) &&
        !isUpdatingCart) {
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
  initDOMElements();
  updateCart();
  wireCartSidebar();
  wireAddToCartButtons();
  
  const style = document.createElement('style');
  style.textContent = `
    @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
    @keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(100%); opacity: 0; } }
  `;
  document.head.appendChild(style);
});