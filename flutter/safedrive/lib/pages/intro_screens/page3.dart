import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {
  IntroPage3({super.key});

  final TextStyle headingTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  final TextStyle bodyTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade300,
      child: Column(
        children: [
          Center(
            child: Text(
              "Personalize Your Experience",
              style: headingTextStyle,
            ),
          ),
          Center(
            child: Text(
              "Tailor the app to suit your needs with customizable settings. Turn on dark mode for a more comfortable nighttime experience, adjust feature preferences, and manage your account using Firebase authentication. Keep your app personalized, secure, and functioning the way you want.",
              style: bodyTextStyle,
            ),
          )
        ],
      ),
    );
  }
}
