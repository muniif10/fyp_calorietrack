import 'package:calorie_track/helper/database.dart';
import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/model/meal.dart';
import 'package:calorie_track/ui/cards/graph.dart';
import 'package:calorie_track/ui/cards/meals_eaten_card.dart';
import 'package:calorie_track/ui/setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    setupSettings();
    mealHistoryFuture = getMealsHistory();
  }

  Future<void> setupSettings() async {
    // Get an instance of SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the value already exists
    bool exists = prefs.containsKey('cal_limit');
    if (!exists) {
      // Set the default data if it does not exist
      await prefs.setInt('cal_limit', 2000);
      AppLogger.instance.i('Default settings for calorie has been saved.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Row(
                    children: [
                      const Text(
                        "Home",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryText),
                      ),
                      const Expanded(child: SizedBox.shrink()),
        
                      // Settings
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const SettingPage(),
                            ));
                          },
                          icon: const Icon(
                            Icons.settings,
                            color: primaryText,
                          )),
        
                      // Logout
                      IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Do you want to logout?"),
                                content: const Text(
                                    "Logging out will require you to log in again after this."),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        FirebaseAuth.instance.signOut();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Yes")),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("No"))
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.exit_to_app))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const CalorieGraph(),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 300,
                  child: MealsEatenCard(mealsFuture: mealHistoryFuture),
                ),
                const SizedBox(
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
