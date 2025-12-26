from flask import Flask, jsonify, request
import mysql.connector
import requests
from decimal import Decimal
import sys
import os

# Add parent directory to path to import config
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import Config

app = Flask(__name__)

def get_db_connection():
    return mysql.connector.connect(**Config.get_db_config())

@app.route('/pricing', methods=['GET'])
def get_pricing():
    db = get_db_connection()
    cursor = db.cursor()
    cursor.execute("SELECT * FROM pricing_rules")
    result = cursor.fetchall()
    cursor.close()
    db.close()
    return {'pricing': result}

#POST /api/pricing/calculate - Calculate order total
@app.route('/api/pricing/calculate', methods=['POST'])
def calculate_pricing():
    data = request.get_json(silent=True) or {}
    products = data.get('products', [])
    region = data.get('region', '')

    if not products:
        return jsonify({'error': 'no products provided'}), 400

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    items = []
    subtotal = Decimal(0)
    
    # Get tax rate based on region
    if region and region.strip():
        cursor.execute('SELECT tax_rate FROM tax_rates WHERE region = %s', (region,))
        tax_row = cursor.fetchone()
        tax_rate = (Decimal(tax_row['tax_rate']) / 100) if tax_row else Decimal(0) # Default to 0% if region not found
    else:
        tax_rate = Decimal(0) # Default tax rate if no region provided

    for product in products:
        product_id = product.get('product_id')
        quantity = product.get('quantity')
        unit_price = Decimal(product.get('unit_price'))
        if not isinstance(product_id, int) or not isinstance(quantity, int):
            return jsonify({'error': 'invalid product data'}), 400

        total = unit_price * quantity

        # Check for discount based on min_quantity
        cursor.execute('SELECT discount_percentage FROM pricing_rules WHERE product_id = %s AND min_quantity <= %s ORDER BY min_quantity DESC LIMIT 1', (product_id, quantity))
        discount_row = cursor.fetchone()
        discount_percent = Decimal(discount_row['discount_percentage']) if discount_row else Decimal(0)
        discounted_total = total * (Decimal(1) - discount_percent / Decimal(100))

        subtotal += discounted_total

        items.append({
            'product_id': product_id,
            'quantity': quantity,
            'unit_price': unit_price,
            'total_before_discount': total,
            'discount_percent': discount_percent,
            'discounted_total': discounted_total
        })

    tax = subtotal * tax_rate
    total = subtotal + tax

    return jsonify({
        'items': items,
        'subtotal': subtotal,
        'tax': tax,
        'total': total
    }), 200

if __name__ == '__main__':
    app.run(debug=Config.DEBUG, port=Config.PRICING_SERVICE_PORT, host=Config.HOST)