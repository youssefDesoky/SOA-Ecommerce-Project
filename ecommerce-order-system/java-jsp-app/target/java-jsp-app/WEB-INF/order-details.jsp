<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Order Details | Nexus</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    :root {
        --primary: #3a36e0;
        --primary-dark: #2a27c9;
        --secondary: #ff6b82;
        --dark: #0f172a;
        --gray: #64748b;
        --gray-light: #e2e8f0;
        --light: #f8fafc;
        --radius: 12px;
        --shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
        --transition: all 0.25s ease;
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
        background: #f5f7fb;
        color: var(--dark);
        line-height: 1.6;
    }

    .container { max-width: 1100px; margin: 0 auto; padding: 0 20px 50px; }

    header {
        background: white;
        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
        position: sticky;
        top: 0;
        z-index: 10;
    }

    nav {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 14px 0;
    }

    .logo { display: flex; align-items: center; gap: 10px; text-decoration: none; color: var(--dark); }
    .logo-icon { width: 36px; height: 36px; border-radius: 10px; background: linear-gradient(135deg, var(--primary), var(--secondary)); display: grid; place-items: center; color: white; font-weight: 800; }
    .logo-text { font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 800; font-size: 22px; background: linear-gradient(135deg, var(--primary), var(--secondary)); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }

    .page-header { display: flex; justify-content: space-between; align-items: center; margin: 32px 0 18px; gap: 12px; flex-wrap: wrap; }
    .page-title { font-family: 'Plus Jakarta Sans', sans-serif; font-size: 28px; font-weight: 800; }
    .page-subtitle { color: var(--gray); font-size: 14px; }

    .btn-link { display: inline-flex; align-items: center; gap: 8px; padding: 10px 14px; border-radius: var(--radius); border: 1px solid var(--gray-light); background: white; cursor: pointer; color: var(--dark); text-decoration: none; transition: var(--transition); font-weight: 600; }
    .btn-link:hover { border-color: var(--primary); color: var(--primary); box-shadow: 0 8px 20px rgba(58, 54, 224, 0.12); }

    .status-banner {
        background: linear-gradient(135deg, var(--primary), var(--primary-dark));
        color: white;
        border-radius: var(--radius);
        padding: 22px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        box-shadow: var(--shadow);
    }

    .status-text h3 { font-size: 18px; font-weight: 700; margin-bottom: 6px; }
    .status-text p { opacity: 0.92; font-size: 14px; }
    .badge { display: inline-flex; align-items: center; gap: 8px; padding: 8px 14px; border-radius: 999px; background: rgba(255, 255, 255, 0.18); font-weight: 700; font-size: 14px; }
    .badge.processing { background: rgba(255, 193, 7, 0.2); color: #ffd166; }
    .badge.delivered { background: rgba(16, 185, 129, 0.2); color: #34d399; }
    .badge.shipped { background: rgba(59, 130, 246, 0.2); color: #60a5fa; }
    .badge.cancelled { background: rgba(239, 68, 68, 0.2); color: #f87171; }

    .grid { display: grid; grid-template-columns: 2fr 1fr; gap: 22px; margin-top: 22px; }
    @media (max-width: 900px) { .grid { grid-template-columns: 1fr; } }

    .card { background: white; border-radius: var(--radius); box-shadow: var(--shadow); padding: 22px; }
    .card h2 { font-size: 18px; font-weight: 700; margin-bottom: 14px; display: flex; align-items: center; gap: 10px; }

    .order-item { display: grid; grid-template-columns: 70px 1fr auto; gap: 16px; padding: 14px 0; border-bottom: 1px solid var(--gray-light); align-items: center; }
    .order-item:last-child { border-bottom: none; }
    .item-img { width: 70px; height: 70px; border-radius: 10px; object-fit: cover; background: var(--gray-light); }
    .item-name { font-weight: 700; margin-bottom: 4px; }
    .item-meta { color: var(--gray); font-size: 13px; }
    .item-price { text-align: right; font-weight: 700; color: var(--primary); }

    .summary { display: flex; flex-direction: column; gap: 10px; }
    .summary-row { display: flex; justify-content: space-between; font-size: 14px; color: var(--dark); }
    .summary-row.total { font-size: 18px; font-weight: 800; margin-top: 10px; padding-top: 10px; border-top: 2px solid var(--gray-light); }

    .meta { margin-top: 14px; padding-top: 14px; border-top: 1px solid var(--gray-light); color: var(--gray); font-size: 14px; display: grid; gap: 8px; }

    .actions { display: grid; gap: 10px; margin-top: 16px; }
    .btn { display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 12px; border-radius: var(--radius); border: none; cursor: pointer; font-weight: 700; transition: var(--transition); }
    .btn-primary { background: linear-gradient(135deg, var(--primary), var(--primary-dark)); color: white; }
    .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 12px 25px rgba(58, 54, 224, 0.25); }
    .btn-ghost { background: white; border: 1px solid var(--gray-light); color: var(--dark); }
    .btn-ghost:hover { border-color: var(--primary); color: var(--primary); }
  </style>
</head>
<body>
<header>
    <div class="container">
        <nav>
            <a class="logo" href="index.jsp">
                <div class="logo-icon">N</div>
                <span class="logo-text">Nexus</span>
            </a>
            <div style="display: flex; gap: 10px;">
                <a class="btn-link" href="orders.jsp"><i class="fas fa-arrow-left"></i>Back to Orders</a>
                <button class="btn-link" onclick="printOrder()"><i class="fas fa-print"></i>Print</button>
            </div>
        </nav>
    </div>
</header>

<div class="container">
    <div class="page-header">
        <div>
            <div class="page-title">Order Details</div>
            <div class="page-subtitle">
              <c:choose>
                <c:when test="${not empty order.created_at}">
                  <fmt:parseDate value="${order.created_at}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="odt" />
                  Placed on <fmt:formatDate value="${odt}" pattern="MMMM d, yyyy h:mm a"/>
                </c:when>
                <c:otherwise>—</c:otherwise>
              </c:choose>
            </div>
        </div>
        <div class="page-subtitle">Order #${order.id}</div>
    </div>

    <div class="status-banner">
      <div class="status-text">
        <h3>${order.status}</h3>
        <p>${order.statusMessage}</p>
      </div>
      <span class="badge ${order.status}">
        <i class="fas fa-clock"></i> ${order.status}
      </span>
    </div>

    <div class="grid">
      <div class="card">
        <h2><i class="fas fa-box"></i> Order Items
          <span style="color:#64748b; font-weight:600;">
            (<c:out value="${fn:length(order.items)}"/> item<c:if test="${fn:length(order.items) != 1}">s</c:if>)
          </span>
        </h2>
        <c:forEach var="item" items="${order.items}">
          <div class="order-item">
            <img class="item-img" src="${item.image}" alt="${item.name}">
            <div>
              <div class="item-name">${item.name}</div>
              <div class="item-meta">SKU: ${item.sku} • Qty: ${item.quantity}</div>
            </div>
            <div class="item-price">
              <fmt:formatNumber value="${item.price * item.quantity}" type="currency"/>
            </div>
          </div>
        </c:forEach>
        <c:if test="${empty order.items}">
          <div style="padding:16px; color:#64748b;">No items in this order.</div>
        </c:if>
      </div>

      <div class="card">
        <h2><i class="fas fa-receipt"></i> Summary</h2>
        <div class="summary">
          <div class="summary-row"><span>Subtotal</span><span><fmt:formatNumber value="${order.summary.subtotal}" type="currency"/></span></div>
          <div class="summary-row"><span>Shipping</span><span><fmt:formatNumber value="${order.summary.shipping}" type="currency"/></span></div>
          <div class="summary-row"><span>Tax</span><span><fmt:formatNumber value="${order.summary.tax}" type="currency"/></span></div>
          <div class="summary-row"><span>Discount</span><span>-<fmt:formatNumber value="${order.summary.discount}" type="currency"/></span></div>
          <div class="summary-row total"><span>Total</span><span><fmt:formatNumber value="${order.summary.total}" type="currency"/></span></div>
        </div>
        <div class="meta">
          <div><strong>Payment:</strong> ${order.payment.method} • ${order.payment.status}</div>
          <div><strong>Shipping:</strong> ${order.shipping.method}</div>
          <div><strong>Tracking:</strong> ${order.shipping.trackingNumber}</div>
        </div>
      </div>
    </div>
  </div>
</body>
</html>
