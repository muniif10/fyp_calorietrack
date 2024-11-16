import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../ui/const.dart';

Stream<List<MealEntry>> getMealListStream() async* {
  List<MealEntry> foodList = [];
  MealEntry sampleMeal = MealEntry("Nasi Lemak", [const Nutrition()]);
  foodList.add(sampleMeal);
  yield foodList;
  await Future.delayed(const Duration(seconds: 2));
  foodList.add(sampleMeal);
  yield foodList;
  await Future.delayed(const Duration(seconds: 2));
  foodList.add(sampleMeal);
  yield foodList;
}

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

class InformationCard extends StatelessWidget {
  final Widget content;

  const InformationCard({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(161, 151, 201, 255), width: 1),
              boxShadow: const [
                BoxShadow(
                    color: shadownOnPrimaryBackgroundGradient,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                    spreadRadius: 0)
              ],
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(colors: secondaryBackgroundGradient)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FractionallySizedBox(
              heightFactor: .9,
              widthFactor: .95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                      widthFactor: 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: onSecondaryBackgroundGradient),
                            borderRadius: BorderRadius.circular(5)),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          child: Text(
                            "Today's Meal",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  content,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MealEntry {
  String foodName;
  List<Nutrition> nutritionList;
  MealEntry(this.foodName, this.nutritionList);

  @override
  String toString() {
    return foodName;
  }
}

class MealInformartionCard extends StatelessWidget {
  final Stream<List<MealEntry>> mealList;

  const MealInformartionCard({
    super.key,
    required this.mealList,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(161, 151, 201, 255), width: 1),
              boxShadow: const [
                BoxShadow(
                    color: shadownOnPrimaryBackgroundGradient,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                    spreadRadius: 0)
              ],
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(colors: secondaryBackgroundGradient)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FractionallySizedBox(
              heightFactor: .9,
              widthFactor: .95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                      widthFactor: 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: onSecondaryBackgroundGradient),
                            borderRadius: BorderRadius.circular(5)),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          child: Text(
                            "Today's Meal",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  StreamBuilder<List<MealEntry>>(
                    stream: mealList,
                    builder: (context, snapshot) {
                      // Create the list of rows starting with the header row
                      List<TableRow> rows = [
                        TableRow(
                          children: [
                            Text("Name",
                                style: TextStyle(
                                    color: secondaryText,
                                    fontWeight: FontWeight.bold)),
                            Text("Daily Cal. (%)",
                                style: TextStyle(
                                    color: secondaryText,
                                    fontWeight: FontWeight.bold)),
                            Text("Cal. (Cal)",
                                style: TextStyle(
                                    color: secondaryText,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ];

                      // Handle different states of the stream
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        rows.add(
                          const TableRow(children: [
                            Text("Loading..."),
                            Text(""),
                            Text("")
                          ]),
                        );
                      } else if (snapshot.hasError) {
                        rows.add(
                          TableRow(children: [
                            Text("Error: ${snapshot.error}"),
                            const Text(""),
                            const Text("")
                          ]),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        rows.add(
                          const TableRow(children: [
                            Text("No data available"),
                            Text(""),
                            Text("")
                          ]),
                        );
                      } else {
                        // Add a TableRow for each MealEntry item in the snapshot data
                        rows.addAll(snapshot.data!.map((meal) {
                          return TableRow(
                            children: [
                              Text(meal.foodName),
                              Text(meal.foodName),
                              Text(meal.foodName),
                            ],
                          );
                        }).toList());
                      }

                      // Return the Table with the rows
                      return Table(
                        children: rows,
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Nutrition {
  const Nutrition();
}

class PieChartWidget extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final int touchedIndex;
  final Function(int?) onTouchedIndexChanged;

  const PieChartWidget({
    super.key,
    required this.sections,
    required this.touchedIndex,
    required this.onTouchedIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Today's Meal Nutrients",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Pie Chart Section
            Flexible(
              flex: 3,
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  swapAnimationCurve: Curves.easeInOutCirc,
                  swapAnimationDuration: const Duration(milliseconds: 300),
                  PieChartData(
                    borderData: FlBorderData(show: true),
                    sectionsSpace: 0,
                    centerSpaceRadius: 50,
                    sections: sections,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          onTouchedIndexChanged(-1);
                          return;
                        }
                        final newIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        onTouchedIndexChanged(newIndex == touchedIndex ? -1 : newIndex);
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Indicator Section
            Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Indicator(color: carbColor, text: 'Carbohydrate', isSquare: true),
                  const SizedBox(height: 4),
                  Indicator(color: proteinColor, text: 'Protein', isSquare: true),
                  const SizedBox(height: 4),
                  Indicator(color: fatColor, text: 'Fat', isSquare: true),
                  const SizedBox(height: 4),
                  Indicator(color: fibreColor, text: 'Fibre', isSquare: true),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
  }
}

class _HomePageState extends State<HomePage> {
  int touchedIndex = -1;
  Stream<List<MealEntry>> mealList = getMealListStream();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: primaryBackgroundGradient)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: PieChartWidget(
                sections: showingSections(),
                touchedIndex: touchedIndex,
                onTouchedIndexChanged: (newIndex) {
                  setState(() {
                    touchedIndex = newIndex!;
                  });
                },
              ),
            ),
            const Divider(
              thickness: 2,
              color: Color.fromARGB(51, 63, 81, 181),
              indent: 25,
              endIndent: 25,
              height: 0,
            ),
            Expanded(
              flex: 1,
              child: MealInformartionCard(mealList: mealList),
            ),
            const Expanded(
              flex: 1,
              child: InformationCard(content: Text("Hi brothers!"),),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: carbColor,
            value: 30,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: proteinColor,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: fatColor,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: fibreColor,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
