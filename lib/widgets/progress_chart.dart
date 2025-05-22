import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:transition_curriculum/models/student.dart';

class ProgressChart extends StatelessWidget {
  final Student student;

  const ProgressChart({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final skillEntries = student.skills.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= skillEntries.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        skillEntries[index].key,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}%');
                  },
                  reservedSize: 32,
                ),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(skillEntries.length, (index) {
              final skill = skillEntries[index];
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: skill.value.toDouble(),
                    color: _getSkillColor(skill.value),
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Color _getSkillColor(int progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 50) return Colors.blue;
    return Colors.orange;
  }
}