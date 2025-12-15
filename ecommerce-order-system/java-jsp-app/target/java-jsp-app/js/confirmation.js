// Sample order data (in a real app, this would come from your backend)
const sampleOrder = {
    orderId: '<%= request.getParameter("orderId") != null ? request.getParameter("orderId") : "ORD-" + new java.util.Date().getTime().toString().slice(-8) %>',
    customerName: "Mohamed Salah",
    customerEmail: "mohamed.salah@example.com",
    customerPhone: "+201234567890",
    shippingAddress: "123 Main Street, Nasr City, Cairo, Egypt",
    paymentMethod: "Cash on Delivery",
    items: [
        {
            id: 1,
            name: "Quantum X1 Laptop",
            price: 1299.99,
            quantity: 1,
            image: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&auto=format&fit=crop"
        },
        {
            id: 2,
            name: "Nova 5 Wireless Earbuds",
            price: 199.99,
            quantity: 2,
            image: "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=500&auto=format&fit=crop"
        }
    ],
    subtotal: 1699.97,
    shipping: 9.99,
    tax: 237.99,
    total: 1947.95
};

// Get order data from sessionStorage or use sample data
let orderData = JSON.parse(sessionStorage.getItem('lastOrder')) || sampleOrder;

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadOrderConfirmation();
    createConfetti();
});

// Load order confirmation
function loadOrderConfirmation() {
    // Set order ID
    document.getElementById('orderId').textContent = orderData.orderId;
    
    // Set customer information
    document.getElementById('customerName').textContent = orderData.customerName;
    document.getElementById('customerEmail').textContent = orderData.customerEmail;
    document.getElementById('customerPhone').textContent = orderData.customerPhone;
    document.getElementById('shippingAddress').textContent = orderData.shippingAddress;
    document.getElementById('paymentMethod').textContent = orderData.paymentMethod;
    
    // Set order items
    const orderItemsContainer = document.getElementById('orderItems');
    if (orderData.items && orderData.items.length > 0) {
        orderItemsContainer.innerHTML = orderData.items.map(item => `
            <div class="product-item">
                <img src="${item.image}" alt="${item.name}" class="product-image">
                <div class="product-info">
                    <div class="product-name">${item.name}</div>
                    <div class="product-meta">
                        <span>Quantity: ${item.quantity}</span>
                        <span>Price: $${item.price.toFixed(2)} each</span>
                    </div>
                </div>
                <div class="product-price">$${(item.price * item.quantity).toFixed(2)}</div>
            </div>
        `).join('');
    } else {
        orderItemsContainer.innerHTML = `
            <div style="text-align: center; padding: 20px; color: var(--gray);">
                <i class="fas fa-box-open" style="font-size: 2rem; margin-bottom: 10px; opacity: 0.3;"></i>
                <p>No items in this order</p>
            </div>
        `;
    }
    
    // Set order totals
    document.getElementById('orderSubtotal').textContent = `$${orderData.subtotal?.toFixed(2) || '0.00'}`;
    document.getElementById('orderShipping').textContent = `$${orderData.shipping?.toFixed(2) || '9.99'}`;
    document.getElementById('orderTax').textContent = `$${orderData.tax?.toFixed(2) || '0.00'}`;
    document.getElementById('orderTotal').textContent = `$${orderData.total?.toFixed(2) || '0.00'}`;
    
    // Clear cart
    sessionStorage.removeItem('nexusCart');
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