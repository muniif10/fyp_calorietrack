import 'package:flutter/material.dart';

class AddFoodPage extends StatelessWidget {
  const AddFoodPage({super.key, this.classification, this.imagePath});
  final Map<String, double>? classification;
  final String? imagePath;

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
        sortClassification(classification);
    return Scaffold(
      body: SafeArea(
        child: PageView(
          children: [
            // Take 3 of the likely food
            ...sortedListClassification.take(3).map((entry) {
              return Text("${entry.key} ${entry.value}");
            })
          ],
        ),
      ),
    );
  }
}
