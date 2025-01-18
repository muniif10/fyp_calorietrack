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
  // Function to handle login with email and password
  void loginWithUsernameAndPassword(String email, String password) async {
    // Validate email and password fields before making any network request
    if (email.isEmpty || password.isEmpty) {
      // If either email or password is empty, show an error
      showErrorMessage("Please enter both email and password.");
      return;
    }

    try {
      // Attempt to sign in with the provided email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException to display specific error messages to the user
      AppLogger.instance.e("Error: Logging in", error: e);

      // Handle specific Firebase authentication errors
      if (e.code == 'user-not-found') {
        showErrorMessage("No user found for this email. Please register.");
      } else if (e.code == 'wrong-password') {
        showErrorMessage("Incorrect password. Please try again.");
      } else if (e.code == 'invalid-email') {
        showErrorMessage("The email address is invalid. Please check your email.");
      } else {
        // Handle all other errors
        showErrorMessage("Login failed. Please try again later.");
      }
    } catch (e) {
      // Handle unexpected errors and log them
      AppLogger.instance.e("Unexpected error: ", error: e);
      showErrorMessage("Something went wrong. Please try again.");
    }
  }

  // Helper function to display error messages using a SnackBar
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TextEditingController for email and password fields
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    // Decorations for email and password input fields
    InputDecoration emailDecoration = InputDecoration(
      hintText: "Enter your username",
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
    );
    InputDecoration passwordDecoration = InputDecoration(
      hintText: "Enter your password",
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
    );

    // Header style for the login page
    TextStyle headerStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: primaryText,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: primaryBackgroundGradient),
        ),
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
              const SizedBox(height: 10),
              const Text("Email"),
              TextField(
                decoration: emailDecoration,
                controller: emailController,
                keyboardType: TextInputType.emailAddress, // Ensures the correct keyboard is displayed for emails
                autofillHints: const [AutofillHints.email], // Suggests email autofill hints to the user
              ),
              const SizedBox(height: 20),
              const Text("Password"),
              TextField(
                decoration: passwordDecoration,
                controller: passwordController,
                obscureText: true, // Ensures the password is obscured
                keyboardType: TextInputType.visiblePassword, // Ensures the correct keyboard is displayed for password
                autofillHints: const [AutofillHints.password], // Suggests password autofill hints to the user
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Call login function with provided email and password when the button is pressed
                  loginWithUsernameAndPassword(
                    emailController.text,
                    passwordController.text,
                  );
                },
                child: const Text("Login"),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to the registration page when the user clicks on 'Register'
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RegisterAccountPage(),
                  ));
                },
                child: const Text("Register a new account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
