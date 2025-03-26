import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/screens/home_screen.dart';



class AuthService{

  createUser(data,context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  const HomeScreen()),
      );

    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {return AlertDialog(
          title: Text("Sign up failed"),
          content: Text(e.toString()),
        );
        });
    }
  }
  login(data,context) async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  const HomeScreen()),
      );
    } catch (e) {
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