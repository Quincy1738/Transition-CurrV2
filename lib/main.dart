import 'package:flutter/material.dart';
import 'package:transition_curriculum/screens/dashboard.dart';
import 'package:transition_curriculum/screens/student_profile.dart';
import 'package:transition_curriculum/screens/progress_tracker.dart';
import 'package:transition_curriculum/screens/reports.dart';
import 'package:transition_curriculum/screens/lesson_planner.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/models/lesson.dart';
import 'package:transition_curriculum/services/alarm_service.dart';

import 'onboarding_screen.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize alarm service
  final alarmService = AlarmService();
  await alarmService.initialize();
  
  runApp(TransitionCurriculumApp());
}

class TransitionCurriculumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transition Curriculum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (c) => SplashScreen(),
        '/onboarding': (c) => OnboardingScreen(),
        '/home': (c) => DashboardScreen(),
        '/profile': (c) {
          final student = ModalRoute.of(c)!.settings.arguments as Student;
          return StudentProfileScreen(student: student);
        },
        '/progress': (c) {
          final student = ModalRoute.of(c)!.settings.arguments as Student;
          return ProgressTrackerScreen(student: student);
        },
        '/reports': (c) {
          final student = ModalRoute.of(c)!.settings.arguments as Student;
          return ReportsScreen(student: student);
        },
        '/lesson_planner': (c) {
          final student = ModalRoute.of(c)!.settings.arguments as Student;
          return LessonPlannerScreen(student: student);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/lesson_from_alarm') {
          final lesson = settings.arguments as Lesson;
          return MaterialPageRoute(
            builder: (ctx) => LessonPlannerScreen(
              student: Student(
                id: lesson.studentId,
                name: '',
                disability: '',
                skills: {},
              ),
            ),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}