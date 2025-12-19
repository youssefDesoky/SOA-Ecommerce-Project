from flask import Flask, jsonify, request
import mysql.connector

app = Flask(__name__)

def get_db_connection():
    return mysql.connector.connect(host='localhost', user='root', password='', database='ecommerce_system')

@app.route('/customers', methods=['GET'])
def get_customers():
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM customers")
    customers = cursor.fetchall()
    cursor.close()
    db.close()
    return jsonify({'customers': customers})

@app.route('/api/customers', methods=['POST'])
def create_customer():
    """Create a new customer or find existing by email"""
    data = request.get_json(silent=True) or {}
    
    first_name = data.get('first_name', '')
    last_name = data.get('last_name', '')
    # Combine first_name and last_name into 'name' to match database schema
    name = f"{first_name} {last_name}".strip()
    email = data.get('email', '')
    phone = data.get('phone', '')
    # Note: 'address' is stored in session/order, not in customers table
    
    if not email:
        return jsonify({'error': 'Email is required'}), 400
    
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    # Check if customer already exists by email
    cursor.execute("SELECT customer_id FROM customers WHERE email = %s", (email,))
    existing = cursor.fetchone()
    
    if existing:
        # Update existing customer info
        cursor.execute("""
            UPDATE customers SET name = %s, phone = %s 
            WHERE customer_id = %s
        """, (name, phone, existing['customer_id']))
        db.commit()
        customer_id = existing['customer_id']
    else:
        # Create new customer
        cursor.execute("""
            INSERT INTO customers (name, email, phone) 
            VALUES (%s, %s, %s)
        """, (name, email, phone))
        db.commit()
        customer_id = cursor.lastrowid
    
    cursor.close()
    db.close()
    
    return jsonify({'customer_id': customer_id}), 201

@app.route('/api/customers/<int:customer_id>', methods=['GET'])
def get_customer(customer_id):
    """Get customer by ID"""
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM customers WHERE customer_id = %s", (customer_id,))
    customer = cursor.fetchone()
    cursor.close()
    db.close()
    
    if not customer:
        return jsonify({'error': 'Customer not found'}), 404
    
    return jsonify(customer)

if __name__ == '__main__':
    app.run(debug=True, port=5004, host='0.0.0.0')
    