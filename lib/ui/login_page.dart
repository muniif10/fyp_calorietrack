import 'package:calorie_track/helper/logger.dart';
import 'package:calorie_track/ui/const.dart';
import 'package:calorie_track/ui/register_account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void loginWithUsernameAndPassword(String email, String password) {
    try {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      AppLogger.instance.e("Error: Logging in", error: e);
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
                  "Login",
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
                obscureText: true,
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    loginWithUsernameAndPassword(
                        emailController.text, passwordController.text);
                  },
                  child: Text("Login")),
              SizedBox(
                height: 20,
              ),
              Divider(),
              SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RegisterAccountPage(),
                    ));
                  },
                  child: Text(
                    "Register a new account",
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
