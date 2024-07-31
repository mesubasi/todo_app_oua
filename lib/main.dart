import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> _todoItems = [];

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  Future<void> _loadTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListString = prefs.getString('todoList');
    if (todoListString != null) {
      final todoList = jsonDecode(todoListString) as List;
      setState(() {
        _todoItems = todoList.map((item) => TodoItem.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListString = jsonEncode(_todoItems);
    prefs.setString('todoList', todoListString);
  }

  void _addTodoItem(String task) {
    if (task.isNotEmpty) {
      setState(() {
        _todoItems.add(TodoItem(task: task));
      });
      _saveTodoItems();
    }
  }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index].isDone = !_todoItems[index].isDone;
    });
    _saveTodoItems();
  }

  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
    _saveTodoItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List', style: GoogleFonts.lato(fontSize: 24)),
      ),
      body: Column(
        children: <Widget>[
          _buildAddTodoItem(),
          Expanded(
            child: _buildTodoList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTodoItem() {
    final TextEditingController _controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add a task',
                labelStyle: GoogleFonts.lato(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              _addTodoItem(_controller.text);
              _controller.clear();
            },
            child: Icon(Icons.add),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(16),
              backgroundColor: Colors.blue, // Button color
              foregroundColor: Colors.white, // Text color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoItems.length,
      itemBuilder: (context, index) {
        return _buildTodoItem(_todoItems[index], index);
      },
    );
  }

  Widget _buildTodoItem(TodoItem todoItem, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          todoItem.task,
          style: GoogleFonts.lato(
            decoration: todoItem.isDone ? TextDecoration.lineThrough : null,
            fontSize: 18,
          ),
        ),
        leading: Checkbox(
          value: todoItem.isDone,
          onChanged: (bool? value) {
            _toggleTodoItem(index);
          },
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _deleteTodoItem(index);
          },
        ),
      ),
    );
  }
}

class TodoItem {
  String task;
  bool isDone;

  TodoItem({required this.task, this.isDone = false});

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      task: json['task'],
      isDone: json['isDone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'isDone': isDone,
    };
  }
}
