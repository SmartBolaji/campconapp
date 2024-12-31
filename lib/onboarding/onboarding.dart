import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:campcon/onboarding/loginscreen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
  }

  PageController _pageController = PageController();
  int _currentPage = 0;
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  Color primary = const Color(0xFF2c2221);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Image.asset(
                  'assets/images/icon2.png',
                  width: 105,
                  height: 105,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  OnboardingPage(
                    imagePath: 'assets/images/social.jpeg',
                    title: 'Join the conversation!',
                    description:
                        'Discover what\'s trending, connect with classmates, and stay updated.',
                  ),
                  OnboardingPage(
                      imagePath: 'assets/images/social.jpeg',
                      title: 'Stay on Track',
                      description:
                          'Keep track of important requirements and tick off your essential tasks to stay on track with your campus journey'),
                  OnboardingPage(
                    imagePath: 'assets/images/social.jpeg',
                    title: 'Find Your Tribe',
                    description:
                        'Explore clubs, join groups, and connect with like-minded students.',
                  ),
                  OnboardingPage(
                    imagePath: 'assets/images/social.jpeg',
                    title: 'Never Miss Out',
                    description:
                        'Stay in the loop with all the latest campus events and activities.',
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8.0,
                  width: _currentPage == index ? 24.0 : 8.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.grey.shade900
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                );
              }),
            ),
            const SizedBox(height: 100.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_currentPage == 3) {
                    // Close last
                    Navigator.pop(context);
                    // Navigate to next screen or home screen
                    Navigator.push(
                        context,
                        PageTransition(
                          child: const LoginScreen(),
                          type: PageTransitionType.rightToLeft,
                          duration: const Duration(milliseconds: 500),
                          reverseDuration: const Duration(milliseconds: 500),
                        ));
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Text(
                  _currentPage == 3 ? 'Get Started' : 'Next',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Trebuchet',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingPage({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              imagePath,
              width: 500,
              fit: BoxFit.fill,
            ),
          )),
          const SizedBox(height: 20.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Trebuchet'),
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13.0, color: Colors.grey, fontFamily: 'Trebuchet'),
          ),
        ],
      ),
    );
  }
}
