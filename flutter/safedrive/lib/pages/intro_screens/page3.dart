import 'package:flutter/material.dart';

class IntroPage3 extends StatelessWidget {
  IntroPage3({super.key});

  final TextStyle headingTextStyle = TextStyle(
    fontSize: 27,
    fontWeight: FontWeight.bold,
  );

  final TextStyle bodyTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 30,
            ),
            color: Colors.blueGrey.shade300,
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(
                          10,
                        )),
                    child: Text(
                      "Personalize Your Experience",
                      style: headingTextStyle,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    "Tailor the app to suit your needs with customizable settings. Turn on dark mode for a more comfortable nighttime experience, adjust feature preferences, and manage your account using Firebase authentication. Keep your app personalized, secure, and functioning the way you want.",
                    style: bodyTextStyle,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
