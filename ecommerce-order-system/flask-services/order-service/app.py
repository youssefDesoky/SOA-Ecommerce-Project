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
        
        cur.execute('SELECT quantity_available FROM inventory WHERE product_id = %s', (product_id,))
        stock_row = cur.fetchone()
        if not stock_row or stock_row[0] < quantity:
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
        
        # Get unit_price from inventory
        cur.execute('SELECT unit_price FROM inventory WHERE product_id = %s', (product_id,))
        price_row = cur.fetchone()
        unit_price = price_row[0]
        item_total_price = unit_price * quantity
        total_amount += item_total_price
        
        cur.execute('INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES (%s, %s, %s, %s, %s)', 
                    (order_id, product_id, quantity, unit_price, item_total_price))
        
        # Update inventory quantity
        cur.execute('UPDATE inventory SET quantity_available = quantity_available - %s WHERE product_id = %s', 
                    (quantity, product_id))
    
    # Update total_amount in orders
    cur.execute('UPDATE orders SET total_amount = %s WHERE order_id = %s', (total_amount, order_id))
    
    db.commit()
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
    app.run(debug=True, port=5001)