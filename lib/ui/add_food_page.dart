import 'dart:io';

import 'package:calorie_track/helper/database.dart';
import 'package:calorie_track/helper/meal_helpers.dart';
import 'package:calorie_track/model/meal.dart';
import 'package:flutter/material.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key, this.classification, this.imagePath});
  final Map<String, double>? classification;
  final String? imagePath;

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  double portionSliderValue = 1;
  double totalCalorie = 0;
  List<MapEntry<String, double>> sortClassification(
      Map<String, double>? classification) {
    if (classification == null) {
      return []; // Return an empty list if the map is null
    }

    // Sort the map by values in descending order and return the sorted list
    var sortedList = classification.entries.toList()
      ..sort((a, b) =>
          b.value.compareTo(a.value)); // Compare the values in descending order

    return sortedList;
  }

  void addMeal(MapEntry<String, double> entry, int portion, double calories,
      String imagePath) {
    DatabaseHelper db = DatabaseHelper.instance;
    db.insertMeal(Meal(
        foodName: entry.key,
        calorieInput: calories,
        portion: portion,
        insertionDate: DateTime.now().toIso8601String(),
        imagePath: imagePath));
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, double>> sortedListClassification =
        sortClassification(widget.classification);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add Meal"),
      ),
      body: SafeArea(
        child: PageView(
          children: [
            ...sortedListClassification.map((entry) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(widget.imagePath!),
                            width: 200,
                          ),
                        ),
                        Text(getHumanReadableName(entry.key)),
                        Text(entry.value.toStringAsFixed(2))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(labelAttributes[entry.key]!["description"]!),
                    const SizedBox(
                      height: 10,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Portion Size"),
                    ),
                    Slider(
                        divisions: 4,
                        min: 1,
                        max: 5,
                        label: portionSliderValue.round().toString(),
                        value: portionSliderValue,
                        onChanged: (double value) {
                          setState(() {
                            portionSliderValue = value;
                            totalCalorie = double.parse((labelAttributes[
                                    entry.key]!["calories"]!)) *
                                portionSliderValue;
                          });
                        }),
                    Row(
                      children: [
                        const Text("Total calories: "),
                        Text("${totalCalorie.round()} kcal")
                      ],
                    ),
                    // const Expanded(
                    //   child: SizedBox(),
                    // ),
                    ElevatedButton(
                        onPressed: () {
                          if (totalCalorie <= 0) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Incomplete details"),
                                content:
                                    const Text("Please select the portion size."),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Close"))
                                ],
                              ),
                            );
                            return;
                          }
                          addMeal(entry, portionSliderValue.toInt(),
                              totalCalorie, widget.imagePath!);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Add this meal"))
                  ],
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
