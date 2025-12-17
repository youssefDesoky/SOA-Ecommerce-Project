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
    
    # Insert order
    shipping_address = data.get('shipping_address', '')
    payment_method = data.get('payment_method', '')
    cur.execute('INSERT INTO orders (customer_id, total_amount, shipping_address, payment_method) VALUES (%s, %s, %s, %s)', 
                (customer_id, Decimal(0), shipping_address, payment_method))
    order_id = cur.lastrowid
    
    total_amount = Decimal(0)
    
    # Insert order items
    for product in products:
        product_id = product['product_id']
        quantity = product['quantity']
        
        unit_price = product['unit_price']
        item_total_price = unit_price * quantity
        total_amount += item_total_price
        
        cur.execute('INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES (%s, %s, %s, %s, %s)', 
                    (order_id, product_id, quantity, unit_price, item_total_price))
    
    # Update total_amount in orders
    cur.execute('UPDATE orders SET total_amount = %s WHERE order_id = %s', (total_amount, order_id))
    
    db.commit()
    
    # Update inventory via service
    for product in products:
        update_response = requests.put('http://localhost:5002/api/inventory/update', json={'product_id': product['product_id'], 'quantity_delta': -product['quantity']})
        if update_response.status_code != 200:
            # Log error, but order is created
            pass
    
    return jsonify({'order_id': order_id, 'total_amount': total_amount}), 201


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
    
    return jsonify(order)

if __name__ == '__main__':
    app.run(debug=True, port=5001, host='0.0.0.0')