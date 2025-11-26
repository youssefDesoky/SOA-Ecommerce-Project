from flask import Flask
import mysql.connector

app = Flask(__name__)
db = mysql.connector.connect(host='localhost', user='root', password='root', database='ecommerce_system')

@app.route('/orders', methods=['GET'])
def get_orders():
    return {'orders': ["order1", "order2", "order3"]}

if __name__ == '__main__':
    app.run(debug=True, port=5001)