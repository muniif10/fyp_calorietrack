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
  // Function to handle registration with email and password
  Future<bool> registerWithEmail(String email, String password) async {
    // Check if email and password are not empty
    if (email.isEmpty || password.isEmpty) {
      // Show an error message if either field is empty
      showErrorMessage("Please fill in both email and password");
      return false;
    }

    try {
      // Attempt to create the user with email and password
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException errors, log them, and show user-friendly messages
      AppLogger.instance.e("Error: Registering account", error: e);

      // FirebaseAuthException has various error codes we can check
      if (e.code == 'weak-password') {
        showErrorMessage(
            "The password is too weak. Please choose a stronger password.");
        return false;
      } else if (e.code == 'email-already-in-use') {
        showErrorMessage(
            "An account already exists with this email. Please log in.");
        return false;
      } else if (e.code == 'invalid-email') {
        showErrorMessage(
            "The email address is not valid. Please enter a valid email.");
        return false;
      } else {
        // Catch all other errors
        showErrorMessage("Registration failed. Please try again later.");
        return false;
      }
    } catch (e) {
      // Catch other unexpected errors and log them
      AppLogger.instance.e("Unexpected Error: ", error: e);
      showErrorMessage("Something went wrong. Please try again.");
      return false;
    }
    return true;
  }

  // Function to display an error message using a snack bar
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showSuccessSnackBar(BuildContext ctx, String msg, int type) {
    ScaffoldMessenger.of(ctx).removeCurrentSnackBar();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.fixed,
        showCloseIcon: true,
        // shape: const StadiumBorder(),
        backgroundColor: type == 1 ? Colors.green[800] : Colors.grey[700],
        padding: const EdgeInsets.all(15),
        // margin: const EdgeInsets.all(30),
        duration: const Duration(
            seconds:
                4), // Set a longer duration to let the fade-out effect happen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Controllers for the email and password text fields
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    // Decorations for the text fields
    InputDecoration emailDecoration = InputDecoration(
      hintText: "Enter your username",
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
    );
    InputDecoration passwordDecoration = InputDecoration(
      hintText: "Enter your password",
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
    );

    // Style for the header
    TextStyle headerStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: primaryText,
    );

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
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
                      child: Image.asset(
                        "assets/images/icon.png",
                        height: 100,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        "Register",
                        style: headerStyle,
                      ),
                    ),
                    const Text("Email"),
                    TextField(
                      decoration: emailDecoration,
                      controller: emailController,
                      keyboardType: TextInputType
                          .emailAddress, // Ensures keyboard is appropriate for emails
                    ),
                    const SizedBox(height: 20),
                    const Text("Password"),
                    TextField(
                      decoration: passwordDecoration,
                      controller: passwordController,
                      obscureText: true, // To obscure password text
                      keyboardType: TextInputType
                          .visiblePassword, // Ensures password keyboard is shown
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Trigger registration when button is pressed
                        bool res = await registerWithEmail(
                            emailController.text, passwordController.text);
                        if (context.mounted && res) {
                          // ScaffoldMessenger.of(context).clearSnackBars();
                          showSuccessSnackBar(
                              context, "Logged in, welcome!", 1);

                          Navigator.of(context).pop();
                          FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text);
                        }
                      },
                      child: const Text("Register"),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
