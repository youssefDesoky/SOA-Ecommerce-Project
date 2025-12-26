from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
import requests
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import sys
import os
from datetime import datetime, timedelta

# Add parent directory to path to import config
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from config import Config

app = Flask(__name__)
CORS(app)

# Service URLs from config
CUSTOMER_SERVICE_URL = Config.CUSTOMER_SERVICE_URL
INVENTORY_SERVICE_URL = Config.INVENTORY_SERVICE_URL
ORDER_SERVICE_URL = Config.ORDER_SERVICE_URL

# Email Configuration from config
SMTP_SERVER = Config.SMTP_SERVER
SMTP_PORT = Config.SMTP_PORT
SENDER_EMAIL = Config.SENDER_EMAIL
SENDER_PASSWORD = Config.SENDER_PASSWORD

def send_email(to_email, subject, body):
    """Send actual email using SMTP"""
    try:
        # Create message
        msg = MIMEMultipart()
        msg['From'] = SENDER_EMAIL
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'plain'))
        
        # Connect to SMTP server and send
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        server.send_message(msg)
        server.quit()
        
        print(f"\n{'='*50}")
        print(f"EMAIL SENT TO: {to_email}")
        print(f"Subject: {subject}")
        print(f"{'='*50}\n")
        return True
    except Exception as e:
        print(f"\n{'='*50}")
        print(f"EMAIL FAILED TO SEND: {str(e)}")
        print(f"Falling back to simulation...")
        print(f"EMAIL SIMULATED TO: {to_email}")
        print(f"Subject: {subject}")
        print(f"Body: {body}")
        print(f"{'='*50}\n")
        return False

def get_db_connection():
    return mysql.connector.connect(**Config.get_db_config())

def serialize_notification(notification):
    """Convert notification data to JSON-serializable format"""
    if notification:
        result = dict(notification)
        if result.get('sent_at'):
            result['sent_at'] = str(result['sent_at'])
        return result
    return None

# ==================== REQUIRED ENDPOINTS ====================

# POST /api/notifications/send - Send order notification
@app.route('/api/notifications/send', methods=['POST'])
def send_notification():
    """
    Send order notification - SERVICE COMPOSITION
    1. Receive order_id from request
    2. GET Customer Service (retrieve email/phone)
    3. GET Inventory Service (check stock status)
    4. Generate notification message
    5. Log to database
    6. Return success confirmation
    """
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    try:
        data = request.get_json(silent=True) or {}
        order_id = data.get('order_id')
        notification_type = data.get('notification_type', 'email')  # email or sms
        
        if not order_id:
            return jsonify({'error': 'order_id is required'}), 400
        
        # Step 1: Get order details from Order Service to find customer_id and product info
        try:
            order_response = requests.get(f"{ORDER_SERVICE_URL}/{order_id}", timeout=10)
            if order_response.status_code != 200:
                return jsonify({'error': 'Order not found'}), 404
            order_data = order_response.json()
            customer_id = order_data.get('customer_id')
            total_amount = order_data.get('total_amount', 0)
            order_status = order_data.get('status', 'pending')
            order_items = order_data.get('items', [])
            order_date_str = order_data.get('order_date', '')
            
            # Calculate estimated delivery date (order_date + 4 days)
            try:
                if order_date_str:
                    order_date = datetime.strptime(order_date_str.split(' ')[0], '%Y-%m-%d')
                else:
                    order_date = datetime.now()
                estimated_delivery = order_date + timedelta(days=4)
                estimated_delivery_str = estimated_delivery.strftime('%B %d, %Y')
            except:
                estimated_delivery_str = (datetime.now() + timedelta(days=4)).strftime('%B %d, %Y')
        except requests.exceptions.RequestException as e:
            return jsonify({'error': f'Order Service unavailable: {str(e)}'}), 503
        
        # Step 2: GET Customer Service (retrieve email/phone)
        try:
            customer_response = requests.get(f"{CUSTOMER_SERVICE_URL}/{customer_id}", timeout=10)
            if customer_response.status_code != 200:
                return jsonify({'error': 'Customer not found'}), 404
            customer_data = customer_response.json()
            customer_email = customer_data.get('email')
            customer_phone = customer_data.get('phone')
            customer_name = customer_data.get('name')
        except requests.exceptions.RequestException as e:
            return jsonify({'error': f'Customer Service unavailable: {str(e)}'}), 503
        
        # Step 3: GET Inventory Service for product names
        items_details = []
        for item in order_items:
            product_id = item.get('product_id')
            quantity = item.get('quantity')
            item_total = item.get('total_price', 0)
            product_name = f"Product #{product_id}"
            
            try:
                inventory_response = requests.get(f"{INVENTORY_SERVICE_URL}/check/{product_id}", timeout=10)
                if inventory_response.status_code == 200:
                    inventory_data = inventory_response.json()
                    product_name = inventory_data.get('product_name', product_name)
            except requests.exceptions.RequestException:
                pass
            
            items_details.append({
                'name': product_name,
                'quantity': quantity,
                'total': item_total
            })
        
        # Step 4: Generate notification message with order items
        items_text = "\n".join([
            f"  - {item['name']} (x{item['quantity']}): ${item['total']}"
            for item in items_details
        ])
        
        notification_message = f"""Dear {customer_name},

Your order #{order_id} is {order_status}!

Order Details:
{items_text}

Total Amount: ${total_amount}
Estimated Delivery: {estimated_delivery_str}

Thank you for shopping with us!"""
        
        # Send notification based on type
        if notification_type == 'email':
            # Send actual email
            subject = f"Order #{order_id} Confirmation - Nexus"
            send_email(customer_email, subject, notification_message)
        else:
            # SMS: Simulate with console output (will also show in browser console)
            print("\n" + "="*50)
            print(f"SMS SENT TO: {customer_phone}")
            print(f"Message: {notification_message}")
            print("="*50 + "\n")
        
        # Step 5: Log to database
        cursor.execute("""
            INSERT INTO notification_log (order_id, customer_id, notification_type, message)
            VALUES (%s, %s, %s, %s)
        """, (order_id, customer_id, notification_type, notification_message))
        db.commit()
        
        notification_id = cursor.lastrowid
        
        # Step 6: Return success confirmation (include notification_message for SMS browser display)
        return jsonify({
            'success': True,
            'notification_id': notification_id,
            'order_id': order_id,
            'customer_id': customer_id,
            'notification_type': notification_type,
            'recipient': customer_email if notification_type == 'email' else customer_phone,
            'notification_message': notification_message,
            'message': 'Notification sent successfully'
        }), 201
        
    except mysql.connector.Error as err:
        db.rollback()
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        db.close()

# GET /api/notifications/customer/<customer_id> - Get customer notifications
@app.route('/api/notifications/customer/<int:customer_id>', methods=['GET'])
def get_customer_notifications(customer_id):
    """Get all notifications for a specific customer"""
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    try:
        cursor.execute("""
            SELECT notification_id, order_id, customer_id, notification_type, message, sent_at
            FROM notification_log
            WHERE customer_id = %s
            ORDER BY sent_at DESC
        """, (customer_id,))
        notifications = cursor.fetchall()
        
        # Serialize notifications
        serialized = [serialize_notification(n) for n in notifications]
        
        return jsonify(serialized), 200
        
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        db.close()


if __name__ == '__main__':
    app.run(debug=Config.DEBUG, port=Config.NOTIFICATION_SERVICE_PORT, host=Config.HOST)