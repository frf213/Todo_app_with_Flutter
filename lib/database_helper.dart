import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/todo_model.dart'; // Import the Todo class

final String tableName = 'todos';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnDescription = 'description';
final String columnIsDone = 'is_done';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY';
    final textType = 'TEXT NOT NULL';
    final boolType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE $tableName (
        $columnId $idType,
        $columnTitle $textType,
        $columnDescription $textType,
        $columnIsDone $boolType
      )
    ''');
  }

  Future<int> insert(Todo todo) async {
    final db = await instance.database;
    return await db.insert(tableName, todo.toMap());
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (index) {
      return Todo.fromMap(maps[index]);
    });
  }

  Future<Todo?> getTodoItem(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Todo todo) async {
    final db = await instance.database;
    final id = todo.id;
    return await db.update(
      tableName,
      todo.toMap(),
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}