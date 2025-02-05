import 'package:flutter/material.dart';

class IntroPage2 extends StatelessWidget {
  IntroPage2({super.key});

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
                      "Navigate Your Journey",
                      style: headingTextStyle,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    "Set your destination and let the app guide you with live routing updates. The map provides real-time navigation to your destination, ensuring you’re always on the best route. Our advanced features also show you any steep inclines or sharp turns along the way, so you can drive with confidence.",
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
