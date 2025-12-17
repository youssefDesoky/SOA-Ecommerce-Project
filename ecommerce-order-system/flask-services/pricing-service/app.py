from flask import Flask
import mysql.connector

app = Flask(__name__)
db = mysql.connector.connect(host='localhost', user='root', password='root', database='ecommerce_system')

@app.route('/pricing', methods=['GET'])
def get_pricing():
    cursor = db.cursor()
    cursor.execute("SELECT * FROM pricing_rules")
    return {'pricing': cursor.fetchall()}
if __name__ == '__main__':
    app.run(debug=True, port=5003, host='0.0.0.0')