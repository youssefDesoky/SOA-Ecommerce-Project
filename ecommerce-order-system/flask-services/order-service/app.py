from flask import Flask, jsonify
from flask import request
import mysql.connector
import requests
from decimal import Decimal

app = Flask(__name__)
db = mysql.connector.connect(host='localhost', user='root', password='root', database='ecommerce_system')

@app.route('/orders', methods=['GET'])
def get_orders():
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM orders")
    orders = cur.fetchall()
    return jsonify({'orders': orders})

#POST /api/orders/create

@app.route('/api/orders/create', methods=['POST'])
def create_order():
    data = request.get_json(silent=True) or {}
    customer_id = data.get('customer_id')
    products = data.get('products', [])  # Expect list of {'product_id': int, 'quantity': int}

    if not isinstance(customer_id, int) or not products:
        return jsonify({'error': 'invalid input'}), 400

    cur = db.cursor()
    
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
    
    return jsonify({'order_id': order_id, 'total_amount': total_amount, 'total_discount': total_discount}), 201


#GET /api/orders/{order_id}
@app.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order(order_id):
    cur = db.cursor(dictionary=True)
    cur.execute("SELECT * FROM orders WHERE order_id = %s", (order_id,))
    order = cur.fetchone()
    if not order:
        return jsonify({"error": "not found"}), 404
    
    # Get order items
    cur.execute("SELECT * FROM order_items WHERE order_id = %s", (order_id,))
    items = cur.fetchall()
    order['items'] = items
    
    # Calculate total discount and discount percentage
    total_discount = sum((Decimal(item['unit_price']) * item['quantity']) - Decimal(item['total_price']) for item in items)
    order['total_discount'] = total_discount
    
    return jsonify(order)

if __name__ == '__main__':
    app.run(debug=True, port=5001, host='0.0.0.0')