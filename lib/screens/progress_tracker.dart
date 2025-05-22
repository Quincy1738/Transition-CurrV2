import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/skill.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/services/database_helper.dart';
import 'package:transition_curriculum/widgets/skill_card.dart';

class ProgressTrackerScreen extends StatefulWidget {
  final Student student;

  const ProgressTrackerScreen({Key? key, required this.student}) : super(key: key);

  @override
  _ProgressTrackerScreenState createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  late List<Skill> _skills;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSkillsFromStudent();
  }

  Future<void> _loadSkillsFromStudent() async {
    // Build Skill objects from the student.skills map
    final map = widget.student.skills;
    _skills = map.entries.map((e) {
      return Skill(
        name: e.key,
        category: e.key,      // if you want separate category field, adjust
        progress: e.value,
      );
    }).toList();

    setState(() => _loading = false);
  }

  Future<void> _onProgressChanged(int index, int newProgress) async {
    final skill = _skills[index];

    // 1) Update local Skill
    setState(() {
      skill.progress = newProgress;
      // drop the lastUpdated setter since it's final
    });

    // 2) Write back into the Student object
    widget.student.skills[skill.name] = newProgress;

    // 3) Persist student into the DB
    await DatabaseHelper.instance.updateStudent(widget.student);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: Text("${widget.student.name}'s Progress"),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _skills.length,
              itemBuilder: (context, index) {
                return SkillCard(
                  skill: _skills[index],
                  onProgressChanged: (newProgress) {
                    _onProgressChanged(index, newProgress);
                  },
                );
              },
            ),
    );
  }
}