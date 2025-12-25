<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Profile | Nexus</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #3a36e0;
            --primary-dark: #2a27c9;
            --secondary: #ff6b82;
            --dark: #0f172a;
            --light: #f8fafc;
            --gray: #64748b;
            --gray-light: #e2e8f0;
            --success: #10b981;
            --warning: #f59e0b;
            --error: #ef4444;
            --radius: 12px;
            --shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        /* Header */
        .header {
            background: white;
            border-radius: var(--radius);
            padding: 20px 30px;
            margin-bottom: 30px;
            box-shadow: var(--shadow);
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
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 800;
            font-size: 20px;
        }

        .logo-text {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 28px;
            font-weight: 800;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .nav-links {
            display: flex;
            gap: 20px;
        }

        .nav-link {
            padding: 10px 20px;
            background: var(--light);
            border-radius: var(--radius);
            text-decoration: none;
            color: var(--dark);
            font-weight: 500;
            transition: all 0.3s;
        }

        .nav-link:hover {
            background: var(--primary);
            color: white;
        }

        /* Search Section */
        .search-section {
            background: white;
            border-radius: var(--radius);
            padding: 40px;
            margin-bottom: 30px;
            box-shadow: var(--shadow);
            text-align: center;
        }

        .search-title {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 2rem;
            font-weight: 700;
            color: var(--dark);
            margin-bottom: 10px;
        }

        .search-subtitle {
            color: var(--gray);
            margin-bottom: 30px;
        }

        .search-form {
            display: flex;
            gap: 15px;
            max-width: 600px;
            margin: 0 auto;
        }

        .search-input {
            flex: 1;
            padding: 15px 20px;
            border: 2px solid var(--gray-light);
            border-radius: var(--radius);
            font-size: 1rem;
            transition: all 0.3s;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(58, 54, 224, 0.1);
        }

        .btn {
            padding: 15px 30px;
            border: none;
            border-radius: var(--radius);
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(58, 54, 224, 0.3);
        }

        .btn-secondary {
            background: var(--light);
            color: var(--dark);
            border: 2px solid var(--gray-light);
        }

        .btn-secondary:hover {
            border-color: var(--primary);
            color: var(--primary);
        }

        /* Results Section */
        .results-section {
            display: none;
        }

        .results-section.active {
            display: block;
        }

        /* Profile Card */
        .profile-card {
            background: white;
            border-radius: var(--radius);
            padding: 40px;
            margin-bottom: 30px;
            box-shadow: var(--shadow);
        }

        .profile-header {
            display: flex;
            align-items: center;
            gap: 30px;
            margin-bottom: 30px;
            padding-bottom: 30px;
            border-bottom: 2px solid var(--gray-light);
        }

        .profile-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 36px;
            font-weight: 700;
        }

        .profile-info h2 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--dark);
            margin-bottom: 5px;
        }

        .profile-info p {
            color: var(--gray);
            margin-bottom: 15px;
        }

        .profile-badges {
            display: flex;
            gap: 10px;
        }

        .badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .badge-primary {
            background: rgba(58, 54, 224, 0.1);
            color: var(--primary);
        }

        .badge-warning {
            background: rgba(245, 158, 11, 0.1);
            color: var(--warning);
        }

        .profile-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }

        .detail-item {
            background: var(--light);
            padding: 20px;
            border-radius: var(--radius);
        }

        .detail-label {
            font-size: 0.85rem;
            color: var(--gray);
            margin-bottom: 5px;
        }

        .detail-value {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--dark);
        }

        /* Loyalty Points Section */
        .loyalty-section {
            background: linear-gradient(135deg, var(--warning), #f76707);
            border-radius: var(--radius);
            padding: 25px;
            margin-top: 30px;
            color: white;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .loyalty-info h3 {
            font-size: 1.2rem;
            margin-bottom: 5px;
        }

        .loyalty-points {
            font-size: 2.5rem;
            font-weight: 800;
        }

        .loyalty-actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .loyalty-input {
            padding: 10px 15px;
            border: 2px solid rgba(255,255,255,0.3);
            border-radius: var(--radius);
            background: rgba(255,255,255,0.2);
            color: white;
            font-size: 1rem;
            width: 120px;
        }

        .loyalty-input::placeholder {
            color: rgba(255,255,255,0.7);
        }

        .btn-white {
            background: white;
            color: var(--warning);
            padding: 10px 20px;
        }

        .btn-white:hover {
            transform: translateY(-2px);
        }

        /* Orders Section */
        .orders-card {
            background: white;
            border-radius: var(--radius);
            padding: 40px;
            box-shadow: var(--shadow);
        }

        .orders-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .orders-title {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .orders-title i {
            color: var(--primary);
        }

        .orders-table {
            width: 100%;
            border-collapse: collapse;
        }

        .orders-table th {
            text-align: left;
            padding: 15px;
            background: var(--light);
            color: var(--dark);
            font-weight: 600;
            border-bottom: 2px solid var(--gray-light);
        }

        .orders-table td {
            padding: 15px;
            border-bottom: 1px solid var(--gray-light);
        }

        .orders-table tr:hover {
            background: var(--light);
        }

        .order-id {
            font-weight: 600;
            color: var(--primary);
        }

        .order-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .status-pending {
            background: rgba(245, 158, 11, 0.1);
            color: var(--warning);
        }

        .status-completed {
            background: rgba(16, 185, 129, 0.1);
            color: var(--success);
        }

        .status-cancelled {
            background: rgba(239, 68, 68, 0.1);
            color: var(--error);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: var(--gray);
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.3;
        }

        .empty-state h3 {
            font-size: 1.3rem;
            color: var(--dark);
            margin-bottom: 10px;
        }

        /* Loading */
        .loading {
            display: none;
            text-align: center;
            padding: 40px;
        }

        .loading.active {
            display: block;
        }

        .spinner {
            width: 50px;
            height: 50px;
            border: 4px solid var(--gray-light);
            border-top-color: var(--primary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Error Message */
        .error-message {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid var(--error);
            color: var(--error);
            padding: 15px 20px;
            border-radius: var(--radius);
            margin-bottom: 20px;
            display: none;
        }

        .error-message.active {
            display: block;
        }

        /* Success Message */
        .success-message {
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid var(--success);
            color: var(--success);
            padding: 15px 20px;
            border-radius: var(--radius);
            margin-bottom: 20px;
            display: none;
        }

        .success-message.active {
            display: block;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .search-form {
                flex-direction: column;
            }
            
            .profile-header {
                flex-direction: column;
                text-align: center;
            }
            
            .loyalty-section {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }
            
            .orders-table {
                display: block;
                overflow-x: auto;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <header class="header">
            <a href="inventory" class="logo">
                <div class="logo-icon">N</div>
                <span class="logo-text">Nexus</span>
            </a>
            <nav class="nav-links">
                <a href="inventory" class="nav-link"><i class="fas fa-store"></i> Shop</a>
                <a href="customers" class="nav-link active"><i class="fas fa-user"></i> Customers</a>
            </nav>
        </header>

        <!-- Search Section -->
        <section class="search-section">
            <h1 class="search-title"><i class="fas fa-user-circle"></i> Customer Lookup</h1>
            <p class="search-subtitle">Enter customer email to view profile and order history</p>
            
            <div class="search-form">
                <input type="email" id="emailInput" class="search-input" placeholder="Enter customer email address..." required>
                <button type="button" class="btn btn-primary" onclick="lookupCustomer()">
                    <i class="fas fa-search"></i> Display
                </button>
            </div>

            <div id="errorMessage" class="error-message">
                <i class="fas fa-exclamation-circle"></i> <span id="errorText"></span>
            </div>

            <div id="successMessage" class="success-message">
                <i class="fas fa-check-circle"></i> <span id="successText"></span>
            </div>
        </section>

        <!-- Loading -->
        <div id="loading" class="loading">
            <div class="spinner"></div>
            <p>Loading customer data...</p>
        </div>

        <!-- Results Section -->
        <section id="resultsSection" class="results-section">
            <!-- Profile Card -->
            <div class="profile-card">
                <div class="profile-header">
                    <div class="profile-avatar" id="customerAvatar">--</div>
                    <div class="profile-info">
                        <h2 id="customerName">Customer Name</h2>
                        <p id="customerEmail">customer@example.com</p>
                        <div class="profile-badges">
                            <span class="badge badge-primary">
                                <i class="fas fa-user"></i> Customer ID: <span id="customerId">0</span>
                            </span>
                            <span class="badge badge-warning">
                                <i class="fas fa-calendar"></i> Member since: <span id="customerSince">--</span>
                            </span>
                        </div>
                    </div>
                </div>

                <div class="profile-details">
                    <div class="detail-item">
                        <div class="detail-label"><i class="fas fa-envelope"></i> Email</div>
                        <div class="detail-value" id="detailEmail">--</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label"><i class="fas fa-phone"></i> Phone</div>
                        <div class="detail-value" id="detailPhone">--</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label"><i class="fas fa-shopping-bag"></i> Total Orders</div>
                        <div class="detail-value" id="totalOrders">0</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label"><i class="fas fa-star"></i> Loyalty Points</div>
                        <div class="detail-value" id="detailPoints">0</div>
                    </div>
                </div>

                <!-- Loyalty Points Display Section -->
                <div class="loyalty-section">
                    <div class="loyalty-info">
                        <h3><i class="fas fa-gem"></i> Loyalty Points</h3>
                        <div class="loyalty-points" id="loyaltyPoints">0</div>
                    </div>
                    <div class="loyalty-info" style="text-align: right;">
                        <p style="opacity: 0.9; font-size: 0.9rem;">Earn 1 point for every $10 spent</p>
                        <p style="opacity: 0.7; font-size: 0.85rem;">Points are automatically added when you place an order</p>
                    </div>
                </div>
            </div>

            <!-- Orders Card -->
            <div class="orders-card">
                <div class="orders-header">
                    <h3 class="orders-title">
                        <i class="fas fa-history"></i> Order History
                    </h3>
                    <span id="orderCount" class="badge badge-primary">0 orders</span>
                </div>

                <div id="ordersContainer">
                    <table class="orders-table" id="ordersTable">
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Date</th>
                                <th>Total</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="ordersBody">
                            <!-- Orders will be loaded here -->
                        </tbody>
                    </table>

                    <div id="emptyOrders" class="empty-state" style="display: none;">
                        <i class="fas fa-shopping-bag"></i>
                        <h3>No Orders Found</h3>
                        <p>This customer hasn't placed any orders yet.</p>
                    </div>
                </div>
            </div>
        </section>
    </div>

    <script>
        // Customer Service API URL
        var CUSTOMER_SERVICE_URL = 'http://localhost:5004/api/customers';
        
        // Current customer data
        var currentCustomer = null;

        // Lookup customer by email
        function lookupCustomer() {
            var email = document.getElementById('emailInput').value.trim();
            
            if (!email) {
                showError('Please enter an email address');
                return;
            }
            
            if (!isValidEmail(email)) {
                showError('Please enter a valid email address');
                return;
            }
            
            hideMessages();
            showLoading(true);
            hideResults();
            
            // Call Customer Service API to get customer by email
            fetch(CUSTOMER_SERVICE_URL + '/email/' + encodeURIComponent(email))
                .then(function(response) {
                    if (!response.ok) {
                        if (response.status === 404) {
                            throw new Error('Customer not found with this email');
                        }
                        throw new Error('Failed to fetch customer data');
                    }
                    return response.json();
                })
                .then(function(customer) {
                    currentCustomer = customer;
                    displayCustomerProfile(customer);
                    
                    // Now fetch order history
                    return fetch(CUSTOMER_SERVICE_URL + '/' + customer.customer_id + '/orders');
                })
                .then(function(response) {
                    return response.json();
                })
                .then(function(data) {
                    displayOrderHistory(data.orders || []);
                    showLoading(false);
                    showResults();
                })
                .catch(function(error) {
                    showLoading(false);
                    showError(error.message);
                });
        }

        // Display customer profile
        function displayCustomerProfile(customer) {
            // Get initials for avatar
            var name = customer.name || 'Unknown';
            var initials = name.split(' ').map(function(n) { return n[0]; }).join('').toUpperCase().substring(0, 2);
            
            document.getElementById('customerAvatar').textContent = initials;
            document.getElementById('customerName').textContent = name;
            document.getElementById('customerEmail').textContent = customer.email;
            document.getElementById('customerId').textContent = customer.customer_id;
            document.getElementById('customerSince').textContent = formatDate(customer.created_at);
            
            document.getElementById('detailEmail').textContent = customer.email || '--';
            document.getElementById('detailPhone').textContent = customer.phone || 'Not provided';
            document.getElementById('detailPoints').textContent = (customer.loyalty_points || 0).toLocaleString();
            
            document.getElementById('loyaltyPoints').textContent = (customer.loyalty_points || 0).toLocaleString();
        }

        // Display order history
        function displayOrderHistory(orders) {
            var ordersBody = document.getElementById('ordersBody');
            var emptyOrders = document.getElementById('emptyOrders');
            var ordersTable = document.getElementById('ordersTable');
            
            document.getElementById('totalOrders').textContent = orders.length;
            document.getElementById('orderCount').textContent = orders.length + ' order' + (orders.length !== 1 ? 's' : '');
            
            if (orders.length === 0) {
                ordersTable.style.display = 'none';
                emptyOrders.style.display = 'block';
                return;
            }
            
            ordersTable.style.display = 'table';
            emptyOrders.style.display = 'none';
            
            ordersBody.innerHTML = orders.map(function(order) {
                var statusClass = 'status-pending';
                if (order.status === 'completed' || order.status === 'delivered') {
                    statusClass = 'status-completed';
                } else if (order.status === 'cancelled') {
                    statusClass = 'status-cancelled';
                }
                
                var total = order.total_amount || order.total || 0;
                if (typeof total === 'string') {
                    total = parseFloat(total);
                }
                
                return '<tr>' +
                    '<td class="order-id">#' + order.order_id + '</td>' +
                    '<td>' + formatDate(order.order_date || order.created_at) + '</td>' +
                    '<td>$' + total.toFixed(2) + '</td>' +
                    '<td><span class="order-status ' + statusClass + '">' + 
                        (order.status || 'pending').charAt(0).toUpperCase() + (order.status || 'pending').slice(1) + 
                    '</span></td>' +
                '</tr>';
            }).join('');
        }

        // Helper functions
        function isValidEmail(email) {
            var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(email);
        }

        function formatDate(dateString) {
            if (!dateString) return '--';
            var date = new Date(dateString);
            return date.toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric'
            });
        }

        function showLoading(show) {
            document.getElementById('loading').className = show ? 'loading active' : 'loading';
        }

        function showResults() {
            document.getElementById('resultsSection').className = 'results-section active';
        }

        function hideResults() {
            document.getElementById('resultsSection').className = 'results-section';
        }

        function showError(message) {
            document.getElementById('errorText').textContent = message;
            document.getElementById('errorMessage').className = 'error-message active';
        }

        function showSuccess(message) {
            document.getElementById('successText').textContent = message;
            document.getElementById('successMessage').className = 'success-message active';
        }

        function hideMessages() {
            document.getElementById('errorMessage').className = 'error-message';
            document.getElementById('successMessage').className = 'success-message';
        }

        // Allow Enter key to trigger search
        document.getElementById('emailInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                lookupCustomer();
            }
        });
    </script>
</body>
</html>