import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String tableName = 'todos';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnDescription = 'description';
final String columnIsDone = 'is_done';

class Todo {
  final int id;
  final String title;
  final String description;
  bool isDone;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_done': isDone ? 1 : 0,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone: map['is_done'] == 1,
    );
  }
}