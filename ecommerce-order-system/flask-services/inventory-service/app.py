from flask import Flask,jsonify,request
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)
db = mysql.connector.connect(host='localhost', user='root', password='root', database='ecommerce_system')

@app.get('/api/inventory/check/<int:product_id>')
def check_inventory(product_id):
    cur = db.cursor(dictionary = True)
    cur.execute("Select product_id, product_name, quantity_available, unit_price, product_image_url From inventory where product_id = %s",(product_id,))
    row = cur.fetchone()
    
    if not row: 
        return jsonify({"error": "not found"}), 404
    
    return jsonify(row)

@app.get('/api/inventory')
def get_inventory():
    cur = db.cursor(dictionary = True)
    cur.execute("Select product_id, product_name, quantity_available, unit_price, product_image_url from inventory")
    row = cur.fetchall()

    return jsonify(row)
    

@app.put('/api/inventory/update')
def update_inventory():
    data = request.get_json(silent=True) or {}
    product_id=data.get('product_id')
    quantity_delta = data.get('quantity_delta')
    
    if not isinstance(product_id, int) or not isinstance(quantity_delta, int):
        return jsonify({'error': 'not found'}), 404
    cur = db.cursor()
    cur.execute('Update inventory Set quantity_available = quantity_available + %s where product_id = %s', (quantity_delta, product_id))
    
    if cur.rowcount==0:
        db.rollback()
        return jsonify({"error": "not found"}), 404
    
    db.commit()
    return jsonify({'status': 'updated'})

if __name__ == '__main__':
    app.run(debug=True, port=5002, host='0.0.0.0')