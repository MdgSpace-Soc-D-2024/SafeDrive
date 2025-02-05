import 'package:flutter/material.dart';

class IntroPage1 extends StatelessWidget {
  IntroPage1({super.key});

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
              "Explore Your World",
              style: headingTextStyle,
            ),
          ),
          Center(
            child: Text(
              "Search for any location and view it on an interactive map. Easily add your favorite spots for quick access, whether it is your home, a favorite café, or a new adventure. The map displays essential information like steep slopes and sharp turns to help you navigate safely. With Google’s advanced mapping features, discovering new places has never been easier.",
              style: bodyTextStyle,
            ),
          )
        ],
      ),
    );
  }
}
