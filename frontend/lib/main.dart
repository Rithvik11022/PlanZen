import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(home: TodoApp()));

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List tasks = [];
  TextEditingController controller = TextEditingController();

  final String baseUrl = "http://localhost:4000";

  // 📥 Fetch tasks from backend
  Future<void> fetchTasks() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/tasks'));
      if (res.statusCode == 200) {
        setState(() {
          tasks = json.decode(res.body);
        });
      }
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }

  // ➕ Add a new task
  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title}),
      );
      if (res.statusCode == 200) {
        controller.clear();
        fetchTasks();
      }
    } catch (e) {
      print("Error adding task: $e");
    }
  }

  // ✅ Toggle is_done
  Future<void> toggleDone(int id) async {
    try {
      await http.put(Uri.parse('$baseUrl/tasks/$id'));
      fetchTasks();
    } catch (e) {
      print("Error toggling task: $e");
    }
  }

  // ❌ Delete task
  Future<void> deleteTask(int id) async {
    try {
      await http.delete(Uri.parse('$baseUrl/tasks/$id'));
      fetchTasks();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("To-Do")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Enter task",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  child: Text("Add"),
                  onPressed: () => addTask(controller.text),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) {
                final task = tasks[i];
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: task['is_done'] == 1,
                      onChanged: (_) => toggleDone(task['id']),
                    ),
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        decoration: task['is_done'] == 1
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteTask(task['id']),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
