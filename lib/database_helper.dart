// database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      p.join(await getDatabasesPath(), 'tasks_database.db'),
      version: 2, // Updated version number
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE IF NOT EXISTS tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            title TEXT, 
            description TEXT, 
            deadline TEXT, 
            isCompleted INTEGER
          )
          ''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migration code
          await db.execute('ALTER TABLE tasks RENAME TO old_tasks');
          await db.execute(
            '''
            CREATE TABLE tasks(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              title TEXT, 
              description TEXT, 
              deadline TEXT, 
              isCompleted INTEGER
            )
            '''
          );
          await db.execute(
            '''
            INSERT INTO tasks (id, title, description, deadline, isCompleted)
            SELECT id, name, description, deadline, isCompleted FROM old_tasks
            '''
          );
          await db.execute('DROP TABLE old_tasks');
        }
      },
    );
  }
}
