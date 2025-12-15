const contextPath = window.APP_CONTEXT || '';
let cart = JSON.parse(localStorage.getItem('nexusCart')) || [];
let products = [];

// DOM Elements
const productsContainer = document.getElementById('products-container');
const cartSidebar = document.getElementById('cart-sidebar');
const cartToggle = document.getElementById('cart-toggle');
const closeCart = document.getElementById('close-cart');
const cartItems = document.getElementById('cart-items');
const cartCount = document.getElementById('cart-count');
const cartTotal = document.getElementById('cart-total');
const checkoutBtn = document.getElementById('checkout-btn');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
  // Parse products from server-rendered cards
  products = Array.from(document.querySelectorAll('.product-card')).map(card => {
    const name = card.querySelector('.product-name')?.textContent?.trim() || 'Product';
    const priceText = card.querySelector('.product-price')?.textContent?.replace('$', '') || '0';
    const price = Number(priceText) || 0;
    const image = card.querySelector('.product-image')?.getAttribute('src') || '';
    const category = card.querySelector('.product-category')?.textContent?.trim() || '';
    const form = card.querySelector('form[action$="/api/orders/create"]');
    const productId = form?.querySelector('input[name="product_id"]')?.value || null;

    return {
      id: Number(productId) || productId,
      product_id: Number(productId) || productId,
      product_name: name,
      name,
      price,
      image,
      category,
      stock_quantity: parseInt(card.querySelector('.product-stock')?.textContent) || 0
    };
  });

  wireAddToCartButtons();
  updateCart();
  wireSearch();
  wireCartSidebar();
});

// Hook up "Add to Cart" buttons rendered by JSP forms
function wireAddToCartButtons() {
  document.querySelectorAll('.product-card .add-to-cart').forEach((btn, idx) => {
    btn.addEventListener('click', (e) => {
      e.preventDefault(); // prevent form POST; we use client cart
      const p = products[idx];
      if (!p) return;
      addToCart(p.id ?? p.product_id, p.name ?? p.product_name, p.price, p.image);
    });
  });
}

// Display products (client-side filter re-renders simple cards)
function displayProducts(productsToShow) {
  productsContainer.innerHTML = productsToShow.map(product => {
    const name = product.product_name || product.name || 'Product';
    const price = Number(product.price || 0);
    const image = product.image || 'https://images.unsplash.com/photo-1505740420928-5e560c06b30e?w=500&auto=format&fit=crop';
    const stock = product.stock_quantity ?? product.stock ?? 0;
    const category = product.category || 'Electronics';
    const id = product.product_id || product.id;
    const badge = stock === 0 ? `<div class="product-badge">Out of Stock</div>` : (stock < 5 ? `<div class="product-badge">Only ${stock} left!</div>` : '');

    return `
      <div class="product-card">
        ${badge}
        <img src="${image}" alt="${name}" class="product-image">
        <div class="product-info">
          <div class="product-category">${category}</div>
          <h3 class="product-name">${name}</h3>
          <div class="product-footer">
            <div>
              <div class="product-price">$${price.toFixed(2)}</div>
              <div class="product-stock"><i class="fas fa-check-circle"></i> ${stock} in stock</div>
            </div>
          </div>
          <button class="add-to-cart" data-id="${id}" data-name="${name.replace(/'/g, "\\'")}" data-price="${price}" data-image="${image}">
            <i class="fas fa-shopping-cart"></i> Add to Cart
          </button>
        </div>
      </div>
    `;
  }).join('');

  // Bind buttons for newly rendered cards
  document.querySelectorAll('.add-to-cart').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const id = Number(btn.dataset.id) || btn.dataset.id;
      const name = btn.dataset.name;
      const price = Number(btn.dataset.price);
      const image = btn.dataset.image;
      addToCart(id, name, price, image);
    });
  });
}

// Cart functions (unchanged)
function addToCart(productId, productName, price, image) {
  const existingItem = cart.find(item => item.id === productId);
  if (existingItem) {
    existingItem.quantity += 1;
  } else {
    cart.push({ id: productId, name: productName, price, image, quantity: 1 });
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
            <button class="quantity-btn" onclick="updateQuantity(${item.id}, ${item.quantity - 1})">-</button>
            <span class="quantity">${item.quantity}</span>
            <button class="quantity-btn" onclick="updateQuantity(${item.id}, ${item.quantity + 1})">+</button>
            <button class="remove-item" onclick="removeFromCart(${item.id})"><i class="fas fa-trash"></i></button>
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

function checkout() {
  if (cart.length === 0) return showNotification('Your cart is empty!', 'error');
  sessionStorage.setItem('cart', JSON.stringify(cart));
  window.location.href = `${contextPath}/checkout.jsp`;
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
}

function wireSearch() {
  const searchInput = document.querySelector('.search-input');
  if (!searchInput) return;
  searchInput.addEventListener('input', (e) => {
    const term = e.target.value.toLowerCase();
    if (term.length === 0) return displayProducts(products);
    const filtered = products.filter(p =>
      (p.product_name || p.name).toLowerCase().includes(term) ||
      (p.description || '').toLowerCase().includes(term) ||
      (p.category || '').toLowerCase().includes(term)
    );
    displayProducts(filtered);
  });
}

// Notifications (unchanged)
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

const style = document.createElement('style');
style.textContent = `
  @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
  @keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(100%); opacity: 0; } }
`;
document.head.appendChild(style);