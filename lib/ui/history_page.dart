import 'dart:io';
import 'package:calorie_track/helper/meal_helpers.dart';
import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/helper/database.dart';
import 'package:calorie_track/model/meal.dart';
import 'package:calorie_track/ui/const.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

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

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Meal>> mealHistoryFuture;
  @override
  void initState() {
    super.initState();
    mealHistoryFuture = getMealsHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Past Meals List",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<List<Meal>>(
              future: mealHistoryFuture, // Pass the Future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While waiting for the data, show a loading indicator
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Handle any errors
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Handle empty data
                  return const Text("No meals found.");
                } else {
                  // If data is available, display the list
                  List<Meal> history = snapshot.data!;
                  return Flexible(
                    child: ListView.builder(
                      itemCount: history
                          .length, // Set itemCount to the number of meals
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                8), // Optional: If you want rounded corners for the image
                            child: Image.file(
                              File(history[index]
                                  .imagePath), // Assuming you store the image URL or local path in 'imagePath'
                              width: 50, // Set a fixed width for the image
                              height: 50, // Set a fixed height for the image
                              fit: BoxFit
                                  .cover, // Ensures the image covers the space without distortion
                            ),
                          ),
                          title: Text(getHumanReadableName(history[index]
                              .foodName)), // Display food name or other properties of Meal
                          subtitle: Text(
                              "Calorie: ${history[index].calorieInput.toInt()}"),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
