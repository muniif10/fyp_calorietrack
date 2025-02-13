import 'package:calorie_track/ui/const.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int calLimit = 0;
  Future<void> getSettings() async {
    // Get an instance of SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the value already exists
    int? exists = prefs.getInt("cal_limit");
    if (exists != null) {
      setState(() {
        calLimit = exists;
      });
    }
  }

  Future<void> setSettings(int calLimit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("cal_limit", calLimit);
  }

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController calControl = TextEditingController();
    calControl.text = calLimit.toString();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setSettings(int.parse(calControl.text));
            },
            child: const Icon(Icons.save),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back)),
                      const Text(
                        "Settings",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryText),
                      ),
                    ],
                  ),
                  ListTile(
                    title: const Text("Calorie Limit"),
                    trailing: SizedBox(
                      width: 150,
                      child: TextField(
                        controller: calControl,
                      ),
                    ),
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
