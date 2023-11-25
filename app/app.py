from flask import Flask, request, render_template_string

app = Flask(__name__)

# In-memory storage for tasks
tasks = []

# HTML template string for the frontend
html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>To-Do List</title>
</head>
<body>
    <h2>To-Do List</h2>
    <form method="POST" action="/add">
        <input type="text" name="task" />
        <input type="submit" value="Add Task" />
    </form>
    <ul>
        {% for task in tasks %}
            <li>{{ task }}</li>
        {% endfor %}
    </ul>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(html_template, tasks=tasks)

@app.route('/add', methods=['POST'])
def add_task():
    task = request.form.get('task')
    if task:
        tasks.append(task)
    return index()

if __name__ == '__main__':
    app.run(debug=True)
