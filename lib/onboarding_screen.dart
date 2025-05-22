import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'lib/assets/1.png',
      'title': 'Track Student Progress',
      'description': 'Monitor growth across life skills, care skills, and career readiness in one place.',
    },
    {
      'image': 'lib/assets/12.jpg',
      'title': 'Plan Lessons with Ease',
      'description': 'Organize personalized lesson plans tailored to each student’s needs and pace.',
    },
    {
      'image': 'lib/assets/13.webp',
      'title': 'Support Future Success',
      'description': 'Build confidence by guiding students through practical skills for real-world success.',
    },
  ];

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, '/home'); // Navigate to DashboardScreen
  }

  @override
  Widget build(BuildContext context) {
    final data = onboardingData[currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    "Skip",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(data['image']!, height: 250),
                  SizedBox(height: 4),
                  Text(
                    data['title']!,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    data['description']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(onboardingData.length, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: currentIndex == index ? 24 : 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: currentIndex == index ? Colors.blueAccent : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (currentIndex == onboardingData.length - 1) {
                  _finishOnboarding();
                } else {
                  setState(() => currentIndex++);
                }
              },
              child: Text(
                currentIndex == onboardingData.length - 1 ? "Get Started" : "Next",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}