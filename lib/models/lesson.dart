class Lesson {
  final String id;
  final int studentId;
  final String title;
  final String description;
  final String skillCategory;
  final List<String> objectives;
  final DateTime date;
  final Duration duration;
  final List<String> materials;
  final bool completed;

  Lesson({
    required this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.skillCategory,
    required this.objectives,
    required this.date,
    required this.duration,
    required this.materials,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'description': description,
      'skillCategory': skillCategory,
      'objectives': objectives,
      'date': date.toIso8601String(),
      'duration': duration.inMinutes,
      'materials': materials,
      'completed': completed,
    };
  }

  static Lesson fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String,
      studentId: map['studentId'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      skillCategory: map['skillCategory'] as String,
      objectives: List<String>.from(map['objectives'] as List<dynamic>),
      date: DateTime.parse(map['date'] as String),
      duration: Duration(minutes: map['duration'] as int),
      materials: List<String>.from(map['materials'] as List<dynamic>),
      completed: map['completed'] as bool,
    );
  }

  Lesson copyWith({
    String? id,
    int? studentId,
    String? title,
    String? description,
    String? skillCategory,
    List<String>? objectives,
    DateTime? date,
    Duration? duration,
    List<String>? materials,
    bool? completed,
  }) {
    return Lesson(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      skillCategory: skillCategory ?? this.skillCategory,
      objectives: objectives ?? this.objectives,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      materials: materials ?? this.materials,
      completed: completed ?? this.completed,
    );
  }
}