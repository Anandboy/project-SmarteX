import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/screens/login_screen.dart';
import 'package:personal_expense_tracker/utils/app_validator.dart';

class SignUpView extends StatelessWidget {
  SignUpView({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully')),
      );
    }
  }
  var appValidator = AppValidator();
//  String? _validateEmail(value) {
//    if (value!.isEmpty) {
//    return 'Please enter an email';
  //  }
  //RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  //if (!emailRegExp.hasMatch(value)) {
//  return 'Please enter a valid email';
  //  }
//return null;
  //}

  // String? _validateUsername(value) {
  //   if (value!.isEmpty) {
  //     return 'Please enter a username';
  //   }
  //   return null;
  // }

  // String? _validatePassword(value) {
  //   if (value!.isEmpty) {
  //     return 'Please enter a password';
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF252634),
        body: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 80.0,
                  ),
                  SizedBox(
                    width: 250,
                    child: Text(
                      "Create new Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration:
                          _buildInputDecoration("Username", Icons.person),
                      validator: appValidator.validateUsername),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: _buildInputDecoration("Email", Icons.email),
                      validator: appValidator.validateEmail),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: _buildInputDecoration("Password", Icons.lock),
                      validator: appValidator.validatePassword),
                  SizedBox(
                    height: 40.0,
                  ),
                  SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF15900)),
                          onPressed: _submitForm, child: Text("Create", style: TextStyle( fontSize: 20)))),
                  SizedBox(
                    height: 30.0,
                  ),
                  TextButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginView()),
                    );
                  }, child: Text(
                    "Login",
                    style: TextStyle(color: Color(0xFFF15900), fontSize: 20),
                  ),
                  //TextFormField(
                  //  decoration: InputDecoration(
                  //    labelText: 'Phone Number', border: OutlineInputBorder(
                  //      borderRadius: BorderRadius.circular(10.0)
                  //  )
                  //  ),
                  ),
              ]),
        ))));
  }

  InputDecoration _buildInputDecoration(String label, IconData suffixIcon) {
    return InputDecoration(
        fillColor: Color(0xAA494A59),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x35949494))),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        filled: true,
        labelStyle: TextStyle(color: Color(0xFF949494)),
        labelText: label,
        suffixIcon: Icon(
          suffixIcon,
          color: Color(0xFF949494),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)));
  }
}
