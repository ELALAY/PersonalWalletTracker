import 'package:flutter/material.dart';
import 'package:personalwallettracker/Screens/onboarding/onboarding_page_1.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PageView(
          controller: _controller,
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
          ],
        ),
        Container(
            alignment: const Alignment(0, 0.75),
            child: SmoothPageIndicator(controller: _controller, count: 3)),
      ]),
    );
  }
}
