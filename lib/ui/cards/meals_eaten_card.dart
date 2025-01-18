import 'package:calorie_track/helper/meal_helpers.dart';
import 'package:calorie_track/model/meal.dart';
import 'package:calorie_track/ui/const.dart';
import 'package:flutter/material.dart';

class MealsEatenCard extends StatelessWidget {
  final Stream<List<Meal>> mealsFuture;
  const MealsEatenCard({
    super.key,
    required this.mealsFuture,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle header =
        const TextStyle(fontWeight: FontWeight.bold, color: primaryText);

    return StreamBuilder(
      stream: mealsFuture,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // No data state
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scrollbar(
            child: SingleChildScrollView(
              child: Center(child: Text("No meals found.")),
            ),
          );
        }

        // Process the meal data for today's meals
        List<TableRow> rows = [];

        List<Meal> meals = snapshot.data!;

        meals = meals.where((meal) {
          // Parse the string to DateTime
          DateTime parsedDateTime = DateTime.parse(meal.insertionDate);

          // Get today's date (ignoring time)
          DateTime today = DateTime.now();

          // Check if the parsed date is today
          return parsedDateTime.year == today.year &&
              parsedDateTime.month == today.month &&
              parsedDateTime.day == today.day;
        }).toList();

        if (meals.isEmpty) {
          // No meals for today
          rows.add(
            const TableRow(
              children: [
                Text("No meal added today.", style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        } else {
          // Populate rows with today's meals
          rows.addAll(meals.map<TableRow>((meal) {
            return TableRow(
              children: [
                Text(getHumanReadableName(meal.foodName)),
                Text(meal.portion.toString()),
                Text(meal.calorieInput.toInt().toString()),
              ],
            );
          }).toList());
        }

        // Final Table Widget
        return Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withOpacity(.1),
                    offset: const Offset(0, 2))
              ],
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(colors: primaryBackgroundGradient)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(0, 2),
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.1))
                      ],
                      gradient:
                          LinearGradient(colors: primaryBackgroundGradient),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Today's Meals",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryText),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Table(
                  columnWidths: const {
                    0: FixedColumnWidth(
                        150), // First column has a fixed width of 150 pixels
                    1: FixedColumnWidth(
                        100), // Second column has a fixed width of 100 pixels
                    2: FixedColumnWidth(
                        120), // Third column has a fixed width of 120 pixels
                  },
                  children: [
                    TableRow(
                      children: [
                        Text("Meal Name", style: header),
                        Text("Servings", style: header),
                        Text("Calories", style: header),
                      ],
                    )
                  ],
                ),
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(
                              150), // First column has a fixed width of 150 pixels
                          1: FixedColumnWidth(
                              100), // Second column has a fixed width of 100 pixels
                          2: FixedColumnWidth(
                              120), // Third column has a fixed width of 120 pixels
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: rows,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
