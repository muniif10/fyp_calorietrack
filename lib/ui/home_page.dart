import 'package:calorie_track/helper/database.dart';
import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/helper/meal_helpers.dart';
import 'package:calorie_track/model/meal.dart';
import 'package:calorie_track/ui/cards/meals_eaten_card.dart';
import 'package:calorie_track/ui/cards/nutrition_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../ui/const.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}

class _HomePageState extends State<HomePage> {
  int touchedIndex = -1;
  List<Meal> mealList = [];
  Future<List<Meal>> getMealsHistory() async {
    DatabaseHelper db = DatabaseHelper.instance;
    List<Map<String, dynamic>> out;
    try {
      out = await db.getMeals(); // Fetch meals from DB
    } on DatabaseException catch (e) {
      // Log the error (optional)
      AppLogger.instance.e("Database error:", error: e);
      return []; // Return an empty list if there's an exception
    }

    // Convert the database results (List<Map<String, dynamic>>) to a List<Meal>
    List<Meal> history = out.map((mealData) => Meal.fromMap(mealData)).toList();

    return history;
  }

  late Future<List<Meal>> mealHistoryFuture;

  @override
  void initState() {
    super.initState();
    mealHistoryFuture = getMealsHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: secondaryBackgroundGradient[0],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: primaryBackgroundGradient)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  child: MealsEatenCard(mealsFuture: mealHistoryFuture),
                  height: 200,
                ),
                SizedBox(
                  height: 10,
                ),
                // NutritionCard(mealsFuture: mealHistoryFuture),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
