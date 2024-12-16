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

    // Open the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Example: Create a table
        await db.execute('''
          CREATE TABLE food_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            food_name TEXT,
            insertion_date TEXT NOT NULL,
            calorie_input REAL,
            portion INT,
          )
        ''');
      },
    );
  }

  Future<int> insertMeal(Meal meal) async {
  Database db = await instance.database;

  return await db.insert(
    'food_history',
    meal.toMap(), // Convert the Meal object to a Map
    conflictAlgorithm: ConflictAlgorithm.replace, // Handle conflicts (optional)
  );
}


  // Query method example
  Future<List<Map<String, dynamic>>> getMeals() async {
    Database db = await instance.database;
    return await db.query('food_history');
  }

  Future<int> updateMeal(Meal meal) async {
    Database db = await instance.database;

    return await db.update(
      'food_history',
      meal.toMap(), // Convert the Meal object to a Map
      where: 'id = ?', // Specify the where condition
      whereArgs: [meal.id], // Pass the ID as an argument for the query
    );
  }

  // Delete method example
  Future<int> deleteMeal(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'food_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
