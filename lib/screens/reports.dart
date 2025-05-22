import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:transition_curriculum/models/student.dart';

class ReportsScreen extends StatelessWidget {
  final Student student;

  const ReportsScreen({Key? key, required this.student}) : super(key: key);

  /// Builds an insights section with trends and suggestions
  pw.Widget _buildInsights() {
    final entries = student.skills.entries.toList();
    if (entries.isEmpty) {
      return pw.Text('No skill data available for insights.');
    }

    // Calculate average, strongest, weakest
    final values = entries.map((e) => e.value).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final top = entries.reduce((a, b) => a.value > b.value ? a : b);
    final bottom = entries.reduce((a, b) => a.value < b.value ? a : b);

    // Skills below threshold
    final needsWork = entries.where((e) => e.value < 50).map((e) => e.key).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(level: 1, text: 'Insights'),
        pw.Text('Average Progress: ${avg.toStringAsFixed(1)}%'),
        pw.Text('Top Skill: ${top.key} (${top.value}%)'),
        pw.Text('Needs Improvement: ${bottom.key} (${bottom.value}%)'),
        if (needsWork.isNotEmpty) pw.SizedBox(height: 10),
        if (needsWork.isNotEmpty) pw.Text('Skills Below 50%:'),
        if (needsWork.isNotEmpty) ...needsWork.map((s) => pw.Bullet(text: s)),
        pw.SizedBox(height: 10),
        pw.Header(level: 2, text: 'Suggestions'),
        ..._buildSuggestions(needsWork),
      ],
    );
  }

  List<pw.Widget> _buildSuggestions(List<String> skills) {
    if (skills.isEmpty) {
      return [
        pw.Text('All skills are above 50%. Keep up the great work!'),
      ];
    }
    return skills.map((skill) {
      return pw.Bullet(
        text:
            'Focus on $skill with targeted practice sessions and track progress weekly.',
      );
    }).toList();
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Header(level: 0, text: 'Student Progress Report'),
          ),
          pw.Text('Name: ${student.name}'),
          pw.Text('Disability: ${student.disability}'),
          pw.SizedBox(height: 20),
          pw.Header(level: 1, text: 'Skills Progress'),
          pw.Table.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            data: [
              ['Skill', 'Progress'],
              ...student.skills.entries.map((e) => [e.key, '${e.value}%']),
            ],
          ),
          pw.SizedBox(height: 20),
          _buildInsights(),
          pw.SizedBox(height: 20),
          pw.Text(
            'Generated on: ${DateTime.now().toLocal()}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ],
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${student.name}'s Reports"),
      ),
      body: PdfPreview(
        useActions: true,
        canChangeOrientation: false,
        build: (format) async => (await _generatePdf()).save(),
      ),
    );
  }
}