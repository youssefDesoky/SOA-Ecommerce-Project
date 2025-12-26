<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Profile | Nexus</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/customer-profile.css">
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

        <form class="search-form" method="post" action="${pageContext.request.contextPath}/customers/lookup">
            <input
                type="email"
                name="email"
                class="search-input"
                placeholder="Enter customer email address..."
                required
                value="<c:out value='${searchedEmail}'/>"
            >
            <button type="submit" class="btn btn-primary">
                <i class="fas fa-search"></i> Display
            </button>
        </form>

        <c:if test="${not empty errorMessage}">
            <div class="error-message active">
                <i class="fas fa-exclamation-circle"></i>
                <span><c:out value="${errorMessage}"/></span>
            </div>
        </c:if>
    </section>

    <!-- Results Section (show only when customer exists) -->
    <section id="resultsSection" class="results-section <c:if test='${not empty customer}'>active</c:if>">

        <c:if test="${not empty customer}">
            <!-- Profile Card -->
            <div class="profile-card">
                <div class="profile-header">
                    <div class="profile-avatar">
                        <!-- Access 'name' from the 'customer' map -->
                        <c:set var="custName" value="${customer['name']}" />
                        <c:choose>
                            <c:when test="${not empty custName}">
                                <c:out value="${fn:substring(custName, 0, 1)}"/>
                            </c:when>
                            <c:otherwise>--</c:otherwise>
                        </c:choose>
                    </div>

                    <div class="profile-info">
                        <h2><c:out value="${customer['name']}"/></h2>
                        <p><c:out value="${customer['email']}"/></p>

                        <div class="profile-badges">
                            <span class="badge badge-primary">
                                <i class="fas fa-user"></i> Customer ID: <span><c:out value="${customer['customer_id']}"/></span>
                            </span>
                            <span class="badge badge-warning">
                                <i class="fas fa-calendar"></i> Member since: <span><c:out value="${customer['created_at']}"/></span>
                            </span>
                        </div>
                    </div>
                </div>

                <div class="profile-details">
                    <div class="detail-item">
                        <div class="detail-label"><i class="fas fa-envelope"></i> Email</div>
                        <div class="detail-value"><c:out value="${customer['email']}"/></div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label"><i class="fas fa-phone"></i> Phone</div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${not empty customer['phone']}"><c:out value="${customer['phone']}"/></c:when>
                                <c:otherwise>Not provided</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label"><i class="fas fa-shopping-bag"></i> Total Orders</div>
                        <div class="detail-value">
                            <c:choose>
                                <c:when test="${not empty orders}">
                                    <c:out value="${fn:length(orders)}"/>
                                </c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label"><i class="fas fa-star"></i> Loyalty Points</div>
                        <div class="detail-value"><c:out value="${customer['loyalty_points']}"/></div>
                    </div>
                </div>

                <!-- Loyalty Points Section -->
                <div class="loyalty-section">
                    <div class="loyalty-info">
                        <h3><i class="fas fa-gem"></i> Loyalty Points</h3>
                        <div class="loyalty-points"><c:out value="${customer['loyalty_points']}"/></div>
                    </div>
                    <div class="loyalty-info" style="text-align:right;">
                        <p style="opacity:0.9;font-size:0.9rem;">Earn 1 point for every $10 spent</p>
                        <p style="opacity:0.7;font-size:0.85rem;">Points are automatically added when you place an order</p>
                    </div>
                </div>
            </div>

            <!-- Notifications Card -->
            <div class="orders-card">
                <div class="orders-header">
                    <h3 class="orders-title">
                        <i class="fas fa-bell"></i> My Notifications
                    </h3>

                    <span class="badge badge-primary">
                        <c:choose>
                            <c:when test="${not empty notifications}">
                                <c:out value="${fn:length(notifications)}"/> notifications
                            </c:when>
                            <c:otherwise>0 notifications</c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <c:choose>
                    <c:when test="${empty notifications}">
                        <div class="empty-state">
                            <i class="fas fa-bell-slash"></i>
                            <h3>No Notifications</h3>
                            <p>This customer has no notifications yet.</p>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <table class="orders-table">
                            <thead>
                            <tr>
                                <th>Type</th>
                                <th>Message</th>
                                <th>Order</th>
                                <th>Date</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="n" items="${notifications}">
                                <tr>
                                    <td>
                                        <span class="order-status status-completed">
                                            <c:out value="${n.notification_type}"/>
                                        </span>
                                    </td>
                                    <td><c:out value="${n.message}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty n.order_id}">
                                                #<c:out value="${n.order_id}"/>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><c:out value="${n.sent_at}"/></td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Orders Card -->
            <div class="orders-card">
                <div class="orders-header">
                    <h3 class="orders-title">
                        <i class="fas fa-history"></i> Order History
                    </h3>

                    <span class="badge badge-primary">
                        <c:choose>
                            <c:when test="${not empty orders}">
                                <c:out value="${fn:length(orders)}"/> orders
                            </c:when>
                            <c:otherwise>0 orders</c:otherwise>
                        </c:choose>
                    </span>
                </div>

                <c:choose>
                    <c:when test="${empty orders}">
                        <div class="empty-state">
                            <i class="fas fa-shopping-bag"></i>
                            <h3>No Orders Found</h3>
                            <p>This customer hasn't placed any orders yet.</p>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <table class="orders-table">
                            <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Date</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="order" items="${orders}">
                                <tr>
                                    <td class="order-id">#<c:out value="${order['order_id']}"/></td>
                                    <td><c:out value="${order['order_date']}"/></td>
                                    <td>$<c:out value="${order['total_amount']}"/></td>
                                    <td>
                                        <span class="order-status status-pending">
                                            <c:out value="${order['status']}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/orders/view/${order['order_id']}"
                                        class="btn btn-secondary" title="View Order">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>

    </section>

</div>
</body>
</html>
