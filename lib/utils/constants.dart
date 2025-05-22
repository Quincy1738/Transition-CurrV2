// utils/constants.dart

// Skill Categories (matches the 7 categories from your proposal)
import 'dart:ui';

import 'package:flutter/material.dart';

const List<String> skillCategories = [
  'Care Skills',
  'Functional Academic Skills',
  'Life Skills',
  'Pre-Vocational Skills',
  'Livelihood Skills',
  'Enrichment Skills',
  'Career Skills',
];

// Default Lesson Duration Options
const List<Duration> lessonDurations = [
  Duration(minutes: 30),
  Duration(hours: 1),
  Duration(hours: 1, minutes: 30),
  Duration(hours: 2),
];

// Common Materials List
const List<String> commonMaterials = [
  'Worksheets',
  'Visual Aids',
  'Manipulatives',
  'Technology Device',
  'Real-life Objects',
  'Adaptive Tools',
];

// Color Scheme for the App
class AppColors {
  static const Color primary = Color(0xFF3A7DDB); // Primary blue
  static const Color secondary = Color(0xFF6C757D); // Gray
  static const Color accent = Color(0xFF28A745); // Green
  static const Color background = Color(0xFFF8F9FA); // Light gray
  
  // Category-specific colors
  static Map<String, Color> categoryColors = {
    'Care Skills': Color(0xFF17A2B8),      // Teal
    'Functional Academic Skills': Color(0xFF6F42C1), // Purple
    'Life Skills': Color(0xFF20C997),      // Green
    'Pre-Vocational Skills': Color(0xFFFD7E14),     // Orange
    'Livelihood Skills': Color(0xFFDC3545),         // Red
    'Enrichment Skills': Color(0xFFFFC107),         // Yellow
    'Career Skills': Color(0xFF343A40),             // Dark gray
  };
}

// Text Styles
class AppTextStyles {
  static const TextStyle header = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle subheader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );
}

// Helpers for DateTime formatting
extension DateTimeExtensions on DateTime {
  String toFormattedString() {
    return '${_twoDigits(day)}/${_twoDigits(month)}/${year} ${_twoDigits(hour)}:${_twoDigits(minute)}';
  }
  
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

// Helpers for Duration formatting
extension DurationExtensions on Duration {
  String toFormattedString() {
    if (inHours > 0) {
      return '${inHours}h ${inMinutes.remainder(60)}m';
    }
    return '${inMinutes}m';
  }
}

// Sample lesson objectives
List<String> sampleObjectives = [
  'Identify key components of the skill',
  'Demonstrate understanding through practice',
  'Apply skill in simulated environment',
  'Generalize skill to real-world context',
  'Maintain skill over time with minimal prompts',
];