import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/lesson.dart';
import 'package:transition_curriculum/services/database_helper.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  Timer? _timer;
  List<Lesson> _scheduledLessons = [];
  bool _isInitialized = false;
  BuildContext? _currentContext;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Start checking for lessons every 30 seconds
    _startLessonChecker();
    
    _isInitialized = true;
    print('AlarmService initialized successfully - checking lessons every 30 seconds');
  }

  void setContext(BuildContext context) {
    _currentContext = context;
  }

  void _startLessonChecker() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      await _checkForUpcomingLessons();
    });
  }

  Future<void> _checkForUpcomingLessons() async {
    try {
      final now = DateTime.now();
      final allLessons = await DatabaseHelper.instance.getAllLessons();
      
      for (final lesson in allLessons) {
        // Check if lesson is starting within the next 2 minutes
        final timeDifference = lesson.date.difference(now);
        
        if (timeDifference.inMinutes <= 2 && timeDifference.inMinutes >= 0) {
          await _triggerLessonAlarm(lesson);
        }
      }
    } catch (e) {
      print('Error checking for upcoming lessons: $e');
    }
  }

  Future<void> _triggerLessonAlarm(Lesson lesson) async {
    print('🚨 LESSON ALARM: ${lesson.title} is starting now!');
    
    // Vibrate the phone
    await _vibrate();
    
    // Play system sound
    await _playSystemSound();
    
    // Show alert dialog if app is active
    if (_currentContext != null) {
      _showLessonAlert(lesson);
    }
    
    // Keep screen awake for the alarm
    await _wakeUpScreen();
  }

  Future<void> _vibrate() async {
    try {
      // Vibrate in a pattern: short-long-short-long
      if (Platform.isAndroid) {
        await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
        await Future.delayed(Duration(milliseconds: 200));
        await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
        await Future.delayed(Duration(milliseconds: 500));
        await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
        await Future.delayed(Duration(milliseconds: 200));
        await SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
      } else {
        // iOS haptic feedback
        HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 300));
        HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 300));
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      print('Error triggering vibration: $e');
    }
  }

  Future<void> _playSystemSound() async {
    try {
      // Play system notification sound
      await SystemSound.play(SystemSoundType.alert);
      
      // Play multiple times for emphasis
      await Future.delayed(Duration(milliseconds: 1000));
      await SystemSound.play(SystemSoundType.alert);
      await Future.delayed(Duration(milliseconds: 1000));
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Error playing system sound: $e');
    }
  }

  Future<void> _wakeUpScreen() async {
    try {
      // This will help ensure the phone screen turns on
      await SystemChannels.platform.invokeMethod('System.wakeUp');
    } catch (e) {
      // This might not work on all devices, but it's worth trying
      print('Could not wake up screen: $e');
    }
  }

  void _showLessonAlert(Lesson lesson) {
    if (_currentContext == null) return;
    
    showDialog(
      context: _currentContext!,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.red[50],
        title: Row(
          children: [
            Icon(Icons.alarm, color: Colors.red, size: 30),
            SizedBox(width: 8),
            Text(
              'LESSON STARTING NOW!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Category: ${lesson.skillCategory}'),
            SizedBox(height: 4),
            Text('Time: ${_formatTime(lesson.date)}'),
            SizedBox(height: 4),
            Text('Duration: ${lesson.duration.inMinutes} minutes'),
            if (lesson.description.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(lesson.description),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _stopAlarm();
            },
            child: Text('DISMISS'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _stopAlarm();
              // Navigate to lesson planner (optional)
              // Navigator.pushNamed(ctx, '/lesson_planner', arguments: student);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('START LESSON'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _stopAlarm() async {
    // Stop any ongoing vibrations or sounds
    try {
      await SystemChannels.platform.invokeMethod('HapticFeedback.cancel');
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> scheduleLessonAlarm(Lesson lesson) async {
    // Add lesson to our tracking list
    _scheduledLessons.removeWhere((l) => l.id == lesson.id);
    _scheduledLessons.add(lesson);
    
    print('Alarm scheduled for lesson "${lesson.title}" at ${lesson.date}');
    
    // The actual alarm checking is handled by the periodic timer
    // This method just confirms the lesson is in our tracking system
  }

  Future<void> cancelLessonAlarm(String lessonId) async {
    _scheduledLessons.removeWhere((l) => l.id == lessonId);
    print('Cancelled alarm for lesson ID: $lessonId');
  }

  Future<void> cancelAllAlarms() async {
    _scheduledLessons.clear();
    print('Cancelled all lesson alarms');
  }

  List<Lesson> getScheduledLessons() {
    // Return lessons that are scheduled for the future
    final now = DateTime.now();
    return _scheduledLessons.where((lesson) => lesson.date.isAfter(now)).toList();
  }

  // Test method to trigger an immediate alarm
  Future<void> testAlarm(Lesson lesson) async {
    print('🧪 Testing alarm for: ${lesson.title}');
    await _triggerLessonAlarm(lesson);
  }

  void dispose() {
    _timer?.cancel();
    _scheduledLessons.clear();
    _currentContext = null;
    _isInitialized = false;
    print('AlarmService disposed');
  }
}