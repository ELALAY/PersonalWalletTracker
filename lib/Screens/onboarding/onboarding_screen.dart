import 'package:flutter/material.dart';
import 'package:personalwallettracker/Screens/home.dart';
import 'package:personalwallettracker/Screens/onboarding/onboarding_page_1.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              isLastScreen = (index == 3);
            });
          },
          children: const [
            // Cards
            OnboardingPage(
              title: 'Cards Management',
              description: 'Manage your cards and their balances',
              image: 'cards',
            ),
            // Transactions
            OnboardingPage(
              title: 'Transaction Management',
              description:
                  'Enter transactions on the go to be able to track them later',
              image: 'transactions',
            ),
            // Statistics
            OnboardingPage(
              title: 'Statistics',
              description:
                  'You can find statistics by date range and categories',
              image: 'stats',
            ),
            // Savings
            OnboardingPage(
              title: 'Savings',
              description:
                  'Make savings and transfer money from cards you manage and track the progress towards your saving Goals',
              image: 'target',
            ),
          ],
        ),
        // controls and page indicator
        Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip to last page
                GestureDetector(
                    onTap: () {
                      _controller.jumpToPage(3);
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold),
                    )),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 4,
                  effect: const ExpandingDotsEffect(
                      activeDotColor: Colors.deepPurple),
                ),
                isLastScreen
                    // Done => to home page
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const MyHomePage();
                          }));
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold),
                        ))
                    :
                    // Next Page
                    GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold),
                        )),
              ],
            )),
      ]),
    );
  }
}
