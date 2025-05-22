import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/skill.dart';

class SkillCard extends StatelessWidget {
  final Skill skill;
  final Function(int) onProgressChanged;

  const SkillCard({
    Key? key,
    required this.skill,
    required this.onProgressChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              skill.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Category: ${skill.category}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: skill.progress / 100,
                    backgroundColor: Colors.grey[200],
                    color: Colors.green,
                    minHeight: 10,
                  ),
                ),
                SizedBox(width: 10),
                Text("${skill.progress}%"),
              ],
            ),
            SizedBox(height: 16),
            Slider(
              value: skill.progress.toDouble(),
              min: 0,
              max: 100,
              divisions: 10,
              label: skill.progress.toString(),
              onChanged: (value) {
                onProgressChanged(value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }
}