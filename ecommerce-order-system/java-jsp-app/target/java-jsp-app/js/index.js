const contextPath = window.APP_CONTEXT || '';
let cart = []; // memory only (resets on refresh)
let isUpdatingCart = false;

// DOM elements
let cartSidebar, cartToggle, closeCart, cartItems, cartCount, cartTotal, checkoutBtn;
let checkoutPostForm, checkoutCartDataInput;

function initDOMElements() {
  cartSidebar = document.getElementById('cart-sidebar');
  cartToggle = document.getElementById('cart-toggle');
  closeCart = document.getElementById('close-cart');
  cartItems = document.getElementById('cart-items');
  cartCount = document.getElementById('cart-count');
  cartTotal = document.getElementById('cart-total');
  checkoutBtn = document.getElementById('checkout-btn');

  checkoutPostForm = document.getElementById('checkout-post-form');
  checkoutCartDataInput = document.getElementById('checkout-cart-data');
}

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

function addToCart(productId, productName, price, image) {
  const existing = cart.find(i => i.id === productId);
  if (existing) {
    existing.quantity += 1;
  } else {
    cart.push({ id: productId, name: productName, price, image, quantity: 1 });
  }
  updateCart();
  showNotification(productName + ' added to cart!');
}

function removeFromCart(productId) {
  isUpdatingCart = true;
  cart = cart.filter(i => i.id !== productId);
  updateCart();
  showNotification('Item removed from cart');
  setTimeout(() => { isUpdatingCart = false; }, 0);
}

function updateQuantity(productId, newQuantity) {
  isUpdatingCart = true;

  if (newQuantity < 1) {
    removeFromCart(productId);
    setTimeout(() => { isUpdatingCart = false; }, 0);
    return;
  }

  const item = cart.find(i => i.id === productId);
  if (item) {
    item.quantity = newQuantity;
    updateCart();
  }

  setTimeout(() => { isUpdatingCart = false; }, 0);
}

function updateCart() {
  const totalItems = cart.reduce((s, i) => s + i.quantity, 0);
  cartCount.textContent = totalItems;
  cartCount.style.display = totalItems > 0 ? 'flex' : 'none';

  if (cart.length === 0) {
    cartItems.innerHTML =
      '<div class="cart-empty">' +
      '  <i class="fas fa-shopping-bag"></i>' +
      '  <h3>Your cart is empty</h3>' +
      '  <p>Add some products to get started</p>' +
      '</div>';
  } else {
    cartItems.innerHTML = cart.map(item => {
      return (
        '<div class="cart-item">' +
        '  <img src="' + item.image + '" alt="' + item.name + '" class="cart-item-image">' +
        '  <div class="cart-item-details">' +
        '    <div class="cart-item-name">' + item.name + '</div>' +
        '    <div class="cart-item-price">$' + (item.price * item.quantity).toFixed(2) + '</div>' +
        '    <div class="cart-item-quantity">' +
        '      <button class="quantity-btn" onclick="event.stopPropagation(); updateQuantity(\'' + item.id + '\',' + (item.quantity - 1) + ')">-</button>' +
        '      <span class="quantity">' + item.quantity + '</span>' +
        '      <button class="quantity-btn" onclick="event.stopPropagation(); updateQuantity(\'' + item.id + '\',' + (item.quantity + 1) + ')">+</button>' +
        '      <button class="remove-item" onclick="event.stopPropagation(); removeFromCart(\'' + item.id + '\')">' +
        '        <i class="fas fa-trash"></i>' +
        '      </button>' +
        '    </div>' +
        '  </div>' +
        '</div>'
      );
    }).join('');
  }

  const total = cart.reduce((s, i) => s + (i.price * i.quantity), 0);
  cartTotal.textContent = '$' + total.toFixed(2);
}

function checkout() {
  if (cart.length === 0) {
    showNotification('Your cart is empty!', 'error');
    return;
  }

  if (!checkoutPostForm || !checkoutCartDataInput) {
    alert('Checkout form not found on page.');
    return;
  }

  const payload = cart.map(i => ({
    product_id: parseInt(i.id, 10),
    quantity: parseInt(i.quantity, 10)
  }));

  checkoutCartDataInput.value = JSON.stringify(payload);
  checkoutPostForm.submit();
}

function wireCartSidebar() {
  cartToggle.addEventListener('click', (e) => {
    e.stopPropagation();
    cartSidebar.classList.add('active');
  });

  closeCart.addEventListener('click', (e) => {
    e.stopPropagation();
    cartSidebar.classList.remove('active');
  });

  cartSidebar.addEventListener('click', (e) => e.stopPropagation());

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

function showNotification(message, type = 'success') {
  const notification = document.createElement('div');
  notification.style.cssText =
    'position: fixed; top: 20px; right: 20px;' +
    'background: ' + (type === 'error' ? '#ef4444' : '#10b981') + ';' +
    'color: white; padding: 12px 24px; border-radius: 8px;' +
    'box-shadow: 0 5px 15px rgba(0,0,0,0.2); z-index: 10000;' +
    'animation: slideIn 0.3s ease; font-weight: 500;';
  notification.textContent = message;
  document.body.appendChild(notification);

  setTimeout(() => {
    notification.style.animation = 'slideOut 0.3s ease';
    setTimeout(() => notification.remove(), 300);
  }, 3000);
}

// expose for inline onclick
window.updateQuantity = updateQuantity;
window.removeFromCart = removeFromCart;

document.addEventListener('DOMContentLoaded', () => {
  initDOMElements();
  updateCart();
  wireCartSidebar();
  wireAddToCartButtons();

  const style = document.createElement('style');
  style.textContent =
    '@keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }' +
    '@keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(100%); opacity: 0; } }';
  document.head.appendChild(style);
});
