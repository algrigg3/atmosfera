import 'package:atmosfera/signUp.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Logo at the top
            Image.asset(
              'images/Atmosfera (1).png',
              height: 200,
            ),
            SizedBox(height: 20), //Add space between logo and buttons
            //Sign up button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => signUpPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, //button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), //Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Sign up',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 10), //add space between buttons
            //Login button
            ElevatedButton(
              onPressed: () {
                //add button logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, //button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), //Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
