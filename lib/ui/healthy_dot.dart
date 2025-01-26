import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HealthDotWidget extends StatefulWidget {
  final String endpoint;

  const HealthDotWidget({super.key, required this.endpoint});

  @override
  _HealthDotWidgetState createState() => _HealthDotWidgetState();
}

class _HealthDotWidgetState extends State<HealthDotWidget> {
  late Color dotColor;
  late String statusText;
  late double latency;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    dotColor = Colors.grey;
    statusText = 'Checking...';
    latency = 0.0;
    _checkHealth();
    // Recheck every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkHealth();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkHealth() async {
    final startTime = DateTime.now();
    try {
      final response = await http.get(Uri.parse(widget.endpoint));
      final endTime = DateTime.now();
      latency = endTime.difference(startTime).inMilliseconds.toDouble();

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'healthy' && latency < 500) {
          setState(() {
            dotColor = Colors.green;
          });
        } else {
          setState(() {
            dotColor = Colors.red;
          });
        }
      } else {
        setState(() {
          dotColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        dotColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _checkHealth,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Status: "),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
