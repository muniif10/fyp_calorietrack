import 'package:calorie_track/helper/database.dart';
import 'package:calorie_track/model/meal.dart';
import 'package:calorie_track/ui/const.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget getTitles(double value, TitleMeta meta) {
  TextStyle style = TextStyle(
    color: Colors.blue[600],
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );
  int today = DateTime.now().weekday - 1;
  Text text;
  switch (value.toInt()) {
    case 0:
      text = Text('M', style: style);
      break;
    case 1:
      text = Text('T', style: style);
      break;
    case 2:
      text = Text('W', style: style);
      break;
    case 3:
      text = Text('T', style: style);
      break;
    case 4:
      text = Text('F', style: style);
      break;
    case 5:
      text = Text('S', style: style);
      break;
    case 6:
      text = Text('S', style: style);
      break;
    default:
      text = Text('', style: style);
      break;
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 16,
    child: value.toInt() == today
        ? Text(
            text.data!,
            style: style.copyWith(fontWeight: FontWeight.w900),
          )
        : text,
  );
}

BarChartGroupData makeGroupData(int x, double y,
    {bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
    int calLimit = 2000}) {
  barColor ??= Colors.blue[200];
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: isTouched ? y.roundToDouble() + 1 : y.roundToDouble(),
        gradient: const LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter),
        width: width,
        borderSide: isTouched
            ? const BorderSide(color: Colors.black)
            : const BorderSide(color: Colors.white, width: 0),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: calLimit.toDouble(),
          color: Colors.white,
        ),
      ),
    ],
    showingTooltipIndicators: showTooltips,
  );
}

class CalorieGraph extends StatefulWidget {
  const CalorieGraph({super.key});

  @override
  State<CalorieGraph> createState() => _CalorieGraphState();
}

// Fetch the calorie limit from SharedPreferences (async function)
Future<int> getCalLimit() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? exists = prefs.getInt("cal_limit");
  return exists ?? 2000; // Return 2000 if the value does not exist
}

class _CalorieGraphState extends State<CalorieGraph> {
  int touchedIndex = -1;
  List<double> weeklyCalories = List.filled(7, 0.0);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getCalLimit(), // Fetch the calorie limit
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          // Calorie limit fetched successfully
          int calLimit = snapshot.data!;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(colors: primaryBackgroundGradient),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Weekly Calories",
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {});
                                },
                                icon: const Icon(Icons.replay_outlined))
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: BarChart(
                            calorieBarData(calLimit),
                            swapAnimationCurve: Easing.standard,
                            swapAnimationDuration:
                                const Duration(milliseconds: 500),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text("No data found"));
        }
      },
    );
  }

  BarChartData calorieBarData(int calLimit) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.white,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem("Calories: ", const TextStyle(), children: [
              TextSpan(
                  text: (rod.toY - 1).toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ]);
          },
        ),
      ),
      barGroups: showingGroups(calLimit),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
    );
  }

  Future<void> fetchWeeklyCalories() async {
  FirestoreHelper db = FirestoreHelper();
  // Subscribe to the stream and calculate weekly calories based on meal dates
  db.mealsStream().listen((meals) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    List<double> tempCalories = List.filled(7, 0.0);

    for (var meal in meals) {
      DateTime mealDate = DateTime.parse(meal.insertionDate);
      if (mealDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          mealDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        int dayIndex = mealDate.weekday - 1;
        tempCalories[dayIndex] += meal.calorieInput;
      }
    }

    // Update the state (assuming you are in a StatefulWidget)
    setState(() {
      weeklyCalories = tempCalories;
    });
  });
}


  @override
  void initState() {
    super.initState();
    fetchWeeklyCalories();
  }

  List<BarChartGroupData> showingGroups(int calLimit) => List.generate(7, (i) {
        return makeGroupData(i, weeklyCalories[i],
            isTouched: i == touchedIndex, calLimit: calLimit);
      });
}
