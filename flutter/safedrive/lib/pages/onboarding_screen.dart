import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final introKey = GlobalKey<IntroductionScreenState>();

// <------ WIP ------->

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      bodyTextStyle: TextStyle(fontSize: 19),
      bodyPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      pageColor: Colors.white,
      // imagePadding: EdgeInsets.zero,
    );
    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: "Map Screen",
          body: "",
          // image: ,
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Drive Screen",
          body: "",
          // image: ,
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Settings Screen",
          body: "",
          // image: ,
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Offline Maps",
          body: "",
          // image: ,
          decoration: pageDecoration,
        ),
      ],
    );
  }
}

// <------ WIP ------->
