from flask import Flask,jsonify,request
from flask_cors import CORS
import mysql.connector
import sys
import os

# Add parent directory to path to import config
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import Config

app = Flask(__name__)
CORS(app)

def get_db_connection():
    return mysql.connector.connect(**Config.get_db_config())

@app.get('/api/inventory/check/<int:product_id>')
def check_inventory(product_id):
    db = get_db_connection()
    cur = db.cursor(dictionary = True)
    cur.execute("Select product_id, product_name, quantity_available, unit_price, product_image_url From inventory where product_id = %s",(product_id,))
    row = cur.fetchone()
    cur.close()
    db.close()
    
    if not row: 
        return jsonify({"error": "not found"}), 404
    
    return jsonify(row)

@app.get('/api/inventory')
def get_inventory():
    db = get_db_connection()
    cur = db.cursor(dictionary = True)
    cur.execute("Select product_id, product_name, quantity_available, unit_price, product_image_url from inventory")
    row = cur.fetchall()
    cur.close()
    db.close()

    return jsonify(row)
    

@app.put('/api/inventory/update')
def update_inventory():
    data = request.get_json(silent=True) or {}
    product_id=data.get('product_id')
    quantity_delta = data.get('quantity_delta')
    
    if not isinstance(product_id, int) or not isinstance(quantity_delta, int):
        return jsonify({'error': 'not found'}), 404
    
    db = get_db_connection()
    cur = db.cursor()
    cur.execute('Update inventory Set quantity_available = quantity_available + %s where product_id = %s', (quantity_delta, product_id))
    
    if cur.rowcount==0:
        db.rollback()
        cur.close()
        db.close()
        return jsonify({"error": "not found"}), 404
    
    db.commit()
    cur.close()
    db.close()
    return jsonify({'status': 'updated'})

if __name__ == '__main__':
    app.run(debug=Config.DEBUG, port=Config.INVENTORY_SERVICE_PORT, host=Config.HOST)