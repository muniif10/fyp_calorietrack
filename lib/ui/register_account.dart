import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/ui/const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterAccountPage extends StatefulWidget {
  const RegisterAccountPage({super.key});

  @override
  State<RegisterAccountPage> createState() => _RegisterAccountPageState();
}

class _RegisterAccountPageState extends State<RegisterAccountPage> {
  void registerWithEmail(String email, String password) {
    try {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      AppLogger.instance.e("Error: Registering account", error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    InputDecoration emailDecoration = InputDecoration(
        hintText: "Enter your username",
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)));
    InputDecoration passwordDecoration = InputDecoration(
        hintText: "Enter your password",
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)));
    TextStyle headerStyle = const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 24, color: primaryText);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: primaryBackgroundGradient)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "Register",
                  style: headerStyle,
                ),
              ),
              Text("Email"),
              TextField(
                decoration: emailDecoration,
                controller: emailController,
              ),
              SizedBox(
                height: 20,
              ),
              Text("Password"),
              TextField(
                decoration: passwordDecoration,
                controller: passwordController,
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    registerWithEmail(
                        emailController.text, passwordController.text);
                  },
                  child: Text("Register")),
              SizedBox(
                height: 20,
              ),
              Divider(),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
