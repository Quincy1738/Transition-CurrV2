import 'dart:async';

import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/models/lesson.dart';
import 'package:transition_curriculum/services/database_helper.dart';
import 'package:transition_curriculum/services/alarm_service.dart';
import 'package:transition_curriculum/utils/constants.dart';
import 'package:transition_curriculum/widgets/lesson_card.dart';

class LessonPlannerScreen extends StatefulWidget {
  final Student student;
  const LessonPlannerScreen({Key? key, required this.student}) : super(key: key);

  @override
  _LessonPlannerScreenState createState() => _LessonPlannerScreenState();
}

class _LessonPlannerScreenState extends State<LessonPlannerScreen> {

  List<Lesson> _lessons = [];
  bool _loading = true;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = skillCategories.first;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Duration _selectedDuration = lessonDurations[1];

  Timer? _countdownTimer;  // <--- Add this here


  @override
  void initState() {
    super.initState();
    _loadLessons();
    _startCountdownTimer();  // <--- Add this here
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }


  String _formatDuration(Duration d) {  // <--- Add this method inside the class
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return "$h:${twoDigits(m)}:${twoDigits(s)}";
    return "${twoDigits(m)}:${twoDigits(s)}";
  }

  void _startCountdownTimer() {  // <--- Add this method inside the class
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) setState(() {}); // refresh UI every second
    });
  }

  Future<void> _loadLessons() async {
    print('Loading lessons for student: ${widget.student.name} (ID: ${widget.student.id})');
    setState(() => _loading = true);

    final sid = widget.student.id;
    if (sid != null) {
      try {
        final existing = await DatabaseHelper.instance.getLessonsForStudent(sid);
        print('Successfully loaded ${existing.length} lessons from database');

        if (mounted) {
          setState(() {
            _lessons = existing;
            _loading = false;
          });
        }

        // Debug: Print each lesson
        for (var lesson in existing) {
          print('Lesson: ${lesson.title} - ${lesson.date} - ${lesson.skillCategory}');
        }

      } catch (e) {
        print('Error loading lessons: $e');
        if (mounted) {
          setState(() {
            _lessons = [];
            _loading = false;
          });
        }
      }
    } else {
      print('Student ID is null, cannot load lessons');
      if (mounted) {
        setState(() {
          _lessons = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _showAddLessonDialog() async {
    // Reset form fields
    _titleController.clear();
    _descController.clear();
    _selectedCategory = skillCategories.first;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedDuration = lessonDurations[1];

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDState) {
        return AlertDialog(
          title: Text("Plan New Lesson for ${widget.student.name}"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Lesson Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? "Title is required" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: "Description (Optional)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Skill Category",
                    border: OutlineInputBorder(),
                  ),
                  items: skillCategories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (v) => setDState(() => _selectedCategory = v!),
                ),
                SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text("Date"),
                    subtitle: Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ),
                SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text("Time"),
                    subtitle: Text(_selectedTime.format(ctx)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) {
                        setDState(() => _selectedTime = picked);
                      }
                    },
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<Duration>(
                  value: _selectedDuration,
                  decoration: InputDecoration(
                    labelText: "Duration",
                    border: OutlineInputBorder(),
                  ),
                  items: lessonDurations
                      .map((dur) => DropdownMenuItem(
                          value: dur, child: Text(dur.toFormattedString())))
                      .toList(),
                  onChanged: (v) => setDState(() => _selectedDuration = v!),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  print('Form validation failed');
                  return;
                }

                final sid = widget.student.id;
                if (sid == null) {
                  print('Student ID is null, cannot save lesson');
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: Student ID is missing'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Combine date and time
                final lessonDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );

                // Create lesson with unique ID
                final lessonId = 'lesson_${DateTime.now().millisecondsSinceEpoch}_${sid}';
                final newLesson = Lesson(
                  id: lessonId,
                  studentId: sid,
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                  skillCategory: _selectedCategory,
                  objectives: [], // Can be expanded later
                  date: lessonDateTime,
                  duration: _selectedDuration,
                  materials: [], // Can be expanded later
                  completed: false,
                );

                print('Creating lesson: ${newLesson.title} for student $sid at ${newLesson.date}');

                try {
                  // Show loading indicator
                  showDialog(
                    context: ctx,
                    barrierDismissible: false,
                    builder: (c) => Center(child: CircularProgressIndicator()),
                  );

                  // Save lesson to database
                  final success = await DatabaseHelper.instance.insertLesson(sid, newLesson);
                  print('Lesson insertion result: $success');

                  if (success) {
                    // Schedule alarm for lesson
                    try {
                      await AlarmService().scheduleLessonAlarm(newLesson);
                      print('Alarm scheduled successfully for lesson: ${newLesson.title}');
                    } catch (alarmError) {
                      print('Warning: Could not schedule alarm: $alarmError');
                      // Don't fail the whole operation if alarm fails
                    }

                    // Close loading dialog
                    Navigator.pop(ctx);

                    // Close form dialog
                    Navigator.pop(ctx);

                    // Reload lessons from database
                    await _loadLessons();

                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lesson "${newLesson.title}" has been added successfully!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  } else {
                    // Close loading dialog
                    Navigator.pop(ctx);
                    throw Exception('Database insertion returned false');
                  }

                } catch (e) {
                  print('Error saving lesson: $e');

                  // Close loading dialog if it's open
                  if (Navigator.canPop(ctx)) {
                    Navigator.pop(ctx);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save lesson: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              child: Text("Save Lesson"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Lesson Planner for ${widget.student.name}"),
        actions: [
          IconButton(
            icon: Icon(Icons.alarm),
            onPressed: () {
              _showAlarmInfo();
            },
            tooltip: "Alarm Status",
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print('Manual refresh triggered');
              _loadLessons();
            },
            tooltip: "Refresh lessons",
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading lessons...'),
                ],
              ),
            )
          : _lessons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No lessons planned yet for ${widget.student.name}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Plan First Lesson"),
                        onPressed: _showAddLessonDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLessons,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _lessons.length,
                    itemBuilder: (ctx, i) {
                      final lesson = _lessons[i];
                      final now = DateTime.now();
                      final lessonStart = lesson.date;
                      final lessonEnd = lesson.date.add(lesson.duration);

                      String countdownText;
                      if (now.isBefore(lessonStart)) {
                        final diff = lessonStart.difference(now);
                        countdownText = "Starts in ${_formatDuration(diff)}";
                      } else if (now.isAfter(lessonEnd)) {
                        countdownText = "Completed";
                      } else {
                        final diff = lessonEnd.difference(now);
                        countdownText = "Ends in ${_formatDuration(diff)}";
                      }

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LessonCard(
                              lesson: lesson,
                              student: widget.student,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text(
                                countdownText,
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },

                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddLessonDialog,
        tooltip: "Plan new lesson",
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAlarmInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.alarm, color: Colors.blue),
            SizedBox(width: 8),
            Text("Lesson Alarms"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your phone will automatically ring/vibrate when scheduled lessons are about to start.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              "• Alarms are set for each lesson you create",
              style: TextStyle(fontSize: 14),
            ),
            Text(
              "• Notifications work even when the app is closed",
              style: TextStyle(fontSize: 14),
            ),
            Text(
              "• You'll be alerted 2 minutes before lesson time",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Got it!"),
          ),
        ],
      ),
    );
  }
}