from flask import Flask
import mysql.connector

app = Flask(__name__)
db = mysql.connector.connect(host='localhost', user='root', password='root', database='ecommerce_system')

@app.route('/customers', methods=['GET'])
def get_customers():
    cursor = db.cursor()
    cursor.execute("SELECT * FROM customers")
    return {'customers': cursor.fetchall()}

if __name__ == '__main__':
    app.run(debug=True, port=5004, host='0.0.0.0')
    