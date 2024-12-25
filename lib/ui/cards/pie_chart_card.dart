import 'package:calorie_track/ui/const.dart';
import 'package:calorie_track/ui/home_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
    // Get the screen height

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Title Section
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
              SizedBox(
                height: 150,
                width: 200,
                child: PieChart(
                  swapAnimationCurve: Curves.easeInOutCirc,
                  swapAnimationDuration: const Duration(milliseconds: 300),
                  PieChartData(
                    borderData: FlBorderData(show: true),
                    sectionsSpace: 0,
                    centerSpaceRadius: 25,
                    sections: sections,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          onTouchedIndexChanged(-1);
                          return;
                        }
                        final newIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                        onTouchedIndexChanged(
                            newIndex == touchedIndex ? -1 : newIndex);
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Indicator(
                        color: carbColor, text: 'Carbohydrate', isSquare: true),
                    const SizedBox(height: 4),
                    Indicator(
                        color: proteinColor, text: 'Protein', isSquare: true),
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


  // List<PieChartSectionData> showingSections() {
  //   return List.generate(4, (i) {
  //     final isTouched = i == touchedIndex;
  //     final fontSize = isTouched ? 25.0 : 16.0;
  //     final radius = isTouched ? 60.0 : 50.0;
  //     const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
  //     switch (i) {
  //       case 0:
  //         return PieChartSectionData(
  //           color: carbColor,
  //           value: 30,
  //           title: '40%',
  //           radius: radius,
  //           titleStyle: TextStyle(
  //             fontSize: fontSize,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //             shadows: shadows,
  //           ),
  //         );
  //       case 1:
  //         return PieChartSectionData(
  //           color: proteinColor,
  //           value: 30,
  //           title: '30%',
  //           radius: radius,
  //           titleStyle: TextStyle(
  //             fontSize: fontSize,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //             shadows: shadows,
  //           ),
  //         );
  //       case 2:
  //         return PieChartSectionData(
  //           color: fatColor,
  //           value: 15,
  //           title: '15%',
  //           radius: radius,
  //           titleStyle: TextStyle(
  //             fontSize: fontSize,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //             shadows: shadows,
  //           ),
  //         );
  //       case 3:
  //         return PieChartSectionData(
  //           color: fibreColor,
  //           value: 15,
  //           title: '15%',
  //           radius: radius,
  //           titleStyle: TextStyle(
  //             fontSize: fontSize,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //             shadows: shadows,
  //           ),
  //         );
  //       default:
  //         throw Error();
  //     }
  //   });
  // }
