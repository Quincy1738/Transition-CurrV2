import 'dart:convert';

class Skill {
  final String id; // Added for better tracking
  final String name;
  final String category; // "Life Skills", "Career Skills", etc.
  final String description; // Added for skill details
  int progress; // 0-100 (made mutable for updates)
  final DateTime? lastUpdated; // Track when progress was updated
  final List<String> subSkills; // For breaking down complex skills
  final String? icon; // For UI representation

  Skill({
    String? id,
    required this.name,
    required this.category,
    this.description = '',
    this.progress = 0,
    this.lastUpdated,
    this.subSkills = const [],
    this.icon,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'progress': progress,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'subSkills': jsonEncode(subSkills),
      'icon': icon,
    };
  }

  // Create from Map (for database retrieval)
  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'] ?? '',
      progress: map['progress'] ?? 0,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
      subSkills: map['subSkills'] != null
          ? List<String>.from(jsonDecode(map['subSkills']))
          : [],
      icon: map['icon'],
    );
  }

  // Helper to get all 7 categories from the proposal
  static List<String> get skillCategories => const [
    'Care Skills',
    'Functional Academic Skills',
    'Life Skills',
    'Pre-Vocational Skills',
    'Livelihood Skills',
    'Enrichment Skills',
    'Career Skills',
  ];

  // Default icons for each category
  static String? getCategoryIcon(String category) {
    return const {
      'Care Skills': '🧼',
      'Functional Academic Skills': '📚',
      'Life Skills': '🏠',
      'Pre-Vocational Skills': '🛠️',
      'Livelihood Skills': '💼',
      'Enrichment Skills': '🎨',
      'Career Skills': '👔',
    }[category];
  }

  // Create a new skill with updated progress
  Skill copyWith({
    int? progress,
    DateTime? lastUpdated,
  }) {
    return Skill(
      id: id,
      name: name,
      category: category,
      description: description,
      progress: progress ?? this.progress,
      lastUpdated: lastUpdated ?? DateTime.now(),
      subSkills: subSkills,
      icon: icon,
    );
  }

  // For debugging
  @override
  String toString() {
    return 'Skill(id: $id, name: $name, category: $category, progress: $progress%)';
  }
}