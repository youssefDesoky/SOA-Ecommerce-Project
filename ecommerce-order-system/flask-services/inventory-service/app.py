from flask import Flask
import mysql.connector

app = Flask(__name__)
db = mysql.connector.connect(host='localhost', user='root', password='', database='ecommerce_system')

@app.route('/inventory', methods=['GET'])
def get_inventory():
    cursor = db.cursor()
    cursor.execute("SELECT * FROM inventory")
    return {'inventory': cursor.fetchall()}

if __name__ == '__main__':
    app.run(debug=True, port   =5002)