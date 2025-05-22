import 'dart:convert';

class Student {
  final int? id;
  final String name;
  final String disability;
  final Map<String, int> skills;

  Student({
    this.id,
    required this.name,
    required this.disability,
    required this.skills,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'disability': disability,
      'skills': jsonEncode(skills),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      disability: map['disability'],
      skills: map['skills'] != null 
          ? Map<String, int>.from(jsonDecode(map['skills']))
          : <String, int>{},
    );
  }

  static Map<String, int> defaultSkills() {
    return {
      "Care Skills": 0,
      "Functional Academic Skills": 0,
      "Life Skills": 0,
      "Pre-Vocational Skills": 0,
      "Livelihood Skills": 0,
      "Enrichment Skills": 0,
      "Career Skills": 0,
    };
  }

  @override
  String toString() {
    return 'Student(id: $id, name: $name, disability: $disability, skills: $skills)';
  }
}