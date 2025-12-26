from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
import requests

app = Flask(__name__)
CORS(app)

# Order Service URL for service composition
ORDER_SERVICE_URL = "http://localhost:5001/api/orders"

def get_db_connection():
    return mysql.connector.connect(
        host='localhost', 
        user='root', 
        password='', 
        database='ecommerce_system'
    )

def serialize_customer(customer):
    """Convert customer data to JSON-serializable format"""
    if customer:
        result = dict(customer)
        if result.get('created_at'):
            result['created_at'] = str(result['created_at'])
        return result
    return None

# ==================== REQUIRED ENDPOINTS ====================

# GET /api/customers/{customer_id} - Get customer profile
@app.route('/api/customers/<int:customer_id>', methods=['GET'])
def get_customer(customer_id):
    """Get customer profile by ID"""
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    try:
        cursor.execute("""
            SELECT customer_id, name, email, phone, loyalty_points, created_at 
            FROM customers 
            WHERE customer_id = %s
        """, (customer_id,))
        customer = cursor.fetchone()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
        
        return jsonify(serialize_customer(customer)), 200
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        db.close()

# GET /api/customers/{customer_id}/orders - Get order history (calls Order Service)
@app.route('/api/customers/<int:customer_id>/orders', methods=['GET'])
def get_customer_orders(customer_id):
    """
    Get customer order history by calling Order Service.
    This is SERVICE COMPOSITION - combines data from Customer DB + Order Service
    """
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    try:
        # Step 1: Verify customer exists in our database
        cursor.execute("""
            SELECT customer_id, name, email 
            FROM customers 
            WHERE customer_id = %s
        """, (customer_id,))
        customer = cursor.fetchone()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
        
        # Step 2: Call Order Service to get order history
        try:
            response = requests.get(
                ORDER_SERVICE_URL,
                params={'customer_id': customer_id},
                timeout=10
            )
            
            if response.status_code == 200:
                orders_data = response.json()
                orders = orders_data if isinstance(orders_data, list) else orders_data.get('orders', [])
            else:
                orders = []
                
        except requests.exceptions.RequestException as e:
            return jsonify({
                'customer_id': customer_id,
                'customer_name': customer['name'],
                'orders': [],
                'error': 'Order Service unavailable: ' + str(e)
            }), 200
        
        return jsonify({
            'customer_id': customer_id,
            'customer_name': customer['name'],
            'customer_email': customer['email'],
            'orders': orders
        }), 200
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        db.close()

# PUT /api/customers/{customer_id}/loyalty - Update loyalty points
@app.route('/api/customers/<int:customer_id>/loyalty', methods=['PUT'])
def update_loyalty_points(customer_id):
    """Update customer loyalty points"""
    data = request.get_json(silent=True) or {}
    
    if 'loyalty_points' not in data:
        return jsonify({'error': 'loyalty_points field is required'}), 400
    
    try:
        loyalty_points = int(data['loyalty_points'])
        if loyalty_points < 0:
            return jsonify({'error': 'loyalty_points cannot be negative'}), 400
    except (ValueError, TypeError):
        return jsonify({'error': 'loyalty_points must be a valid integer'}), 400
    
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT customer_id, loyalty_points FROM customers WHERE customer_id = %s", (customer_id,))
        customer = cursor.fetchone()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
        
        old_points = customer['loyalty_points'] or 0
        
        cursor.execute("UPDATE customers SET loyalty_points = %s WHERE customer_id = %s", (loyalty_points, customer_id))
        db.commit()
        
        return jsonify({
            'message': 'Loyalty points updated successfully',
            'customer_id': customer_id,
            'old_points': old_points,
            'new_points': loyalty_points
        }), 200
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        db.close()

# ==================== ADDITIONAL ENDPOINTS ====================

# GET /api/customers/email/{email} - Get customer by email (for lookup)
@app.route('/api/customers/email/<path:email>', methods=['GET'])
def get_customer_by_email(email):
    """Get customer profile by email address"""
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    try:
        cursor.execute("""
            SELECT customer_id, name, email, phone, loyalty_points, created_at 
            FROM customers 
            WHERE email = %s
        """, (email,))
        customer = cursor.fetchone()
        
        if not customer:
            return jsonify({'error': 'Customer not found'}), 404
        
        return jsonify(serialize_customer(customer)), 200
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        db.close()

# POST /api/customers - Create a new customer (or return existing)
@app.route('/api/customers', methods=['POST'])
def create_customer():
    """Create a new customer or return existing one by email"""
    data = request.get_json(silent=True) or {}
    
    # Support both 'name' and 'first_name'/'last_name' formats
    name = data.get('name', '').strip()
    if not name:
        first_name = data.get('first_name', '').strip()
        last_name = data.get('last_name', '').strip()
        name = f"{first_name} {last_name}".strip()
    
    email = data.get('email', '').strip()
    phone = data.get('phone', '').strip()
    
    if not email:
        return jsonify({'error': 'Email is required'}), 400
    if not name:
        return jsonify({'error': 'Name is required (provide name or first_name/last_name)'}), 400
    
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    try:
        # Check if customer already exists by email
        cursor.execute("SELECT customer_id, name FROM customers WHERE email = %s", (email,))
        existing = cursor.fetchone()
        
        if existing:
            # Return existing customer (200 OK so order can proceed)
            return jsonify({
                'message': 'Customer found',
                'customer_id': existing['customer_id'],
                'name': existing['name']
            }), 200
        
        # Create new customer
        cursor.execute("INSERT INTO customers (name, email, phone, loyalty_points) VALUES (%s, %s, %s, 0)", (name, email, phone))
        db.commit()
        
        return jsonify({'message': 'Customer created', 'customer_id': cursor.lastrowid}), 201
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        db.close()

# GET /api/customers - Get all customers
@app.route('/api/customers', methods=['GET'])
def get_all_customers():
    """Get all customers"""
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT customer_id, name, email, phone, loyalty_points, created_at FROM customers")
        customers = cursor.fetchall()
        return jsonify([serialize_customer(c) for c in customers]), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        db.close()

if __name__ == '__main__':
    print("=" * 50)
    print("Customer Service running on port 5004")
    print("=" * 50)
    print("Required Endpoints:")
    print("  GET  /api/customers/{id}         - Get customer profile")
    print("  GET  /api/customers/{id}/orders  - Get order history (calls Order Service)")
    print("  PUT  /api/customers/{id}/loyalty - Update loyalty points")
    print("Additional Endpoints:")
    print("  GET  /api/customers/email/{email} - Get customer by email")
    print("  POST /api/customers              - Create new customer")
    print("  GET  /api/customers              - Get all customers")
    print("=" * 50)
    app.run(debug=True, port=5004, host='0.0.0.0')
    