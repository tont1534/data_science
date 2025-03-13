from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# Список продуктов и их цен
products = {
    'Яблоко': 2.00,
    'Банан': 1.50,
    'Молоко': 3.00,
    # Добавьте другие продукты здесь
}

# Список для хранения выбранных продуктов пользователем
cart = []

@app.route('/')
def index():
    return render_template('index.html', products=products)

@app.route('/add_to_cart', methods=['POST'])
def add_to_cart():
    product = request.form['product']
    cart.append(product)
    return redirect(url_for('index'))

@app.route('/cart')
def view_cart():
    total_price = sum(products[item] for item in cart)
    return render_template('cart.html', cart=cart, total_price=total_price)

if __name__ == '__main__':
    app.run(debug=True)
