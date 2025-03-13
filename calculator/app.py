from flask import Flask, render_template, request

app = Flask(__name__)

class BudgetCalculator:
    def __init__(self):
        self.incomes = []
        self.expenses = []

    def add_income(self, amount, description):
        self.incomes.append({'amount': amount, 'description': description})

    def add_expense(self, amount, description):
        self.expenses.append({'amount': amount, 'description': description})

    def calculate_total_income(self):
        total_income = sum(item['amount'] for item in self.incomes)
        return total_income

    def calculate_total_expense(self):
        total_expense = sum(item['amount'] for item in self.expenses)
        return total_expense

    def calculate_balance(self):
        total_income = self.calculate_total_income()
        total_expense = self.calculate_total_expense()
        balance = total_income - total_expense
        return balance

    def get_incomes(self):
        return self.incomes

    def get_expenses(self):
        return self.expenses

budget_calculator = BudgetCalculator()

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        action = request.form['action']
        if action == 'income':
            amount = float(request.form['amount'])
            description = request.form['description']
            budget_calculator.add_income(amount, description)
        elif action == 'expense':
            amount = float(request.form['amount'])
            description = request.form['description']
            budget_calculator.add_expense(amount, description)
    
    total_income = budget_calculator.calculate_total_income()
    total_expense = budget_calculator.calculate_total_expense()
    balance = budget_calculator.calculate_balance()
    incomes = budget_calculator.get_incomes()
    expenses = budget_calculator.get_expenses()

    return render_template('index.html', total_income=total_income, total_expense=total_expense, balance=balance, incomes=incomes, expenses=expenses)

if __name__ == '__main__':
    app.run(debug=True)
