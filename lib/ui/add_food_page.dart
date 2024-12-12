import 'dart:io';

import 'package:calorie_track/helper/enums.dart';
import 'package:flutter/material.dart';

class AddFoodPage extends StatefulWidget {
  AddFoodPage({super.key, this.classification, this.imagePath});
  final Map<String, double>? classification;
  final String? imagePath;

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  double weightSliderValue = 1;
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

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, double>> sortedListClassification =
        sortClassification(widget.classification);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Meal"),
      ),
      body: SafeArea(
        child: PageView(
          children: [
            // Take 3 of the likely food
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
                        Text(entry.value.roundToDouble().toString())
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(labelAttributes[entry.key]!["description"]!),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Portion Size"),
                    ),
                    Slider(
                        divisions: 4,
                        min: 1,
                        max: 5,
                        label: weightSliderValue.round().toString(),
                        value: weightSliderValue,
                        onChanged: (double value) {
                          setState(() {
                            weightSliderValue = value;
                            totalCalorie = double.parse((labelAttributes[
                                    entry.key]!["calories"]!)) *
                                weightSliderValue;
                          });
                        }),
                    Row(
                      children: [
                        Text("Total calories: "),
                        Text("${totalCalorie.round()} kcal")
                      ],
                    )
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
