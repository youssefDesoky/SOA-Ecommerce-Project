const contextPath = window.APP_CONTEXT || '';
let cart = []; // memory only (resets on refresh)
let isUpdatingCart = false;

// DOM elements
let cartSidebar, cartToggle, closeCart, cartItems, cartCount, cartTotal, checkoutBtn;
let checkoutPostForm, checkoutCartDataInput;

const initDOMElements = () => {
  cartSidebar = document.getElementById('cart-sidebar');
  cartToggle = document.getElementById('cart-toggle');
  closeCart = document.getElementById('close-cart');
  cartItems = document.getElementById('cart-items');
  cartCount = document.getElementById('cart-count');
  cartTotal = document.getElementById('cart-total');
  checkoutBtn = document.getElementById('checkout-btn');

  checkoutPostForm = document.getElementById('checkout-post-form');
  checkoutCartDataInput = document.getElementById('checkout-cart-data');
};

const wireAddToCartButtons = () => {
  document.querySelectorAll('.product-card .add-to-cart').forEach((btn) => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();

      const id = btn.dataset.id;
      const name = btn.dataset.name;
      const price = Number(btn.dataset.price);
      const image = btn.dataset.image;

      addToCart(id, name, price, image);
    });
  });
};

const addToCart = (productId, productName, price, image) => {
  const existing = cart.find((i) => i.id === productId);

  if (existing) {
    existing.quantity += 1;
  } else {
    cart.push({ id: productId, name: productName, price, image, quantity: 1 });
  }

  updateCart();
};

const removeFromCart = (productId) => {
  isUpdatingCart = true;
  cart = cart.filter((i) => i.id !== productId);
  updateCart();
  setTimeout(() => { isUpdatingCart = false; }, 0);
};

const updateQuantity = (productId, newQuantity) => {
  isUpdatingCart = true;

  if (newQuantity < 1) {
    removeFromCart(productId);
    setTimeout(() => { isUpdatingCart = false; }, 0);
    return;
  }

  const item = cart.find((i) => i.id === productId);
  if (item) {
    item.quantity = newQuantity;
    updateCart();
  }

  setTimeout(() => { isUpdatingCart = false; }, 0);
};

const updateCart = () => {
  const totalItems = cart.reduce((sum, i) => sum + i.quantity, 0);
  cartCount.textContent = String(totalItems);
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
    cartItems.innerHTML = cart.map((item) => `
      <div class="cart-item" data-id="${item.id}">
        <img src="${item.image}" alt="${escapeHtml(item.name)}" class="cart-item-image">
        <div class="cart-item-details">
          <div class="cart-item-name">${escapeHtml(item.name)}</div>
          <div class="cart-item-price">$${(item.price * item.quantity).toFixed(2)}</div>

          <div class="cart-item-quantity">
            <button class="quantity-btn" type="button" data-action="dec">-</button>
            <span class="quantity">${item.quantity}</span>
            <button class="quantity-btn" type="button" data-action="inc">+</button>
            <button class="remove-item" type="button" data-action="remove">
              <i class="fas fa-trash"></i>
            </button>
          </div>
        </div>
      </div>
    `).join('');
  }

  const total = cart.reduce((sum, i) => sum + (i.price * i.quantity), 0);
  cartTotal.textContent = `$${total.toFixed(2)}`;
};

const wireCartItemActions = () => {
  cartItems.addEventListener('click', (e) => {
    const btn = e.target.closest('button[data-action]');
    if (!btn) return;

    const row = e.target.closest('.cart-item');
    if (!row) return;

    const id = row.dataset.id;
    const item = cart.find((i) => i.id === id);
    if (!item) return;

    const action = btn.dataset.action;

    if (action === 'inc') updateQuantity(id, item.quantity + 1);
    if (action === 'dec') updateQuantity(id, item.quantity - 1);
    if (action === 'remove') removeFromCart(id);
  });
};

const checkout = () => {
  if (cart.length === 0) {
    // notification removed -> just silently stop
    return;
  }

  if (!checkoutPostForm || !checkoutCartDataInput) {
    alert('Checkout form not found on page.');
    return;
  }

  const payload = cart.map((i) => ({
    product_id: parseInt(i.id, 10),
    quantity: parseInt(i.quantity, 10),
  }));

  checkoutCartDataInput.value = JSON.stringify(payload);
  checkoutPostForm.submit();
};

const wireCartSidebar = () => {
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
    if (
      cartSidebar.classList.contains('active') &&
      !cartSidebar.contains(e.target) &&
      !cartToggle.contains(e.target) &&
      !isUpdatingCart
    ) {
      cartSidebar.classList.remove('active');
    }
  });

  checkoutBtn.addEventListener('click', checkout);
};

const escapeHtml = (str) => String(str)
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;')
  .replace(/'/g, '&#039;');

document.addEventListener('DOMContentLoaded', () => {
  initDOMElements();
  updateCart();
  wireCartSidebar();
  wireAddToCartButtons();
  wireCartItemActions();
});
