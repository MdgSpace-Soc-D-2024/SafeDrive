import 'package:flutter/material.dart';

class IntroPage1 extends StatelessWidget {
  IntroPage1({super.key});

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
                      "Explore Your World",
                      style: headingTextStyle,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    "Search for any location and view it on an interactive map. Easily add your favorite spots for quick access, whether it is your home, a favorite café, or a new adventure. The map displays essential information like steep slopes and sharp turns to help you navigate safely. With Google’s advanced mapping features, discovering new places has never been easier.",
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
