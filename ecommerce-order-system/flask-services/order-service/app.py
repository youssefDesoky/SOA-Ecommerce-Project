from flask import Flask, jsonify
from flask import request
from flask_cors import CORS
import mysql.connector
import requests
from decimal import Decimal

app = Flask(__name__)
CORS(app)

def get_db_connection():
    return mysql.connector.connect(host='localhost', user='root', password='', database='ecommerce_system')

@app.route('/orders', methods=['GET'])
def get_orders():
    db = get_db_connection()
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM orders")
    orders = cur.fetchall()
    cur.close()
    db.close()
    return jsonify({'orders': orders})

# GET /api/orders - Get orders, optionally filtered by customer_id
@app.route('/api/orders', methods=['GET'])
def get_orders_api():
    """Get all orders or filter by customer_id"""
    customer_id = request.args.get('customer_id')
    
    db = get_db_connection()
    cur = db.cursor(dictionary=True)
    
    try:
        if customer_id:
            cur.execute("""
                SELECT o.order_id, o.customer_id, o.total_amount, o.status, 
                       o.order_date, o.shipping_address, o.payment_method, o.total_discount
                FROM orders o
                WHERE o.customer_id = %s
                ORDER BY o.order_date DESC
            """, (customer_id,))
        else:
            cur.execute("""
                SELECT order_id, customer_id, total_amount, status, 
                       order_date, shipping_address, payment_method, total_discount
                FROM orders
                ORDER BY order_date DESC
            """)
        
        orders = cur.fetchall()
        
        # Convert Decimal and datetime to JSON-serializable format
        for order in orders:
            if order.get('total_amount'):
                order['total_amount'] = float(order['total_amount'])
            if order.get('total_discount'):
                order['total_discount'] = float(order['total_discount'])
            if order.get('order_date'):
                order['order_date'] = str(order['order_date'])
        
        return jsonify(orders), 200
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cur.close()
        db.close()

#POST /api/orders/create

@app.route('/api/orders/create', methods=['POST'])
def create_order():
    data = request.get_json(silent=True) or {}
    customer_id = data.get('customer_id')
    products = data.get('products', [])  # Expect list of {'product_id': int, 'quantity': int}

    if not isinstance(customer_id, int) or not products:
        return jsonify({'error': 'invalid input'}), 400

    db = get_db_connection()
    cur = db.cursor()
    
    try:
        # Check inventory availability
        for product in products:
            product_id = product.get('product_id')
            quantity = product.get('quantity')
            if not isinstance(product_id, int) or not isinstance(quantity, int):
                return jsonify({'error': 'invalid product data'}), 400
            
            response = requests.get(f'http://localhost:5002/api/inventory/check/{product_id}')
            if response.status_code == 404:
                return jsonify({'error': f'product {product_id} not found'}), 404
            elif response.status_code != 200:
                return jsonify({'error': 'inventory check failed'}), 500
            
            inventory_data = response.json()
            stock_available = inventory_data.get('quantity_available', 0)
            product['unit_price'] = Decimal(inventory_data.get('unit_price', '100.00'))
            
            if stock_available < quantity:
                return jsonify({'error': f'insufficient stock for product {product_id}'}), 400
        
        # Calculate pricing using pricing service
        shipping_address = data.get('shipping_address', '')
        region = shipping_address.split(' - ')[-1].strip() if shipping_address else ''
        pricing_data = {'products': [{'product_id': p['product_id'], 'quantity': p['quantity'], 'unit_price': str(p['unit_price'])} for p in products], 'region': region}
        pricing_response = requests.post('http://localhost:5003/api/pricing/calculate', json=pricing_data)
        if pricing_response.status_code != 200:
            return jsonify({'error': 'pricing calculation failed'}), 500
        
        pricing_result = pricing_response.json()
        total_amount = pricing_result['total']
        
        # Calculate total discount and discount percentage
        total_discount = sum(Decimal(item['total_before_discount']) - Decimal(item['discounted_total']) for item in pricing_result['items'])
        
        # Insert order
        shipping_address = data.get('shipping_address', '')
        payment_method = data.get('payment_method', '')
        cur.execute('INSERT INTO orders (customer_id, total_amount, shipping_address, payment_method, total_discount) VALUES (%s, %s, %s, %s, %s)', 
                    (customer_id, total_amount, shipping_address, payment_method, total_discount))
        order_id = cur.lastrowid
        
        # Insert order items
        for product, item_pricing in zip(products, pricing_result['items']):
            product_id = product['product_id']
            quantity = product['quantity']
            
            unit_price = product['unit_price']
            item_total_price = item_pricing['discounted_total']
            
            cur.execute('INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES (%s, %s, %s, %s, %s)', 
                        (order_id, product_id, quantity, unit_price, item_total_price))
        
        db.commit()
        
        # Update inventory via service
        for product in products:
            update_response = requests.put('http://localhost:5002/api/inventory/update', json={'product_id': product['product_id'], 'quantity_delta': -product['quantity']})
            if update_response.status_code != 200:
                # Log error, but order is created
                pass
        
        # Award loyalty points: 1 point per $10 spent
        loyalty_points_earned = int(float(total_amount) // 10)
        if loyalty_points_earned > 0:
            try:
                # Get current loyalty points
                customer_response = requests.get(f'http://localhost:5004/api/customers/{customer_id}')
                if customer_response.status_code == 200:
                    customer_data = customer_response.json()
                    current_points = customer_data.get('loyalty_points', 0) or 0
                    new_points = current_points + loyalty_points_earned
                    
                    # Update loyalty points via Customer Service
                    requests.put(
                        f'http://localhost:5004/api/customers/{customer_id}/loyalty',
                        json={'loyalty_points': new_points}
                    )
            except Exception as e:
                # Log error but don't fail the order
                print(f"Failed to update loyalty points: {e}")
        
        return jsonify({
            'order_id': order_id, 
            'total_amount': total_amount, 
            'total_discount': total_discount,
            'loyalty_points_earned': loyalty_points_earned
        }), 201
    
    finally:
        cur.close()
        db.close()


#GET /api/orders/{order_id}
@app.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order(order_id):
    db = get_db_connection()
    cur = db.cursor(dictionary=True)
    
    try:
        cur.execute("SELECT * FROM orders WHERE order_id = %s", (order_id,))
        order = cur.fetchone()
        if not order:
            return jsonify({"error": "not found"}), 404
        
        # Get order items
        cur.execute("SELECT * FROM order_items WHERE order_id = %s", (order_id,))
        items = cur.fetchall()
        
        # Convert Decimal values
        if order.get('total_amount'):
            order['total_amount'] = float(order['total_amount'])
        if order.get('total_discount'):
            order['total_discount'] = float(order['total_discount'])
        if order.get('order_date'):
            order['order_date'] = str(order['order_date'])
        
        for item in items:
            if item.get('unit_price'):
                item['unit_price'] = float(item['unit_price'])
            if item.get('total_price'):
                item['total_price'] = float(item['total_price'])
        
        order['items'] = items
        
        return jsonify(order)
    
    finally:
        cur.close()
        db.close()



@app.route('/api/orders/preview', methods=['POST'])
def preview_order():
    data = request.get_json(silent=True) or {}

    products = data.get('products', [])
    shipping_address = data.get('shipping_address', '')

    if not products:
        return jsonify({'error': 'No products'}), 400

    enriched_products = []
    product_names = {}  # Store product names for later

    for p in products:
        product_id = p.get('product_id')
        quantity = p.get('quantity')

        if not isinstance(product_id, int) or not isinstance(quantity, int):
            return jsonify({'error': 'Invalid product data'}), 400

        inv_res = requests.get(
            f'http://localhost:5002/api/inventory/check/{product_id}'
        )

        if inv_res.status_code != 200:
            return jsonify({'error': f'Product {product_id} not found'}), 404

        inv = inv_res.json()

        if 'unit_price' not in inv or inv['unit_price'] is None:
            return jsonify({'error': f'Price missing for product {product_id}'}), 500

        # Store product name
        product_names[product_id] = inv.get('product_name', f'Product #{product_id}')

        enriched_products.append({
            "product_id": product_id,
            "quantity": quantity,
            "unit_price": float(inv['unit_price'])
        })

    pricing_res = requests.post(
        "http://localhost:5003/api/pricing/calculate",
        json={
            "products": enriched_products,
            "region": shipping_address.split(',')[-1].strip()
        }
    )

    if pricing_res.status_code != 200:
        return jsonify({'error': 'Pricing failed'}), 500

    pricing = pricing_res.json()

    total_discount = sum(
        Decimal(item['total_before_discount']) - Decimal(item['discounted_total'])
        for item in pricing['items']
    )

    # Add product names and format for JSP
    items_with_names = []
    for item in pricing['items']:
        # Use Decimal for proper rounding
        total_price = Decimal(str(item['discounted_total'])).quantize(Decimal('0.01'))
        items_with_names.append({
            'product_id': item['product_id'],
            'product_name': product_names.get(item['product_id'], f"Product #{item['product_id']}"),
            'quantity': item['quantity'],
            'unit_price': float(Decimal(str(item['unit_price'])).quantize(Decimal('0.01'))),
            'total_price': float(total_price)
        })

    return jsonify({
        "items": items_with_names,
        "subtotal": pricing["subtotal"],
        "discount": float(total_discount),
        "tax": pricing["tax"],
        "total_amount": pricing["total"]
    }), 200






if __name__ == '__main__':
    print("=" * 50)
    print("Order Service running on port 5001")
    print("=" * 50)
    print("Endpoints:")
    print("  GET  /api/orders              - Get all orders (optional ?customer_id=X)")
    print("  GET  /api/orders/{order_id}   - Get specific order")
    print("  POST /api/orders/create       - Create new order")
    print("=" * 50)
    app.run(debug=True, port=5001, host='0.0.0.0')