from bottle import route, run, template, request

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

budget_calculator = BudgetCalculator()

@route('/')
def index():
    return '''
        <h1>Budget Calculator</h1>
        <form action="/" method="post">
            <h2>Add Income</h2>
            Amount: <input type="number" step="0.01" name="amount" required><br>
            Description: <input type="text" name="description" required><br>
            <input type="submit" name="action" value="Add Income">
        </form>
        <form action="/" method="post">
            <h2>Add Expense</h2>
            Amount: <input type="number" step="0.01" name="amount" required><br>
            Description: <input type="text" name="description" required><br>
            <input type="submit" name="action" value="Add Expense">
        </form>
        <h2>Summary</h2>
        <p>Total Income: {{ total_income }}</p>
        <p>Total Expenses: {{ total_expense }}</p>
        <p>Balance: {{ balance }}</p>
    '''

@route('/', method='POST')
def do_actions():
    action = request.forms.get('action')
    amount = float(request.forms.get('amount'))
    description = request.forms.get('description')

    if action == 'Add Income':
        budget_calculator.add_income(amount, description)
    elif action == 'Add Expense':
        budget_calculator.add_expense(amount, description)

    total_income = budget_calculator.calculate_total_income()
    total_expense = budget_calculator.calculate_total_expense()
    balance = budget_calculator.calculate_balance()

    return template('''
        <h1>Budget Calculator</h1>
        <form action="/" method="post">
            <h2>Add Income</h2>
            Amount: <input type="number" step="0.01" name="amount" required><br>
            Description: <input type="text" name="description" required><br>
            <input type="submit" name="action" value="Add Income">
        </form>
        <form action="/" method="post">
            <h2>Add Expense</h2>
            Amount: <input type="number" step="0.01" name="amount" required><br>
            Description: <input type="text" name="description" required><br>
            <input type="submit" name="action" value="Add Expense">
        </form>
        <h2>Summary</h2>
        <p>Total Income: {{ total_income }}</p>
        <p>Total Expenses: {{ total_expense }}</p>
        <p>Balance: {{ balance }}</p>
    ''', total_income=total_income, total_expense=total_expense, balance=balance)

if __name__ == '__main__':
    run(host='localhost', port=8080, debug=True)
