let cart = JSON.parse(localStorage.getItem('nexusCart')) || [];
let currentStep = 1;
let customerData = {};

// DOM Elements - declare but don't initialize yet
let cartItemsSummary, subtotalEl, shippingEl, taxEl, totalEl, loadingOverlay, confirmedOrderId;
let step1, step2, step3;
let step1Indicator, step2Indicator, step3Indicator;
let nextStep1Btn, prevStep2Btn, placeOrderBtn;
let paymentMethods, cardDetails, creditCardMethod, cashOnDeliveryMethod;

// Wait for DOM to be ready before executing
document.addEventListener('DOMContentLoaded', function() {
    // Initialize DOM references INSIDE DOMContentLoaded
    cartItemsSummary = document.getElementById('cartItemsSummary');
    subtotalEl = document.getElementById('subtotal');
    shippingEl = document.getElementById('shipping');
    taxEl = document.getElementById('tax');
    totalEl = document.getElementById('total');
    loadingOverlay = document.getElementById('loadingOverlay');
    confirmedOrderId = document.getElementById('confirmed-order-id');

    step1 = document.getElementById('step-1');
    step2 = document.getElementById('step-2');
    step3 = document.getElementById('step-3');

    step1Indicator = document.getElementById('step-1-indicator');
    step2Indicator = document.getElementById('step-2-indicator');
    step3Indicator = document.getElementById('step-3-indicator');

    nextStep1Btn = document.getElementById('next-step-1');
    prevStep2Btn = document.getElementById('prev-step-2');
    placeOrderBtn = document.getElementById('place-order-btn');

    paymentMethods = document.querySelectorAll('.payment-method');
    cardDetails = document.getElementById('cardDetails');
    creditCardMethod = document.getElementById('creditCardMethod');
    cashOnDeliveryMethod = document.getElementById('cashOnDeliveryMethod');

    // Initialize everything
    loadOrderSummary();
    setupEventListeners();
});

// Load order summary
function loadOrderSummary() {
    if (cart.length === 0) {
        cartItemsSummary.innerHTML = `
            <div style="text-align: center; padding: 40px 20px; color: var(--gray);">
                <i class="fas fa-shopping-cart" style="font-size: 2rem; margin-bottom: 15px; opacity: 0.3;"></i>
                <p>Your cart is empty</p>
            </div>
        `;
        updateTotals(0);
        return;
    }
    
    // Display cart items
    cartItemsSummary.innerHTML = cart.map(item => `
        <div class="cart-item-summary">
            <div class="item-image" style="background-image: url('${item.image}'); background-size: cover; background-position: center;">
                ${!item.image ? '<i class="fas fa-box" style="color: var(--gray); font-size: 1.5rem; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);"></i>' : ''}
            </div>
            <div class="item-details">
                <div class="item-name">${item.name}</div>
                <div class="item-quantity">Quantity: ${item.quantity}</div>
            </div>
            <div class="item-price">$${(item.price * item.quantity).toFixed(2)}</div>
        </div>
    `).join('');
    
    // Calculate totals
    const subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    updateTotals(subtotal);
}

// Update totals
function updateTotals(subtotal) {
    const shipping = 9.99;
    const tax = subtotal * 0.14; // 14% VAT for Egypt
    const total = subtotal + shipping + tax;
    
    subtotalEl.textContent = `$${subtotal.toFixed(2)}`;
    shippingEl.textContent = `$${shipping.toFixed(2)}`;
    taxEl.textContent = `$${tax.toFixed(2)}`;
    totalEl.textContent = `$${total.toFixed(2)}`;
    
    // Update hidden cart data field for form submission
    const cartDataField = document.getElementById('cartData');
    const customerIdField = document.getElementById('customerId');
    if (cartDataField) {
        cartDataField.value = JSON.stringify(cart.map(item => ({
            product_id: parseInt(item.id),
            quantity: parseInt(item.quantity)
        })));
    }
    if (customerIdField) {
        customerIdField.value = generateCustomerId();
    }
}

// Setup event listeners
function setupEventListeners() {
    // Step 1: Next button
    nextStep1Btn.addEventListener('click', goToStep2);
    
    // Step 2: Back button
    prevStep2Btn.addEventListener('click', goToStep1);
    
    // Form submission handler
    const checkoutForm = document.getElementById('checkoutForm');
    if (checkoutForm) {
        checkoutForm.addEventListener('submit', handleFormSubmit);
    }
    
    // Payment method selection
    paymentMethods.forEach(method => {
        method.addEventListener('click', () => {
            paymentMethods.forEach(m => m.classList.remove('selected'));
            method.classList.add('selected');
            
            const paymentType = method.querySelector('input').value;
            if (paymentType === 'credit_card') {
                cardDetails.classList.add('show');
            } else {
                cardDetails.classList.remove('show');
            }
        });
    });
    
    // Form validation on blur
    const formInputs = document.querySelectorAll('#step-1 .form-input');
    formInputs.forEach(input => {
        input.addEventListener('blur', () => validateStep1Field(input));
        input.addEventListener('input', () => clearError(input.id));
    });
    
    // Card input formatting
    document.getElementById('cardNumber')?.addEventListener('input', formatCardNumber);
    document.getElementById('cardExpiry')?.addEventListener('input', formatExpiryDate);
    
    // Set default payment method to Cash on Delivery
    cashOnDeliveryMethod.click();
}

// Format card number with spaces
function formatCardNumber(e) {
    let value = e.target.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
    let formatted = '';
    
    for (let i = 0; i < value.length; i++) {
        if (i > 0 && i % 4 === 0) {
            formatted += ' ';
        }
        formatted += value[i];
    }
    
    e.target.value = formatted.substring(0, 19);
}

// Format expiry date
function formatExpiryDate(e) {
    let value = e.target.value.replace(/[^0-9]/g, '');
    
    if (value.length >= 2) {
        value = value.substring(0, 2) + '/' + value.substring(2, 4);
    }
    
    e.target.value = value.substring(0, 5);
}

// Validate Step 1 fields
function validateStep1Field(field) {
    const value = field.value.trim();
    const fieldId = field.id;
    
    clearError(fieldId);
    
    switch(fieldId) {
        case 'firstName':
        case 'lastName':
            if (!value) {
                showError(fieldId, 'This field is required');
                return false;
            }
            if (value.length < 2) {
                showError(fieldId, 'Must be at least 2 characters');
                return false;
            }
            break;
            
        case 'email':
            if (!value) {
                showError(fieldId, 'Email is required');
                return false;
            }
            if (!isValidEmail(value)) {
                showError(fieldId, 'Please enter a valid email address');
                return false;
            }
            break;
            
        case 'phone':
            if (!value) {
                showError(fieldId, 'Phone number is required');
                return false;
            }
            if (!isValidEgyptPhone(value)) {
                showError(fieldId, 'Please enter a valid Egyptian phone number (+20XXXXXXXXXX)');
                return false;
            }
            break;
            
        case 'government':
            if (!value) {
                showError(fieldId, 'Please select your government');
                return false;
            }
            break;
            
        case 'city':
            if (!value) {
                showError(fieldId, 'City is required');
                return false;
            }
            if (value.length < 2) {
                showError(fieldId, 'Must be at least 2 characters');
                return false;
            }
            break;
            
        case 'address':
            if (!value) {
                showError(fieldId, 'Address is required');
                return false;
            }
            if (value.length < 10) {
                showError(fieldId, 'Please provide a complete address');
                return false;
            }
            break;
    }
    
    return true;
}

// Validate entire Step 1
function validateStep1() {
    let isValid = true;
    
    const fields = ['firstName', 'lastName', 'email', 'phone', 'government', 'city', 'address'];
    fields.forEach(fieldId => {
        const field = document.getElementById(fieldId);
        if (!validateStep1Field(field)) {
            isValid = false;
        }
    });
    
    return isValid;
}

// Show error message
function showError(fieldId, message) {
    const errorEl = document.getElementById(fieldId + 'Error');
    if (errorEl) {
        errorEl.textContent = message;
        errorEl.classList.add('show');
        document.getElementById(fieldId).classList.add('error');
    }
}

// Clear error message
function clearError(fieldId) {
    const errorEl = document.getElementById(fieldId + 'Error');
    if (errorEl) {
        errorEl.classList.remove('show');
        document.getElementById(fieldId).classList.remove('error');
    }
}

// Validation helpers
function isValidEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

function isValidEgyptPhone(phone) {
    // Accepts formats: +201234567890, 01234567890, 201234567890
    const re = /^(\+20|0)?1[0-9]{9}$/;
    return re.test(phone.replace(/\s+/g, ''));
}

function isValidCardNumber(card) {
    const cleaned = card.replace(/\s+/g, '');
    const re = /^[0-9]{16}$/;
    return re.test(cleaned);
}

function isValidExpiry(expiry) {
    const re = /^(0[1-9]|1[0-2])\/([0-9]{2})$/;
    if (!re.test(expiry)) return false;
    
    const [month, year] = expiry.split('/');
    const now = new Date();
    const currentYear = now.getFullYear() % 100;
    const currentMonth = now.getMonth() + 1;
    
    return (parseInt(year) > currentYear) || 
            (parseInt(year) === currentYear && parseInt(month) >= currentMonth);
}

function isValidCVV(cvv) {
    const re = /^[0-9]{3,4}$/;
    return re.test(cvv);
}

// Navigate to Step 2
function goToStep2() {
    if (!validateStep1()) {
        alert('Please fix the errors in the form before proceeding.');
        return;
    }
    
    // Save customer data
    customerData = {
        firstName: document.getElementById('firstName').value.trim(),
        lastName: document.getElementById('lastName').value.trim(),
        email: document.getElementById('email').value.trim(),
        phone: document.getElementById('phone').value.trim(),
        government: document.getElementById('government').value,
        city: document.getElementById('city').value.trim(),
        address: document.getElementById('address').value.trim()
    };
    
    // Update UI
    step1.classList.remove('active');
    step2.classList.add('active');
    
    step1Indicator.classList.remove('active');
    step1Indicator.classList.add('completed');
    step2Indicator.classList.add('active');
    
    currentStep = 2;
}

// Navigate back to Step 1
function goToStep1() {
    step2.classList.remove('active');
    step1.classList.add('active');
    
    step2Indicator.classList.remove('active');
    step1Indicator.classList.add('active');
    
    currentStep = 1;
}

// Validate Step 2 (Payment)
function validateStep2() {
    let isValid = true;
    
    // Validate terms
    if (!document.getElementById('terms').checked) {
        showError('terms', 'You must agree to the terms and conditions');
        isValid = false;
    } else {
        clearError('terms');
    }
    
    // Validate payment method
    const paymentMethod = document.querySelector('input[name="payment_method"]:checked').value;
    
    if (paymentMethod === 'credit_card') {
        const cardFields = ['cardNumber', 'cardName', 'cardExpiry', 'cardCvv'];
        cardFields.forEach(fieldId => {
            const field = document.getElementById(fieldId);
            const value = field.value.trim();
            
            if (!value) {
                showError(fieldId, 'This field is required');
                isValid = false;
            } else {
                // Additional validations
                if (fieldId === 'cardNumber' && !isValidCardNumber(value)) {
                    showError(fieldId, 'Please enter a valid 16-digit card number');
                    isValid = false;
                }
                
                if (fieldId === 'cardExpiry' && !isValidExpiry(value)) {
                    showError(fieldId, 'Please enter a valid expiry date (MM/YY)');
                    isValid = false;
                }
                
                if (fieldId === 'cardCvv' && !isValidCVV(value)) {
                    showError(fieldId, 'Please enter a valid CVV (3-4 digits)');
                    isValid = false;
                }
            }
        });
    }
    
    return isValid;
}

// Handle form submission
function handleFormSubmit(e) {
    if (!validateStep2()) {
        e.preventDefault();
        alert('Please fix the errors before placing your order.');
        return false;
    }
    
    // Update hidden fields with latest cart data before submission
    const cartDataField = document.getElementById('cartData');
    const customerIdField = document.getElementById('customerId');
    
    if (cartDataField) {
        cartDataField.value = JSON.stringify(cart.map(item => ({
            product_id: parseInt(item.id),
            quantity: parseInt(item.quantity)
        })));
    }
    if (customerIdField) {
        customerIdField.value = generateCustomerId();
    }
    
    // Show loading overlay
    loadingOverlay.classList.add('active');
    
    // Clear cart from localStorage (form will submit and redirect)
    localStorage.removeItem('nexusCart');
    
    // Allow form to submit naturally
    return true;
}

// Show success step
function showSuccessStep(orderId) {
    step2.classList.remove('active');
    step3.classList.add('active');
    
    step2Indicator.classList.remove('active');
    step2Indicator.classList.add('completed');
    step3Indicator.classList.add('active');
    
    confirmedOrderId.textContent = orderId;
    currentStep = 3;
}

// Generate a customer ID (in a real app, this would come from authentication)
function generateCustomerId() {
    return Math.floor(1000 + Math.random() * 9000);
}