import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/model/meal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  // Private constructor
  DatabaseHelper._privateConstructor();

  // The single instance of the DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // The Database instance
  static Database? _database;

  // Getter for the database
  Future<Database> get database async {
    // Check if the database is already initialized
    if (_database != null) {
      return _database!;
    }
    // Initialize the database if it's not yet initialized
    _database = await _initDatabase();
    return _database!;
  }

  // Function to initialize the database
  Future<Database> _initDatabase() async {
    // Get the path to the database
    String path = join(await getDatabasesPath(), 'my_database.db');

    // Open the database and handle the creation or upgrade
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create the table
        await db.execute('''
          CREATE TABLE food_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            food_name TEXT,
            insertion_date TEXT NOT NULL,
            calorie_input REAL,
            portion INT,
            image_path TEXT
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          // In case of schema upgrade, handle changes here (if needed)
          // For instance, drop and recreate the table or modify schema
          await _dropTable(db);
          await _createTable(db);
        }
      },
    );
  }

  // Function to create the table
  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS food_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_name TEXT,
        insertion_date TEXT NOT NULL,
        calorie_input REAL,
        portion INT,
        image_path TEXT
      );
    ''');
  }

  // Function to drop the 'food_history' table
  Future<void> _dropTable(Database db) async {
    try {
      await db.execute('DROP TABLE IF EXISTS food_history');
    } catch (e) {
      AppLogger.instance.e("Error dropping table: $e");
    }
  }

  // Function to insert a new meal
  Future<int> insertMeal(Meal meal) async {
    Database db = await instance.database;
    return await db.insert(
      'food_history',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Function to retrieve meals
  Future<List<Map<String, dynamic>>> getMeals() async {
    Database db = await instance.database;
    try {
      return await db.query('food_history');
    } on DatabaseException catch (_, e) {
      AppLogger.instance.e("Error fetching meals: $e");
      // If the table doesn't exist, recreate it and return an empty list
      await _createTable(db);  // Recreate the table if it was dropped
      return [];
    }
  }

  // Function to update a meal
  Future<int> updateMeal(Meal meal, int id) async {
    Database db = await instance.database;
    return await db.update(
      'food_history',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Function to delete a meal
  Future<int> deleteMeal(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'food_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Function to clear all data (drop the table)
  void clearData() async {
    Database db = await instance.database;
    await _dropTable(db);
  }
}
