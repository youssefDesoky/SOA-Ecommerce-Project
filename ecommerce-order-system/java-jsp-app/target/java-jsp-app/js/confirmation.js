// Get order data from sessionStorage
let orderData = JSON.parse(sessionStorage.getItem('lastOrder')) || {};

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadOrderConfirmation();
    createConfetti();
    
    // Clear the order data from sessionStorage after loading
    sessionStorage.removeItem('lastOrder');
});

// Load order confirmation
function loadOrderConfirmation() {
    // Order ID comes from server-side (JSP attribute) - already set in HTML
    // Just update the other fields from sessionStorage
    
    // Set customer information from sessionStorage if available
    const customerNameEl = document.getElementById('customerName');
    const customerEmailEl = document.getElementById('customerEmail');
    const customerPhoneEl = document.getElementById('customerPhone');
    const shippingAddressEl = document.getElementById('shippingAddress');
    const paymentMethodEl = document.getElementById('paymentMethod');
    
    if (orderData.customerName) {
        customerNameEl.textContent = orderData.customerName;
    }
    if (orderData.customerEmail) {
        customerEmailEl.textContent = orderData.customerEmail;
    }
    if (orderData.customerPhone) {
        customerPhoneEl.textContent = orderData.customerPhone;
    }
    if (orderData.shippingAddress) {
        shippingAddressEl.textContent = orderData.shippingAddress;
    }
    if (orderData.paymentMethod) {
        paymentMethodEl.textContent = orderData.paymentMethod;
    }
    
    // Set order items
    const orderItemsContainer = document.getElementById('orderItems');
    if (orderData.items && orderData.items.length > 0) {
        orderItemsContainer.innerHTML = orderData.items.map(item => `
            <div class="product-item">
                <img src="${item.image || ''}" alt="${item.name}" class="product-image" 
                     onerror="this.style.display='none'">
                <div class="product-info">
                    <div class="product-name">${item.name}</div>
                    <div class="product-meta">
                        <span>Quantity: ${item.quantity}</span>
                        <span>Price: $${parseFloat(item.price).toFixed(2)} each</span>
                    </div>
                </div>
                <div class="product-price">$${(parseFloat(item.price) * parseInt(item.quantity)).toFixed(2)}</div>
            </div>
        `).join('');
    } else {
        orderItemsContainer.innerHTML = `
            <div style="text-align: center; padding: 20px; color: var(--gray);">
                <i class="fas fa-box-open" style="font-size: 2rem; margin-bottom: 10px; opacity: 0.3;"></i>
                <p>Order placed successfully!</p>
            </div>
        `;
    }
    
    // Calculate pricing using the pricing servlet
    calculateOrderPricing();
}

// Calculate order pricing using the pricing servlet
async function calculateOrderPricing() {
    if (!orderData || !orderData.items || orderData.items.length === 0) return;
    
    console.log

    // Extract region from shipping address (format: "address, city, government")
    // Prefer explicit region saved in the order data; fallback to parsing shippingAddress
    let region = '';
    if (orderData.region && orderData.region.trim()) {
        region = orderData.region.trim();
    } else if (orderData.shippingAddress) {
        const addressParts = orderData.shippingAddress.split(',');
        if (addressParts.length >= 3) {
            region = addressParts[addressParts.length - 1].trim();
        }
    }
    
    // Prepare products data
    const products = orderData.items.map(item => ({
        product_id: parseInt(item.id),
        quantity: parseInt(item.quantity),
        unit_price: parseFloat(item.price)
    }));
    
    try {
        const response = await fetch(`${window.APP_CONTEXT}/pricing/calculate`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                products: products,
                region: region
            })
        });
        
        if (response.ok) {
            const pricingData = await response.json();
            
            // Calculate total discount
            let totalDiscount = 0;
            if (pricingData.items) {
                totalDiscount = pricingData.items.reduce((sum, item) => 
                    sum + (parseFloat(item.total_before_discount) - parseFloat(item.discounted_total)), 0);
            }
            
            // Update the display with pricing data
            document.getElementById('orderSubtotal').textContent = `$${parseFloat(pricingData.subtotal || 0).toFixed(2)}`;
            document.getElementById('orderDiscount').textContent = totalDiscount > 0 ? `-$${totalDiscount.toFixed(2)}` : '$0.00';
            document.getElementById('orderTax').textContent = `$${parseFloat(pricingData.tax || 0).toFixed(2)}`;
            document.getElementById('orderTotal').textContent = `$${parseFloat(pricingData.total || 0).toFixed(2)}`;
        } else {
            console.error('Failed to calculate pricing for confirmation');
            // Fallback to sessionStorage data
            if (orderData.subtotal !== undefined) {
                document.getElementById('orderSubtotal').textContent = `$${parseFloat(orderData.subtotal).toFixed(2)}`;
            }
            if (orderData.discount !== undefined) {
                const discountEl = document.getElementById('orderDiscount');
                const discountValue = parseFloat(orderData.discount);
                discountEl.textContent = discountValue > 0 ? `-$${discountValue.toFixed(2)}` : '$0.00';
            }
            if (orderData.tax !== undefined) {
                document.getElementById('orderTax').textContent = `$${parseFloat(orderData.tax).toFixed(2)}`;
            }
            if (orderData.total !== undefined) {
                document.getElementById('orderTotal').textContent = `$${parseFloat(orderData.total).toFixed(2)}`;
            }
        }
    } catch (error) {
        console.error('Error calculating pricing for confirmation:', error);
        // Fallback to sessionStorage data
        if (orderData.subtotal !== undefined) {
            document.getElementById('orderSubtotal').textContent = `$${parseFloat(orderData.subtotal).toFixed(2)}`;
        }
        if (orderData.discount !== undefined) {
            const discountEl = document.getElementById('orderDiscount');
            const discountValue = parseFloat(orderData.discount);
            discountEl.textContent = discountValue > 0 ? `-$${discountValue.toFixed(2)}` : '$0.00';
        }
        if (orderData.tax !== undefined) {
            document.getElementById('orderTax').textContent = `$${parseFloat(orderData.tax).toFixed(2)}`;
        }
        if (orderData.total !== undefined) {
            document.getElementById('orderTotal').textContent = `$${parseFloat(orderData.total).toFixed(2)}`;
        }
    }
}

// Create confetti animation
function createConfetti() {
    const container = document.querySelector('.confirmation-card');
    const confettiCount = 50;
    
    for (let i = 0; i < confettiCount; i++) {
        const confetti = document.createElement('div');
        confetti.className = 'confetti';
        
        // Random position
        const posX = Math.random() * 100;
        const posY = Math.random() * 100;
        
        // Random animation
        const duration = 1 + Math.random() * 2;
        const delay = Math.random() * 2;
        const rotation = Math.random() * 720;
        
        confetti.style.cssText = `
            left: ${posX}%;
            top: ${posY}%;
            animation: confettiFall ${duration}s ease-out ${delay}s forwards;
            transform: rotate(${rotation}deg);
        `;
        
        container.appendChild(confetti);
        
        // Remove after animation
        setTimeout(() => {
            confetti.remove();
        }, (duration + delay) * 1000);
    }
    
    // Add CSS for confetti animation
    const style = document.createElement('style');
    style.textContent = `
        @keyframes confettiFall {
            0% {
                opacity: 1;
                transform: translateY(-100px) rotate(0deg);
            }
            100% {
                opacity: 0;
                transform: translateY(500px) rotate(360deg);
            }
        }
    `;
    document.head.appendChild(style);
}

// Print confirmation
function printConfirmation() {
    const printContent = `
        <!DOCTYPE html>
        <html>
        <head>
            <title>Order Receipt - Nexus</title>
            <style>
                body { font-family: Arial, sans-serif; padding: 20px; }
                .receipt { max-width: 600px; margin: 0 auto; }
                .header { text-align: center; margin-bottom: 30px; border-bottom: 2px solid #333; padding-bottom: 20px; }
                .logo { font-size: 24px; font-weight: bold; color: #3a36e0; margin-bottom: 10px; }
                .order-number { font-size: 18px; font-weight: bold; margin: 10px 0; }
                .section { margin: 20px 0; }
                .section-title { font-weight: bold; border-bottom: 1px solid #ddd; padding-bottom: 5px; margin-bottom: 10px; }
                .item { display: flex; justify-content: space-between; margin: 5px 0; }
                .total { font-weight: bold; font-size: 18px; border-top: 2px solid #333; padding-top: 10px; margin-top: 20px; }
                .footer { text-align: center; margin-top: 30px; font-size: 12px; color: #666; }
                @media print {
                    body { padding: 0; }
                    .no-print { display: none; }
                }
            </style>
        </head>
        <body>
            <div class="receipt">
                <div class="header">
                    <div class="logo">Nexus</div>
                    <div>Order Receipt</div>
                    <div class="order-number">Order #${orderData.orderId}</div>
                    <div>Date: ${new Date().toLocaleDateString('en-US', { 
                        weekday: 'long', 
                        year: 'numeric', 
                        month: 'long', 
                        day: 'numeric' 
                    })}</div>
                </div>
                
                <div class="section">
                    <div class="section-title">Customer Information</div>
                    <div>${orderData.customerName}</div>
                    <div>${orderData.customerEmail}</div>
                    <div>${orderData.customerPhone}</div>
                </div>
                
                <div class="section">
                    <div class="section-title">Shipping Address</div>
                    <div>${orderData.shippingAddress}</div>
                </div>
                
                <div class="section">
                    <div class="section-title">Items</div>
                    ${orderData.items.map(item => `
                        <div class="item">
                            <span>${item.name} (x${item.quantity})</span>
                            <span>$${(item.price * item.quantity).toFixed(2)}</span>
                        </div>
                    `).join('')}
                </div>
                
                <div class="section">
                    <div class="section-title">Payment Summary</div>
                    <div class="item">
                        <span>Subtotal:</span>
                        <span>$${orderData.subtotal?.toFixed(2) || '0.00'}</span>
                    </div>
                    <div class="item">
                        <span>Shipping:</span>
                        <span>$${orderData.shipping?.toFixed(2) || '9.99'}</span>
                    </div>
                    <div class="item">
                        <span>Tax:</span>
                        <span>$${orderData.tax?.toFixed(2) || '0.00'}</span>
                    </div>
                    <div class="item total">
                        <span>Total:</span>
                        <span>$${orderData.total?.toFixed(2) || '0.00'}</span>
                    </div>
                </div>
                
                <div class="section">
                    <div class="section-title">Payment Method</div>
                    <div>${orderData.paymentMethod}</div>
                </div>
                
                <div class="footer">
                    <div>Thank you for shopping with Nexus!</div>
                    <div>For any inquiries, contact: support@nexus.com</div>
                    <div>Printed on: ${new Date().toLocaleString()}</div>
                </div>
            </div>
        </body>
        </html>
    `;
    
    const printWindow = window.open('', '_blank');
    printWindow.document.write(printContent);
    printWindow.document.close();
    printWindow.focus();
    
    setTimeout(() => {
        printWindow.print();
        printWindow.close();
    }, 250);
}

// Email receipt (simulated)
function emailReceipt() {
    alert('Receipt has been sent to your email address!');
}

// Try to get order data from URL parameters (for backward compatibility)
function getOrderFromURL() {
    const urlParams = new URLSearchParams(window.location.search);
    const orderId = urlParams.get('orderId');
    
    if (orderId && !orderData.orderId.includes(orderId)) {
        orderData.orderId = orderId;
        loadOrderConfirmation();
    }
}

// Initialize with URL data if available
getOrderFromURL();