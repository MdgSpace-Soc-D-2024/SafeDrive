import 'package:flutter/material.dart';
import 'package:safedrive/main.dart';
import 'package:safedrive/pages/intro_screens/page1.dart';
import 'package:safedrive/pages/intro_screens/page2.dart';
import 'package:safedrive/pages/intro_screens/page3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // controller to keep track of which page we're on
  PageController _controller = PageController();
  bool onLastPage = false;

  // set the flag in SharedPreferences when onboarding is completed
  void _setOnboardingComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstLaunch', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (value) {
              setState(() {
                if (value == 2) {
                  onLastPage = true;
                }
              });
            },
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),
          // dot indicators
          Row(
            children: [
              Container(
                  alignment: Alignment(0, 0.80),
                  child:
                      SmoothPageIndicator(controller: _controller, count: 3)),

              // next or done
              onLastPage
                  ? ElevatedButton(
                      onPressed: () {
                        _setOnboardingComplete();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return MyHomePage();
                            },
                          ),
                        );
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      },
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
            ],
          )
        ],
      ),
    );
  }
}

// <------ WIP ------->
