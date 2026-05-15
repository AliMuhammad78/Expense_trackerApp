import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:money_tracker_001/models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'money_tracker.db');
    return await openDatabase(
      path,
      version: 3, // Bumping to version 3 to ensure the new icon columns are added
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Handle database schema updates
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Logic for old version 1 -> 2
      await db.execute('ALTER TABLE expenses ADD COLUMN userId INTEGER');
    }
    if (oldVersion < 3) {
      // Logic for version 2 -> 3: Adding the missing Icon columns to match the Model
      try {
        await db.execute('ALTER TABLE expenses ADD COLUMN categoryIconCode INTEGER');
        await db.execute('ALTER TABLE expenses ADD COLUMN categoryIconFont TEXT');
      } catch (e) {
        // Column might already exist if app was reinstalled
      }
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        userId INTEGER, 
        categoryId TEXT,
        categoryName TEXT,
        categoryIconCode INTEGER, -- Matches Transaction Model
        categoryIconFont TEXT,    -- Matches Transaction Model
        amount REAL,
        date TEXT,
        note TEXT,
        type INTEGER
      )
    ''');
  }

  // --- AUTH METHODS ---

  Future<int> registerUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<bool> checkEmailExists(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return res.isNotEmpty;
  }

  Future<User?> loginUser(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }

  // --- DATA FILTERING METHODS ---

  Future<List<Map<String, dynamic>>> getExpensesByUser(int userId) async {
    Database db = await database;
    return await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}