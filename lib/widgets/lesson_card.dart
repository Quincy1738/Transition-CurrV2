import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/lesson.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/utils/constants.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  
  const LessonCard({Key? key, required this.lesson, required Student student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.categoryColors[lesson.skillCategory],
                  ),
                ),
                Chip(
                  label: Text(
                    lesson.date.toFormattedString(),
                    style: TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              lesson.description,
              style: AppTextStyles.body,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 16,
                  color: Colors.grey,
                ),
                SizedBox(width: 4),
                Text(
                  lesson.skillCategory,
                  style: AppTextStyles.caption,
                ),
                Spacer(),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey,
                ),
                SizedBox(width: 4),
                Text(
                  lesson.duration.toFormattedString(),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            if (lesson.objectives.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Objectives:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Column(
                children: lesson.objectives
                    .map((obj) => Padding(
                          padding: EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 16, color: Colors.green),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  obj,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}