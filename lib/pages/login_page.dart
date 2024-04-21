// Matthew Fante
// INFO-C451: System Implementation
// Spring 2024 Final Project

// this class describes the login page which allows the user to login to the app

import 'package:flutter/material.dart';
import 'package:untitled/authentication/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/authentication/fire_auth.dart';
import 'package:untitled/widgets/menu_scaffold.dart';
import 'package:untitled/pages/register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailTextController = TextEditingController();
    final passwordTextController = TextEditingController();
    final focusEmail = FocusNode();
    final focusPassword = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sheltr',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 200.0),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
                controller: emailTextController,
                focusNode: focusEmail,
                validator: (value) => Validator.validateEmail(email: value!),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Password",
                ),
                controller: passwordTextController,
                focusNode: focusPassword,
                obscureText: true,
                validator: (value) =>
                    Validator.validatePassword(password: value!),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color(0xff990000),
                  ),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      User? user = await FireAuth.signInUsingEmailPassword(
                        email: emailTextController.text,
                        password: passwordTextController.text,
                        context: context,
                      );
                      if (user != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const MenuScaffold()),
                        );
                      } else {
                        throw Exception("Login failed!");
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                              "Login failed. Please check your credentials and try again.",
                            ),
                            backgroundColor: Color(0xff990000)),
                      );
                      // Clear the password field on failure
                      passwordTextController.clear();
                    }
                  }
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text("-  or  -"),
              const SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'Register',
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
