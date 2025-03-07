import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:ase_capstone/components/my_button.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/components/textfield.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // firebase operations
  final FirestoreService firestoreService = FirestoreService();

  // text controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  late UserCredential user;

  Future<void> signUserUp() async {
    // create the user
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // check to ensure email and password are not empty
      if (usernameController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please fill out all of the fields to continue';
          Utils.displayMessage(context: context, message: _errorMessage);
        });
        return;
      }

      // check to ensure password and confirm password match
      if (passwordController.text != confirmPasswordController.text) {
        Utils.displayMessage(
          context: context,
          message: 'Passwords do not match',
        );
        return;
      } else {
        // create the user
        user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: usernameController.text,
          password: passwordController.text,
        )
            .then((userCredential) {
          var bytes = utf8.encode(passwordController.text);
          var digest = sha256.convert(bytes);
          firestoreService.addUserToDatabase(
            email: usernameController.text,
            password: digest.toString(),
          );
          return userCredential;
        });
        // add user to database
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          // no user found with that email
          _errorMessage = 'User not found with that email address';
          _isLoading = false;
        } else if (e.code == 'invalid-credential' ||
            e.code == 'invalid-email') {
          // invalid email
          _errorMessage = 'Invalid username or password';
          _isLoading = false;
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'A user with that email already exists';
          _isLoading = false;
        } else {
          // other errors
          _errorMessage = 'An unexpected error occurred ${e.code}';
          _isLoading = false;
        }
        Utils.displayMessage(context: context, message: _errorMessage);
      });
      return;
    }

    setState(() {
      // Navigate to the map page when the button is pressed
      Navigator.pushNamed(context, '/map');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // page background color
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        title: Text('Create an Account'),
      ),

      // Safe area to avoid notches and status bar
      body: SafeArea(
        child: Center(
          // allows scrolling if keyboard is open
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_isLoading)
                  Column(
                    children: [
                      const CircularProgressIndicator(),
                    ],
                  ),
                // Campus Compass Logo
                Icon(
                  Icons.account_circle,
                  size: 100,
                ),

                SizedBox(height: 30),

                // Welcome Text
                const Text(
                  'Welcome to Campus Compass!',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const Text(
                  'Let\'s create an account!',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 20),

                // Username Text Field
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                SizedBox(height: 10),

                // Password Text Field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                SizedBox(height: 10),

                // Password Text Field
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                // sign up button
                SizedBox(height: 20),
                MyButton(
                  buttonText: 'Sign Up',
                  onTap: () => signUserUp(),
                ),

                SizedBox(height: 20),
                Divider(thickness: 1, color: Colors.black),

                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
