<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Account | Nexus</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
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
            --error: #ef4444;
            --radius: 12px;
            --shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
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
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
        }

        /* Header */
        .header {
            background: white;
            box-shadow: 0 2px 15px rgba(0, 0, 0, 0.05);
            padding: 15px 0;
            position: sticky;
            top: 0;
            z-index: 100;
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

        .nav-links {
            display: flex;
            gap: 30px;
            align-items: center;
        }

        .nav-link {
            text-decoration: none;
            color: var(--dark);
            font-weight: 500;
            padding: 8px 0;
            position: relative;
            transition: var(--transition);
        }

        .nav-link:hover {
            color: var(--primary);
        }

        .nav-link.active::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 2px;
            background: var(--primary);
            border-radius: 2px;
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .cart-btn, .profile-btn {
            position: relative;
            background: none;
            border: none;
            font-size: 20px;
            color: var(--dark);
            cursor: pointer;
            padding: 8px;
            transition: var(--transition);
        }

        .cart-btn:hover, .profile-btn:hover {
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

        /* Profile Layout */
        .profile-layout {
            padding: 40px 0;
            min-height: calc(100vh - 200px);
        }

        /* Profile Header */
        .profile-header {
            background: white;
            border-radius: var(--radius);
            padding: 40px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            gap: 30px;
            margin-bottom: 30px;
        }

        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 48px;
            font-weight: 700;
            border: 5px solid white;
            box-shadow: var(--shadow);
            flex-shrink: 0;
        }

        .profile-info {
            flex: 1;
        }

        .profile-name {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 5px;
            color: var(--dark);
        }

        .profile-email {
            color: var(--gray);
            font-size: 1rem;
            margin-bottom: 15px;
        }

        .profile-badges {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .badge {
            background: var(--light);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .badge.gold {
            color: var(--primary);
        }

        .badge.points {
            color: var(--warning);
        }

        /* Accordion Styles */
        .accordion-container {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .accordion-section {
            background: white;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            overflow: hidden;
            transition: var(--transition);
        }

        .accordion-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 25px 30px;
            cursor: pointer;
            background: white;
            border: none;
            width: 100%;
            text-align: left;
            transition: var(--transition);
            position: relative;
        }

        .accordion-header:hover {
            background: var(--light);
        }

        .accordion-section.active .accordion-header {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: white;
        }

        .accordion-title {
            display: flex;
            align-items: center;
            gap: 15px;
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--dark);
            transition: var(--transition);
        }

        .accordion-section.active .accordion-title {
            color: white;
        }

        .accordion-title i {
            font-size: 1.5rem;
            color: var(--primary);
            transition: var(--transition);
        }

        .accordion-section.active .accordion-title i {
            color: white;
        }

        .accordion-arrow {
            font-size: 1.2rem;
            color: var(--gray);
            transition: transform 0.3s ease, color 0.3s ease;
        }

        .accordion-section.active .accordion-arrow {
            transform: rotate(180deg);
            color: white;
        }

        .accordion-body {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s cubic-bezier(0.4, 0, 0.2, 1), padding 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            padding: 0 30px;
        }

        .accordion-section.active .accordion-body {
            max-height: 5000px;
            padding: 30px;
            padding-top: 0;
        }

        .accordion-content {
            padding-top: 20px;
            animation: fadeInContent 0.4s ease;
        }

        @keyframes fadeInContent {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 768px) {
            .profile-header {
                flex-direction: column;
                text-align: center;
            }
            
            .profile-badges {
                justify-content: center;
            }
            
            .accordion-header {
                padding: 20px;
            }
            
            .accordion-section.active .accordion-body {
                padding: 20px;
                padding-top: 0;
            }
            
            .accordion-title {
                font-size: 1.2rem;
            }
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid var(--gray-light);
        }

        .section-title {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .section-title i {
            color: var(--primary);
        }

        .section-actions {
            display: flex;
            gap: 15px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 24px;
            border-radius: var(--radius);
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            transition: var(--transition);
            border: none;
            text-decoration: none;
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
            background: white;
            border: 2px solid var(--gray-light);
            color: var(--dark);
        }

        .btn-secondary:hover {
            border-color: var(--primary);
            color: var(--primary);
        }

        .btn-sm {
            padding: 8px 16px;
            font-size: 0.85rem;
        }

        /* Dashboard Stats */
        .dashboard-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: var(--light);
            border-radius: var(--radius);
            padding: 25px;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: var(--transition);
            cursor: pointer;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: white;
        }

        .stat-icon.orders {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
        }

        .stat-icon.wishlist {
            background: linear-gradient(135deg, var(--secondary), #ff4757);
        }

        .stat-icon.reviews {
            background: linear-gradient(135deg, var(--success), #0ca678);
        }

        .stat-icon.points {
            background: linear-gradient(135deg, var(--warning), #f76707);
        }

        .stat-info h3 {
            font-size: 2rem;
            font-weight: 800;
            margin-bottom: 5px;
            color: var(--dark);
        }

        .stat-info p {
            color: var(--gray);
            font-size: 0.9rem;
        }

        /* Recent Activity */
        .recent-activity {
            background: var(--light);
            border-radius: var(--radius);
            padding: 30px;
            margin-bottom: 40px;
        }

        .activity-list {
            list-style: none;
            max-height: 300px;
            overflow-y: auto;
        }

        .activity-item {
            display: flex;
            gap: 15px;
            padding: 15px 0;
            border-bottom: 1px solid var(--gray-light);
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .activity-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            flex-shrink: 0;
        }

        .activity-content {
            flex: 1;
        }

        .activity-title {
            font-weight: 600;
            margin-bottom: 5px;
        }

        .activity-time {
            color: var(--gray);
            font-size: 0.85rem;
        }

        /* Form Styles */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--dark);
            font-size: 0.95rem;
        }

        .form-label .required {
            color: var(--error);
            margin-left: 2px;
        }

        .form-input {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid var(--gray-light);
            border-radius: var(--radius);
            font-size: 1rem;
            transition: var(--transition);
            font-family: 'Inter', sans-serif;
        }

        .form-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(58, 54, 224, 0.1);
        }

        .form-input.error {
            border-color: var(--error);
        }

        .error-message {
            color: var(--error);
            font-size: 0.85rem;
            margin-top: 6px;
            display: none;
        }

        .error-message.show {
            display: block;
        }

        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid var(--gray-light);
        }

        /* Orders Table */
        .orders-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
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
            vertical-align: middle;
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
            display: inline-block;
        }

        .order-status.processing {
            background: rgba(245, 158, 11, 0.1);
            color: var(--warning);
        }

        .order-status.shipped {
            background: rgba(59, 130, 246, 0.1);
            color: #3b82f6;
        }

        .order-status.delivered {
            background: rgba(16, 185, 129, 0.1);
            color: var(--success);
        }

        .order-status.cancelled {
            background: rgba(239, 68, 68, 0.1);
            color: var(--error);
        }

        .order-actions {
            display: flex;
            gap: 8px;
        }

        /* Settings Section */
        .settings-section {
            background: var(--light);
            border-radius: var(--radius);
            padding: 25px;
            margin-bottom: 20px;
        }

        .settings-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 15px;
            color: var(--dark);
        }

        .settings-options {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .setting-option {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px;
            background: white;
            border-radius: var(--radius);
            border: 1px solid var(--gray-light);
        }

        .setting-info h4 {
            font-weight: 600;
            margin-bottom: 5px;
        }

        .setting-info p {
            color: var(--gray);
            font-size: 0.9rem;
        }

        .switch {
            position: relative;
            display: inline-block;
            width: 60px;
            height: 30px;
        }

        .switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: var(--gray-light);
            transition: var(--transition);
            border-radius: 34px;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 22px;
            width: 22px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: var(--transition);
            border-radius: 50%;
        }

        input:checked + .slider {
            background-color: var(--primary);
        }

        input:checked + .slider:before {
            transform: translateX(30px);
        }

        /* Empty States */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: var(--gray);
        }

        .empty-state i {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.3;
        }

        .empty-state h3 {
            font-size: 1.2rem;
            margin-bottom: 10px;
            color: var(--dark);
        }

        /* Footer */
        .footer {
            background: var(--dark);
            color: white;
            padding: 40px 0 20px;
            margin-top: 60px;
        }

        .footer-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 30px;
            margin-bottom: 30px;
        }

        .footer-section h3 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 1.2rem;
            margin-bottom: 15px;
            color: white;
        }

        .footer-links {
            list-style: none;
        }

        .footer-links li {
            margin-bottom: 8px;
        }

        .footer-links a {
            color: #cbd5e1;
            text-decoration: none;
            transition: var(--transition);
            font-size: 0.9rem;
        }

        .footer-links a:hover {
            color: white;
            padding-left: 5px;
        }

        .copyright {
            text-align: center;
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            color: #94a3b8;
            font-size: 0.9rem;
        }

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: white;
            border-radius: var(--radius);
            padding: 40px;
            max-width: 500px;
            width: 100%;
            max-height: 90vh;
            overflow-y: auto;
            animation: modalSlideIn 0.3s ease;
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .modal-header {
            margin-bottom: 20px;
        }

        .modal-title {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--dark);
        }

        .modal-body {
            margin-bottom: 30px;
        }

        .modal-footer {
            display: flex;
            gap: 15px;
            justify-content: flex-end;
        }

        .modal-close {
            position: absolute;
            top: 20px;
            right: 20px;
            background: none;
            border: none;
            font-size: 1.5rem;
            color: var(--gray);
            cursor: pointer;
            padding: 5px;
            border-radius: var(--radius);
            transition: var(--transition);
        }

        .modal-close:hover {
            background: var(--gray-light);
            color: var(--dark);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .profile-content {
                padding: 20px;
            }
            
            .dashboard-stats {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .orders-table {
                display: block;
                overflow-x: auto;
            }
            
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .section-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .section-actions {
                width: 100%;
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
            }
            
            .nav-links {
                display: none;
            }
        }

        @media (max-width: 480px) {
            .container {
                padding: 0 15px;
            }
            
            .dashboard-stats {
                grid-template-columns: 1fr;
            }
            
            .stat-card {
                flex-direction: column;
                text-align: center;
            }
            
            .modal-content {
                padding: 20px;
            }
            
            .setting-option {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
        }

        /* Scrollbar Styling */
        .activity-list::-webkit-scrollbar,
        .orders-table::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }

        .activity-list::-webkit-scrollbar-track,
        .orders-table::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 3px;
        }

        .activity-list::-webkit-scrollbar-thumb,
        .orders-table::-webkit-scrollbar-thumb {
            background: var(--primary);
            border-radius: 3px;
        }

        .activity-list::-webkit-scrollbar-thumb:hover,
        .orders-table::-webkit-scrollbar-thumb:hover {
            background: var(--primary-dark);
        }
    </style>
</head>

<body>
    <!-- Header -->
    <header class="header">
        <div class="container">
            <nav class="nav">
                <a href="index.jsp" class="logo">
                    <div class="logo-icon">N</div>
                    <span class="logo-text">Nexus</span>
                </a>
                
                <div class="header-actions">
                    <button class="cart-btn" id="cart-toggle">
                        <i class="fas fa-shopping-bag"></i>
                        <span class="cart-count" id="cart-count">0</span>
                    </button>
                </div>
            </nav>
        </div>
    </header>

    <!-- Profile Layout -->
    <div class="container">
        <div class="profile-layout">
            <!-- Profile Header -->
            <div class="profile-header">
                <div class="profile-avatar" id="userAvatar">MS</div>
                <div class="profile-info">
                    <h2 class="profile-name" id="userName">Mohamed Salah</h2>
                    <p class="profile-email" id="userEmail">mohamed.salah@example.com</p>
                    <div class="profile-badges">
                        <span class="badge gold">
                            <i class="fas fa-crown"></i> Gold Member
                        </span>
                        <span class="badge points">
                            <i class="fas fa-star"></i> 1250 Points
                        </span>
                    </div>
                </div>
            </div>

            <!-- Accordion Container -->
            <div class="accordion-container">
                <!-- Dashboard Section -->
                <div class="accordion-section active" id="dashboard-section">
                    <button class="accordion-header" onclick="toggleAccordion('dashboard-section')">
                        <div class="accordion-title">
                            <i class="fas fa-chart-line"></i>
                            Dashboard
                        </div>
                        <i class="fas fa-chevron-down accordion-arrow"></i>
                    </button>
                    <div class="accordion-body">
                        <div class="accordion-content">
                    <div class="section-header">
                        <h2 class="section-title">
                            <i class="fas fa-chart-line"></i>
                            Dashboard
                        </h2>
                        <div class="section-actions">
                            <button class="btn btn-primary" onclick="window.location.href='index.jsp'">
                                <i class="fas fa-shopping-bag"></i>
                                Continue Shopping
                            </button>
                        </div>
                    </div>
                    
                            <!-- Stats Cards -->
                            <div class="dashboard-stats">
                                <div class="stat-card" onclick="toggleAccordion('orders-section')">
                                    <div class="stat-icon orders">
                                        <i class="fas fa-shopping-bag"></i>
                                    </div>
                                    <div class="stat-info">
                                        <h3>12</h3>
                                        <p>Total Orders</p>
                                    </div>
                                </div>
                                
                                <div class="stat-card">
                                    <div class="stat-icon points">
                                        <i class="fas fa-gem"></i>
                                    </div>
                                    <div class="stat-info">
                                        <h3>1,250</h3>
                                        <p>Loyalty Points</p>
                                    </div>
                                </div>
                            </div>
                    
                            <!-- Recent Orders -->
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                                    <h3 style="font-size: 1.3rem; font-weight: 600;">Recent Orders</h3>
                                    <button class="btn btn-secondary btn-sm" onclick="toggleAccordion('orders-section')">
                                        View All
                                        <i class="fas fa-arrow-right"></i>
                                    </button>
                                </div>
                                
                                <div style="background: var(--light); border-radius: var(--radius); padding: 20px;">
                                    <table style="width: 100%;">
                                        <thead>
                                            <tr>
                                                <th style="padding: 10px; text-align: left;">Order ID</th>
                                                <th style="padding: 10px; text-align: left;">Date</th>
                                                <th style="padding: 10px; text-align: left;">Total</th>
                                                <th style="padding: 10px; text-align: left;">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody id="recentOrders">
                                            <!-- Recent orders will be loaded here -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Profile Information Section -->
                <div class="accordion-section" id="profile-section">
                    <button class="accordion-header" onclick="toggleAccordion('profile-section')">
                        <div class="accordion-title">
                            <i class="fas fa-user"></i>
                            Profile Information
                        </div>
                        <i class="fas fa-chevron-down accordion-arrow"></i>
                    </button>
                    <div class="accordion-body">
                        <div class="accordion-content">
                            <div style="display: flex; justify-content: flex-end; gap: 15px; margin-bottom: 20px;">
                                <button class="btn btn-secondary" onclick="resetProfileForm()">
                                    <i class="fas fa-undo"></i>
                                    Reset
                                </button>
                                <button class="btn btn-primary" onclick="saveProfile()">
                                    <i class="fas fa-save"></i>
                                    Save Changes
                                </button>
                            </div>
                    
                    <form id="profileForm">
                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label">
                                    First Name <span class="required">*</span>
                                </label>
                                <input type="text" class="form-input" id="profileFirstName" name="first_name" required>
                                <div class="error-message" id="firstNameError"></div>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">
                                    Last Name <span class="required">*</span>
                                </label>
                                <input type="text" class="form-input" id="profileLastName" name="last_name" required>
                                <div class="error-message" id="lastNameError"></div>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">
                                    Email Address <span class="required">*</span>
                                </label>
                                <input type="email" class="form-input" id="profileEmail" name="email" required>
                                <div class="error-message" id="emailError"></div>
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label">
                                    Phone Number <span class="required">*</span>
                                </label>
                                <input type="tel" class="form-input" id="profilePhone" name="phone" required>
                                <div class="error-message" id="phoneError"></div>
                            </div>
                        </div>
                    </form>
                        </div>
                    </div>
                </div>

                <!-- My Orders Section -->
                <div class="accordion-section" id="orders-section">
                    <button class="accordion-header" onclick="toggleAccordion('orders-section')">
                        <div class="accordion-title">
                            <i class="fas fa-shopping-bag"></i>
                            My Orders
                        </div>
                        <i class="fas fa-chevron-down accordion-arrow"></i>
                    </button>
                    <div class="accordion-body">
                        <div class="accordion-content">
                            <div style="display: flex; justify-content: flex-end; margin-bottom: 20px;">
                                <button class="btn btn-primary" onclick="window.location.href='index.jsp'">
                                    <i class="fas fa-shopping-cart"></i>
                                    Shop Now
                                </button>
                            </div>
                    
                    <div style="overflow-x: auto;">
                        <table class="orders-table">
                            <thead>
                                <tr>
                                    <th>Order ID</th>
                                    <th>Date</th>
                                    <th>Items</th>
                                    <th>Total</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="ordersTable">
                                <!-- Orders will be loaded here -->
                            </tbody>
                        </table>
                    </div>
                    
                            <div class="empty-state" id="emptyOrders" style="display: none;">
                                <i class="fas fa-shopping-bag"></i>
                                <h3>No Orders Yet</h3>
                                <p style="margin-bottom: 20px;">You haven't placed any orders yet.</p>
                                <button class="btn btn-primary" onclick="window.location.href='index.jsp'">
                                    <i class="fas fa-shopping-cart"></i>
                                    Start Shopping
                                </button>
                            </div>
                        </div>
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
        // Sample data
        const sampleData = {
            user: {
                firstName: "Mohamed",
                lastName: "Salah",
                email: "mohamed.salah@example.com",
                phone: "+201234567890",
                dob: "1992-06-15",
                gender: "male",
                avatar: "MS",
                membership: "gold",
                points: 1250
            },
            orders: [
                {
                    id: "ORD-123456",
                    date: "2024-01-15T10:30:00",
                    items: 3,
                    total: 1897.93,
                    status: "processing"
                },
                {
                    id: "ORD-789012",
                    date: "2024-01-10T14:20:00",
                    items: 1,
                    total: 418.97,
                    status: "delivered"
                },
                {
                    id: "ORD-345678",
                    date: "2024-01-05T09:15:00",
                    items: 2,
                    total: 549.98,
                    status: "shipped"
                }
            ],
            addresses: [
                {
                    id: 1,
                    name: "Home",
                    fullName: "Mohamed Salah",
                    street: "123 Main Street, Building 5, Apartment 12",
                    government: "Cairo",
                    city: "Nasr City",
                    phone: "+201234567890",
                    type: "home",
                    default: true
                },
                {
                    id: 2,
                    name: "Work",
                    fullName: "Mohamed Salah",
                    street: "456 Business District, Tower A, Floor 8",
                    government: "Giza",
                    city: "Smart Village",
                    phone: "+201098765432",
                    type: "work",
                    default: false
                }
            ],
            wishlist: [
                {
                    id: 1,
                    name: "Quantum X1 Laptop",
                    price: 1299.99,
                    image: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&auto=format&fit=crop"
                },
                {
                    id: 2,
                    name: "Aether Pro Smartphone",
                    price: 899.99,
                    image: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&auto=format&fit=crop"
                },
                {
                    id: 3,
                    name: "Nova 5 Wireless Earbuds",
                    price: 199.99,
                    image: "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=500&auto=format&fit=crop"
                }
            ],
            activity: [
                {
                    title: "Order Placed",
                    description: "You placed order ORD-123456",
                    time: "2024-01-15T10:30:00"
                },
                {
                    title: "Product Reviewed",
                    description: "You reviewed 'Quantum X1 Laptop'",
                    time: "2024-01-14T16:45:00"
                },
                {
                    title: "Address Added",
                    description: "You added a new shipping address",
                    time: "2024-01-12T11:20:00"
                },
                {
                    title: "Profile Updated",
                    description: "You updated your profile information",
                    time: "2024-01-10T09:15:00"
                },
                {
                    title: "Wishlist Item Added",
                    description: "You added 'Nova 5 Wireless Earbuds' to wishlist",
                    time: "2024-01-08T14:30:00"
                }
            ],
            notifications: [
                {
                    id: 1,
                    title: "Order Shipped",
                    message: "Your order ORD-345678 has been shipped",
                    time: "2024-01-06T14:20:00",
                    read: true
                },
                {
                    id: 2,
                    title: "Price Drop Alert",
                    message: "Nova 5 Wireless Earbuds is now 20% off",
                    time: "2024-01-05T10:15:00",
                    read: false
                },
                {
                    id: 3,
                    title: "New Arrival",
                    message: "Check out the new Quantum X2 Laptop",
                    time: "2024-01-03T09:30:00",
                    read: true
                }
            ],
            sessions: [
                {
                    id: 1,
                    device: "Chrome on Windows",
                    location: "Cairo, Egypt",
                    time: "2024-01-15T10:25:00",
                    current: true
                },
                {
                    id: 2,
                    device: "Safari on iPhone",
                    location: "Alexandria, Egypt",
                    time: "2024-01-14T14:30:00",
                    current: false
                }
            ]
        };

        // State
        let currentSection = 'dashboard';

        // Initialize
        document.addEventListener('DOMContentLoaded', () => {
            loadUserData();
            loadDashboard();
            setupEventListeners();
            updateCartCount();
        });

        // Load user data
        function loadUserData() {
            const user = sampleData.user;
            
            // Update avatar
            const avatar = document.getElementById('userAvatar');
            const currentAvatar = document.getElementById('currentAvatar');
            avatar.textContent = user.avatar;
            currentAvatar.textContent = user.avatar;
            
            // Update name and email
            document.getElementById('userName').textContent = `${user.firstName} ${user.lastName}`;
            document.getElementById('userEmail').textContent = user.email;
            
            // Update profile form
            document.getElementById('profileFirstName').value = user.firstName;
            document.getElementById('profileLastName').value = user.lastName;
            document.getElementById('profileEmail').value = user.email;
            document.getElementById('profilePhone').value = user.phone;
            document.getElementById('profileDob').value = user.dob;
            
            // Set gender
            const genderRadio = document.querySelector(`input[name="gender"][value="${user.gender}"]`);
            if (genderRadio) genderRadio.checked = true;
        }

        // Load dashboard data
        function loadDashboard() {
            // Load activity
            const activityList = document.getElementById('activityList');
            activityList.innerHTML = sampleData.activity.map(activity => `
                <li class="activity-item">
                    <div class="activity-icon">
                        <i class="fas fa-${getActivityIcon(activity.title)}"></i>
                    </div>
                    <div class="activity-content">
                        <div class="activity-title">${activity.title}</div>
                        <div class="activity-description">${activity.description}</div>
                        <div class="activity-time">${formatTime(activity.time)}</div>
                    </div>
                </li>
            `).join('');

            // Load recent orders
            const recentOrders = document.getElementById('recentOrders');
            recentOrders.innerHTML = sampleData.orders.map(order => `
                <tr>
                    <td style="padding: 10px;">
                        <a href="order-details.jsp?orderId=${order.id}" style="color: var(--primary); text-decoration: none; font-weight: 600;">
                            ${order.id}
                        </a>
                    </td>
                    <td style="padding: 10px;">${formatDate(order.date)}</td>
                    <td style="padding: 10px;">$${order.total.toFixed(2)}</td>
                    <td style="padding: 10px;">
                        <span class="order-status ${order.status}">
                            ${order.status.charAt(0).toUpperCase() + order.status.slice(1)}
                        </span>
                    </td>
                    <td style="padding: 10px;">
                        <a href="order-details.jsp?orderId=${order.id}" class="btn btn-secondary btn-sm">
                            <i class="fas fa-eye"></i>
                        </a>
                    </td>
                </tr>
            `).join('');
        }

        // Setup event listeners
        function setupEventListeners() {
            // Menu navigation
            document.querySelectorAll('.menu-link').forEach(link => {
                link.addEventListener('click', (e) => {
                    e.preventDefault();
                    const section = link.getAttribute('data-section');
                    switchSection(section);
                    
                    // Update active state
                    document.querySelectorAll('.menu-link').forEach(l => l.classList.remove('active'));
                    link.classList.add('active');
                    
                    // Close mobile menu if open
                    document.getElementById('profileSidebar').style.display = 'block';
                });
            });

            // Mobile menu toggle
            document.getElementById('mobileMenuToggle').addEventListener('click', () => {
                const sidebar = document.getElementById('profileSidebar');
                sidebar.style.display = sidebar.style.display === 'none' ? 'block' : 'none';
            });

            // Close modals when clicking outside
            document.querySelectorAll('.modal').forEach(modal => {
                modal.addEventListener('click', (e) => {
                    if (e.target === modal) {
                        modal.classList.remove('active');
                    }
                });
            });
        }

        // Toggle accordion sections
        function toggleAccordion(sectionId) {
            const section = document.getElementById(sectionId);
            const isActive = section.classList.contains('active');
            
            // Close all sections
            document.querySelectorAll('.accordion-section').forEach(sec => {
                sec.classList.remove('active');
            });
            
            // If section was not active, open it
            if (!isActive) {
                section.classList.add('active');
                currentSection = sectionId.replace('-section', '');
                
                // Load section data if needed
                switch(currentSection) {
                    case 'orders':
                        loadOrders();
                        break;
                    case 'notifications':
                        loadNotifications();
                        break;
                }
            }
        }
        
        // Switch between sections (for compatibility with existing code)
        function switchSection(section) {
            const targetSection = document.getElementById(`${section}-section`);
            if (targetSection) {
                toggleAccordion(`${section}-section`);
            }
        }

        // Load orders
        function loadOrders() {
            const ordersTable = document.getElementById('ordersTable');
            const emptyOrders = document.getElementById('emptyOrders');
            
            if (sampleData.orders.length === 0) {
                ordersTable.innerHTML = '';
                emptyOrders.style.display = 'block';
                return;
            }
            
            emptyOrders.style.display = 'none';
            ordersTable.innerHTML = sampleData.orders.map(order => `
                <tr>
                    <td class="order-id">${order.id}</td>
                    <td>${formatDate(order.date)}</td>
                    <td>${order.items} item${order.items > 1 ? 's' : ''}</td>
                    <td>$${order.total.toFixed(2)}</td>
                    <td>
                        <div class="order-actions">
                            <a href="order-details.jsp?orderId=${order.id}" class="btn btn-secondary btn-sm">
                                <i class="fas fa-eye"></i>
                            </a>
                            <button class="btn btn-secondary btn-sm" onclick="reorderItems('${order.id}')">
                                <i class="fas fa-redo"></i>
                            </button>
                            ${order.status === 'processing' ? `
                                <button class="btn btn-danger btn-sm" onclick="cancelOrder('${order.id}')">
                                    <i class="fas fa-times"></i>
                                </button>
                            ` : ''}
                        </div>
                    </td>
                </tr>
            `).join('');
        }

        // Load notifications
        function loadNotifications() {
            const notificationsList = document.getElementById('notificationsList');
            
            notificationsList.innerHTML = sampleData.notifications.map(notification => `
                <div class="setting-option" style="align-items: flex-start; ${notification.read ? 'opacity: 0.7;' : 'background: rgba(58, 54, 224, 0.05);'}">
                    <div class="setting-info">
                        <h4>${notification.title}</h4>
                        <p>${notification.message}</p>
                        <div style="color: var(--gray); font-size: 0.85rem; margin-top: 5px;">
                            ${formatTime(notification.time)}
                        </div>
                    </div>
                    ${!notification.read ? `
                        <button class="btn btn-secondary btn-sm" onclick="markAsRead(${notification.id})">
                            Mark as Read
                        </button>
                    ` : ''}
                </div>
            `).join('');
        }

        // Load sessions
        function loadSessions() {
            const sessionsList = document.getElementById('sessionsList');
            
            sessionsList.innerHTML = sampleData.sessions.map(session => `
                <div class="setting-option">
                    <div class="setting-info">
                        <h4>${session.device}</h4>
                        <p>${session.location} • ${formatTime(session.time)}</p>
                    </div>
                    ${session.current ? `
                        <span style="color: var(--success); font-weight: 600;">Current</span>
                    ` : `
                        <button class="btn btn-danger btn-sm" onclick="logoutSession(${session.id})">
                            <i class="fas fa-sign-out-alt"></i>
                        </button>
                    `}
                </div>
            `).join('');
        }

        // Profile functions
        function saveProfile() {
            const form = document.getElementById('profileForm');
            const formData = new FormData(form);
            
            // Basic validation
            let isValid = true;
            const requiredFields = ['first_name', 'last_name', 'email', 'phone'];
            
            requiredFields.forEach(field => {
                const input = form.querySelector(`[name="${field}"]`);
                const error = document.getElementById(`${field}Error`);
                
                if (!input.value.trim()) {
                    showError(field, 'This field is required');
                    isValid = false;
                } else {
                    clearError(field);
                    
                    // Email validation
                    if (field === 'email' && !isValidEmail(input.value)) {
                        showError(field, 'Please enter a valid email address');
                        isValid = false;
                    }
                    
                    // Phone validation
                    if (field === 'phone' && !isValidEgyptPhone(input.value)) {
                        showError(field, 'Please enter a valid Egyptian phone number');
                        isValid = false;
                    }
                }
            });
            
            if (!isValid) {
                alert('Please fix the errors in the form');
                return;
            }
            
            // Save to localStorage (in a real app, this would be an API call)
            const userData = {
                firstName: formData.get('first_name'),
                lastName: formData.get('last_name'),
                email: formData.get('email'),
                phone: formData.get('phone'),
                dob: formData.get('dob'),
                gender: formData.get('gender')
            };
            
            localStorage.setItem('nexusUser', JSON.stringify(userData));
            
            // Update UI
            const avatar = document.getElementById('userAvatar');
            const currentAvatar = document.getElementById('currentAvatar');
            avatar.textContent = userData.firstName.charAt(0) + userData.lastName.charAt(0);
            currentAvatar.textContent = userData.firstName.charAt(0) + userData.lastName.charAt(0);
            
            document.getElementById('userName').textContent = `${userData.firstName} ${userData.lastName}`;
            document.getElementById('userEmail').textContent = userData.email;
            
            alert('Profile updated successfully!');
        }

        function resetProfileForm() {
            loadUserData();
            clearAllErrors();
        }

        // Notification functions
        function markAllAsRead() {
            sampleData.notifications.forEach(n => n.read = true);
            loadNotifications();
            alert('All notifications marked as read!');
        }

        // Utility functions

        function formatDate(dateString) {
            const date = new Date(dateString);
            return date.toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
                year: 'numeric'
            });
        }

        function formatTime(dateString) {
            const date = new Date(dateString);
            const now = new Date();
            const diff = now - date;
            
            // If less than 24 hours, show relative time
            if (diff < 24 * 60 * 60 * 1000) {
                const hours = Math.floor(diff / (60 * 60 * 1000));
                if (hours === 0) {
                    const minutes = Math.floor(diff / (60 * 1000));
                    return `${minutes} minute${minutes === 1 ? '' : 's'} ago`;
                }
                return `${hours} hour${hours === 1 ? '' : 's'} ago`;
            }
            
            // Otherwise show date
            return formatDate(dateString);
        }

        function isValidEmail(email) {
            const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(email);
        }

        function isValidEgyptPhone(phone) {
            const re = /^(\+20|0)?1[0-9]{9}$/;
            return re.test(phone.replace(/\s+/g, ''));
        }

        function showError(field, message) {
            const errorEl = document.getElementById(`${field}Error`);
            if (errorEl) {
                errorEl.textContent = message;
                errorEl.classList.add('show');
                document.getElementById(`profile${field.charAt(0).toUpperCase() + field.slice(1)}`).classList.add('error');
            }
        }

        function clearError(field) {
            const errorEl = document.getElementById(`${field}Error`);
            if (errorEl) {
                errorEl.classList.remove('show');
                document.getElementById(`profile${field.charAt(0).toUpperCase() + field.slice(1)}`).classList.remove('error');
            }
        }

        function clearAllErrors() {
            const errors = ['firstName', 'lastName', 'email', 'phone'];
            errors.forEach(clearError);
        }

        function updateCartCount() {
            const cart = JSON.parse(sessionStorage.getItem('nexusCart')) || [];
            const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
            const cartCount = document.getElementById('cart-count');
            
            cartCount.textContent = totalItems;
            cartCount.style.display = totalItems > 0 ? 'flex' : 'none';
        }

        function logout() {
            if (confirm('Are you sure you want to logout?')) {
                // Clear session data
                sessionStorage.removeItem('nexusCart');
                sessionStorage.removeItem('lastOrder');
                
                // Redirect to login page (in a real app)
                alert('You have been logged out successfully!');
                window.location.href = 'index.jsp';
            }
        }


    </script>
</body>
</html>