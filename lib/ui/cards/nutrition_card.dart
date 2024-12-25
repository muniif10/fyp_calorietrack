import 'package:calorie_track/model/meal.dart';
import 'package:flutter/material.dart';

class NutritionCard extends StatelessWidget {
  final Future<List<Meal>> mealsFuture;
  const NutritionCard({
    super.key,
    required this.mealsFuture,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Placeholder();
  }
}
