import 'package:flutter/material.dart';
import 'package:to_do_app/database_helper.dart';
import 'package:to_do_app/todo_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.deepOrangeAccent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  late DatabaseHelper _databaseHelper;
  late List<Todo> _todoList;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper.instance;
    _refreshTodoList();
  }

  void _refreshTodoList() async {
    List<Todo> todoList = await _databaseHelper.getAllTodos();
    setState(() {
      _todoList = todoList;
    });
  }

  void _addTodo() async {
    String todoText = _textEditingController.text.trim();
    if (todoText.isNotEmpty) {
      Todo todo = Todo(
        id: DateTime.now().millisecondsSinceEpoch,
        title: todoText,
        description: '',
        isDone: false,
      );
      await _databaseHelper.insert(todo);
      _textEditingController.clear();
      _refreshTodoList();
    }
  }

  void _updateTodoStatus(int todoId, bool isDone) async {
    Todo? todo = await _databaseHelper.getTodoItem(todoId);
    if (todo != null) {
      todo.isDone = isDone;
      await _databaseHelper.update(todo);
      _refreshTodoList();
    }
  }

  void _deleteTodoItem(int todoId) async {
    Todo? todo = await _databaseHelper.getTodoItem(todoId);
    if (todo != null) {
      await _databaseHelper.delete(todoId);
      _refreshTodoList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _textEditingController,
              style: TextStyle(
                color: Colors.white, // Set the text color
              ),
              decoration: InputDecoration(
                labelText: 'Todo',
                labelStyle: TextStyle(
                  color: Colors.white70, // Set the label text color
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Set the border radius
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurpleAccent, // Set the border color
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepOrangeAccent, // Set the focused border color
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onSubmitted: (value) {
                _addTodo();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                Todo todo = _todoList[index];
                return ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isDone ? TextDecoration.lineThrough : null,
                      color: todo.isDone ? Colors.grey : Colors.black, // Set the text color
                    ),
                  ),
                  leading: Checkbox(
                    value: todo.isDone,
                    onChanged: (value) {
                      _updateTodoStatus(todo.id, value ?? false);
                    },
                    activeColor: Colors.deepPurpleAccent, // Set the checkbox color
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteTodoItem(todo.id);
                    },
                    color: Colors.deepOrangeAccent, // Set the icon color
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}