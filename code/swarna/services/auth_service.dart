import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/screens/home_screen.dart';
/// Service class for handling authentication operations
class AuthService{
/// Method to create a new user using Firebase Authentication
  /// 
  /// Takes `data` (a map containing 'email' and 'password') and `context` for navigation.
  Future<void> createUser(Map<String, String> data, BuildContext context) async {
    try {
       // Attempt to create a new user with email and password
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      // Navigate to HomeScreen upon successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  const HomeScreen()),
      );

    } catch (e) {
      // Show error dialog if sign-up fails
      showDialog(
        context: context,
        builder: (context) {return AlertDialog(
          title: Text("Sign up failed"),
          content: Text(e.toString()),
        );
        });
    }
  }
  /// Method to log in an existing user using Firebase Authentication
  /// 
  /// Takes `data` (a map containing 'email' and 'password') and `context` for navigation.
  Future<void> login(Map<String, String> data, BuildContext context) async {
    try {
      // Attempt to sign in the user with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      // Navigate to HomeScreen upon successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  const HomeScreen()),
      );
    } catch (e) {
      // Show error dialog if login fails
      showDialog(
          context: context,
          builder: (context) {return AlertDialog(
            title: Text("Login Error"),
            content: Text(e.toString()),
          );
          });
    }
  }

}
