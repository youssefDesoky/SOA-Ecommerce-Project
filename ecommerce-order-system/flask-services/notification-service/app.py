from flask import Flask
import mysql.connector

app = Flask(__name__)
db = mysql.connector.connect(host='localhost', user='root', password='root', database='ecommerce_system')

@app.route('/notifications', methods=['GET'])
def get_notifications():
    cursor = db.cursor()
    cursor.execute("SELECT * FROM notification_log")
    return {'notifications': cursor.fetchall()}

if __name__ == '__main__':
    app.run(debug=True, port=5005, host='0.0.0.0')