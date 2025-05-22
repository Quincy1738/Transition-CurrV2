import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/utils/constants.dart';

class StudentProfileScreen extends StatelessWidget {
  final Student student;

  const StudentProfileScreen({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple, // Set purple background color
      appBar: AppBar(
        title: Text(student.name),
        actions: [
          // Reports button
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Report',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/reports',
                arguments: student,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student basic info
            Text(
              "Disability: ${student.disability}",
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
            SizedBox(height: 20),

            // Skills progress section
            Text(
              "Skills Progress:",
              style: AppTextStyles.subheader.copyWith(color: Colors.white),
            ),
            ...student.skills.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${entry.key} (${entry.value}%)",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / 100,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: AppColors.categoryColors[entry.key] ?? Colors.white,
                    ),
                  ],
                ),
              );
            }).toList(),

            SizedBox(height: 24),

            // Action cards for the four modules
            Text(
              "Actions:",
              style: AppTextStyles.subheader.copyWith(color: Colors.white),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionCard(
                  icon: Icons.book,
                  label: "Plan Lessons",
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/lesson_planner',
                    arguments: student,
                  ),
                ),
                _ActionCard(
                  icon: Icons.timeline,
                  label: "Track Progress",
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/progress',
                    arguments: student,
                  ),
                ),
                _ActionCard(
                  icon: Icons.picture_as_pdf,
                  label: "Generate Reports",
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/reports',
                    arguments: student,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          width: 140,
          height: 100,
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}