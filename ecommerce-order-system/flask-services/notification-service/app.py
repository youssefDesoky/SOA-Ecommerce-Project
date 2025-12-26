from flask import Flask, jsonify
import mysql.connector

app = Flask(__name__)
db = mysql.connector.connect(host='localhost', user='root', password='', database='ecommerce_system')
db = mysql.connector.connect(host='localhost', user='root', password='', database='ecommerce_system')

# GET /api/notifications/customer/<customer_id>
@app.get('/api/notifications/customer/<int:customer_id>')
def get_customer_notifications(customer_id):
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT notification_id, order_id, notification_type, message, sent_at
        FROM notification_log
        WHERE customer_id = %s
        ORDER BY sent_at DESC
    """, (customer_id,))
    notifications = cursor.fetchall()
    return jsonify(notifications), 200


if __name__ == '__main__':
    app.run(debug=True, port=5005, host='0.0.0.0')