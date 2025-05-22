import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';

import '../models/student.dart';
import '../models/lesson.dart';

/// Defines common database operations for Student & Lesson entities
abstract class BaseDatabaseHelper {
  // Student CRUD
  Future<int> insertStudent(Student student);
  Future<List<Student>> getStudents();
  Future<int> updateStudent(Student student);
  Future<int> deleteStudent(int id);

  // Lesson CRUD
  Future<bool> insertLesson(int studentId, Lesson lesson);
  Future<List<Lesson>> getLessonsForStudent(int studentId);
  Future<List<Lesson>> getAllLessons(); // New method for alarm service
  Future<int> updateLesson(Lesson lesson);
  Future<int> deleteLesson(String lessonId);
  Future<Lesson?> getLessonById(String lessonId);
}

////////////////////////////////////////////////////////////////////////////////
// MOBILE (SQLite) IMPLEMENTATION
////////////////////////////////////////////////////////////////////////////////

class MobileDatabaseHelper implements BaseDatabaseHelper {
  static sql.Database? _database;

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sql.Database> _initDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final fullPath = path.join(dbPath, 'transition_curriculum.db');

    print('Initializing database at: $fullPath');

    return await sql.openDatabase(
      fullPath,
      version: 5, // Increased version for clean slate
      onCreate: (db, version) async {
        print('Creating new database tables (version $version)');
        
        await db.execute('''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            disability TEXT NOT NULL,
            skills TEXT NOT NULL
          )
        ''');
        
        await db.execute('''
          CREATE TABLE lessons(
            id TEXT PRIMARY KEY,
            studentId INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT DEFAULT '',
            skillCategory TEXT NOT NULL,
            objectives TEXT DEFAULT '[]',
            date TEXT NOT NULL,
            duration INTEGER DEFAULT 60,
            materials TEXT DEFAULT '[]',
            completed INTEGER DEFAULT 0,
            FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE
          )
        ''');
        
        print('Database tables created successfully');
      },
      onUpgrade: (db, oldV, newV) async {
        print('Upgrading database from version $oldV to $newV');
        
        if (oldV < 5) {
          // Complete recreation for clean slate
          await db.execute('DROP TABLE IF EXISTS lessons');
          await db.execute('DROP TABLE IF EXISTS students');
          
          await db.execute('''
            CREATE TABLE students(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              disability TEXT NOT NULL,
              skills TEXT NOT NULL
            )
          ''');
          
          await db.execute('''
            CREATE TABLE lessons(
              id TEXT PRIMARY KEY,
              studentId INTEGER NOT NULL,
              title TEXT NOT NULL,
              description TEXT DEFAULT '',
              skillCategory TEXT NOT NULL,
              objectives TEXT DEFAULT '[]',
              date TEXT NOT NULL,
              duration INTEGER DEFAULT 60,
              materials TEXT DEFAULT '[]',
              completed INTEGER DEFAULT 0,
              FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE
            )
          ''');
          
          print('Database recreated successfully');
        }
      },
    );
  }

  // --- Student methods ---
  @override
  Future<int> insertStudent(Student student) async {
    final db = await database;
    final result = await db.insert('students', student.toMap());
    print('Inserted student: ${student.name} with ID: $result');
    return result;
  }

  @override
  Future<List<Student>> getStudents() async {
    try {
      final db = await database;
      final maps = await db.query('students', orderBy: 'name ASC');
      final students = maps.map((m) {
        // Ensure ID is properly assigned
        final student = Student.fromMap(m);
        print('Retrieved student: ${student.name} with ID: ${student.id}');
        return student;
      }).toList();
      print('Retrieved ${students.length} students from database');
      return students;
    } catch (e) {
      debugPrint("Error loading students: $e");
      return [];
    }
  }

  @override
  Future<int> updateStudent(Student student) async {
    final db = await database;
    final result = await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
    print('Updated student: ${student.name}, rows affected: $result');
    return result;
  }

  @override
  Future<int> deleteStudent(int id) async {
    final db = await database;
    final result = await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Deleted student with ID: $id, rows affected: $result');
    return result;
  }

  // --- Lesson methods ---
  @override
  Future<bool> insertLesson(int studentId, Lesson lesson) async {
    final db = await database;
    try {
      print('Inserting lesson: ${lesson.title} for student ID: $studentId');
      
      // Validate studentId exists
      final studentExists = await db.query(
        'students',
        where: 'id = ?',
        whereArgs: [studentId],
        limit: 1,
      );
      
      if (studentExists.isEmpty) {
        print('Error: Student with ID $studentId does not exist');
        return false;
      }
      
      final lessonData = {
        'id': lesson.id,
        'studentId': studentId,
        'title': lesson.title,
        'description': lesson.description,
        'skillCategory': lesson.skillCategory,
        'objectives': jsonEncode(lesson.objectives),
        'date': lesson.date.toIso8601String(),
        'duration': lesson.duration.inMinutes,
        'materials': jsonEncode(lesson.materials),
        'completed': lesson.completed ? 1 : 0,
      };
      
      print('Lesson data to insert: $lessonData');
      
      final result = await db.insert('lessons', lessonData);
      print('Lesson inserted successfully, result: $result');
      
      // Verify insertion
      final verification = await db.query(
        'lessons',
        where: 'id = ?',
        whereArgs: [lesson.id],
      );
      
      print('Verification query returned ${verification.length} rows');
      if (verification.isNotEmpty) {
        print('Verified lesson exists: ${verification.first}');
      }
      
      return true;
    } catch (e) {
      debugPrint("Error inserting lesson: $e");
      debugPrint("Lesson details: ${lesson.toString()}");
      return false;
    }
  }

  @override
  Future<List<Lesson>> getLessonsForStudent(int studentId) async {
    try {
      final db = await database;
      print('Querying lessons for student ID: $studentId');
      
      // First verify student exists
      final studentExists = await db.query(
        'students',
        where: 'id = ?',
        whereArgs: [studentId],
        limit: 1,
      );
      
      if (studentExists.isEmpty) {
        print('Warning: Student with ID $studentId does not exist');
        return [];
      }
      
      final rows = await db.query(
        'lessons',
        where: 'studentId = ?',
        whereArgs: [studentId],
        orderBy: 'date ASC',
      );
      
      print('Query returned ${rows.length} lessons for student $studentId');
      
      final lessons = rows.map((m) {
        print('Processing lesson row: $m');
        return Lesson(
          id: m['id'] as String,
          studentId: m['studentId'] as int,
          title: m['title'] as String,
          description: (m['description'] as String?) ?? '',
          skillCategory: m['skillCategory'] as String,
          objectives: List<String>.from(
            jsonDecode((m['objectives'] as String?) ?? '[]')
          ),
          date: DateTime.parse(m['date'] as String),
          duration: Duration(minutes: (m['duration'] as int?) ?? 60),
          materials: List<String>.from(
            jsonDecode((m['materials'] as String?) ?? '[]')
          ),
          completed: (m['completed'] as int? ?? 0) == 1,
        );
      }).toList();
      
      print('Successfully converted ${lessons.length} lessons');
      return lessons;
    } catch (e) {
      debugPrint("Error loading lessons for student $studentId: $e");
      return [];
    }
  }

  @override
  Future<List<Lesson>> getAllLessons() async {
    try {
      final db = await database;
      print('Querying all lessons from database');
      
      final rows = await db.query(
        'lessons',
        orderBy: 'date ASC',
      );
      
      print('Query returned ${rows.length} total lessons');
      
      final lessons = rows.map((m) {
        return Lesson(
          id: m['id'] as String,
          studentId: m['studentId'] as int,
          title: m['title'] as String,
          description: (m['description'] as String?) ?? '',
          skillCategory: m['skillCategory'] as String,
          objectives: List<String>.from(
            jsonDecode((m['objectives'] as String?) ?? '[]')
          ),
          date: DateTime.parse(m['date'] as String),
          duration: Duration(minutes: (m['duration'] as int?) ?? 60),
          materials: List<String>.from(
            jsonDecode((m['materials'] as String?) ?? '[]')
          ),
          completed: (m['completed'] as int? ?? 0) == 1,
        );
      }).toList();
      
      return lessons;
    } catch (e) {
      debugPrint("Error loading all lessons: $e");
      return [];
    }
  }

  @override
  Future<int> updateLesson(Lesson lesson) async {
    final db = await database;
    try {
      final result = await db.update(
        'lessons',
        {
          'title': lesson.title,
          'description': lesson.description,
          'skillCategory': lesson.skillCategory,
          'objectives': jsonEncode(lesson.objectives),
          'date': lesson.date.toIso8601String(),
          'duration': lesson.duration.inMinutes,
          'materials': jsonEncode(lesson.materials),
          'completed': lesson.completed ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [lesson.id],
      );
      print('Updated lesson: ${lesson.title}, rows affected: $result');
      return result;
    } catch (e) {
      debugPrint("Error updating lesson: $e");
      return 0;
    }
  }

  @override
  Future<int> deleteLesson(String lessonId) async {
    final db = await database;
    try {
      final result = await db.delete(
        'lessons',
        where: 'id = ?',
        whereArgs: [lessonId],
      );
      print('Deleted lesson with ID: $lessonId, rows affected: $result');
      return result;
    } catch (e) {
      debugPrint("Error deleting lesson: $e");
      return 0;
    }
  }

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      final db = await database;
      final rows = await db.query(
        'lessons',
        where: 'id = ?',
        whereArgs: [lessonId],
        limit: 1,
      );
      
      if (rows.isEmpty) {
        print('No lesson found with ID: $lessonId');
        return null;
      }
      
      final m = rows.first;
      return Lesson(
        id: m['id'] as String,
        studentId: m['studentId'] as int,
        title: m['title'] as String,
        description: (m['description'] as String?) ?? '',
        skillCategory: m['skillCategory'] as String,
        objectives: List<String>.from(
          jsonDecode((m['objectives'] as String?) ?? '[]')
        ),
        date: DateTime.parse(m['date'] as String),
        duration: Duration(minutes: (m['duration'] as int?) ?? 60),
        materials: List<String>.from(
          jsonDecode((m['materials'] as String?) ?? '[]')
        ),
        completed: (m['completed'] as int? ?? 0) == 1,
      );
    } catch (e) {
      debugPrint("Error getting lesson by ID $lessonId: $e");
      return null;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// WEB (SharedPreferences) IMPLEMENTATION
////////////////////////////////////////////////////////////////////////////////

class WebDatabaseHelper implements BaseDatabaseHelper {
  static const _studentsKey = 'students_data';
  static const _lessonsKey = 'lessons_data';
  static const _nextStudentIdKey = 'next_student_id';

  Future<int> _getNextStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    final nextId = prefs.getInt(_nextStudentIdKey) ?? 1;
    await prefs.setInt(_nextStudentIdKey, nextId + 1);
    return nextId;
  }

  @override
  Future<int> insertStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    final students = await getStudents();
    
    // Assign a new ID if student doesn't have one
    final newId = await _getNextStudentId();
    final studentWithId = Student(
      id: newId,
      name: student.name,
      disability: student.disability,
      skills: student.skills,
    );
    
    students.add(studentWithId);
    await prefs.setString(
      _studentsKey,
      jsonEncode(students.map((s) => s.toMap()).toList()),
    );
    print('Web: Inserted student: ${student.name} with ID: $newId');
    return newId;
  }

  @override
  Future<List<Student>> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_studentsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final students = list.map((j) {
      final student = Student.fromMap(j as Map<String, dynamic>);
      print('Web: Retrieved student: ${student.name} with ID: ${student.id}');
      return student;
    }).toList();
    print('Web: Retrieved ${students.length} students');
    return students;
  }

  @override
  Future<int> updateStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    final students = await getStudents();
    final idx = students.indexWhere((s) => s.id == student.id);
    if (idx != -1) {
      students[idx] = student;
      await prefs.setString(
        _studentsKey,
        jsonEncode(students.map((s) => s.toMap()).toList()),
      );
      print('Web: Updated student: ${student.name}');
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteStudent(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final students = await getStudents();
    students.removeWhere((s) => s.id == id);
    await prefs.setString(
      _studentsKey,
      jsonEncode(students.map((s) => s.toMap()).toList()),
    );
    print('Web: Deleted student with ID: $id');
    return 1;
  }

  @override
  Future<bool> insertLesson(int studentId, Lesson lesson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lessonsKey);
      final list = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
      
      // Validate student exists
      final students = await getStudents();
      final studentExists = students.any((s) => s.id == studentId);
      
      if (!studentExists) {
        print('Web: Error - Student with ID $studentId does not exist');
        return false;
      }
      
      list.add({
        'studentId': studentId,
        'lesson': lesson.toMap(),
      });
      
      await prefs.setString(_lessonsKey, jsonEncode(list));
      print('Web: Inserted lesson: ${lesson.title} for student $studentId');
      return true;
    } catch (e) {
      debugPrint("Web: Error inserting lesson: $e");
      return false;
    }
  }

  @override
  Future<List<Lesson>> getLessonsForStudent(int studentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lessonsKey);
      if (raw == null) return <Lesson>[];
      
      // Validate student exists
      final students = await getStudents();
      final studentExists = students.any((s) => s.id == studentId);
      
      if (!studentExists) {
        print('Web: Warning - Student with ID $studentId does not exist');
        return [];
      }
      
      final decoded = jsonDecode(raw) as List<dynamic>;
      final lessons = decoded
          .where((e) => e['studentId'] == studentId)
          .map((e) => Lesson.fromMap(e['lesson'] as Map<String, dynamic>))
          .toList();
      
      print('Web: Retrieved ${lessons.length} lessons for student $studentId');
      return lessons;
    } catch (e) {
      debugPrint("Web: Error loading lessons for student $studentId: $e");
      return [];
    }
  }

  @override
  Future<List<Lesson>> getAllLessons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lessonsKey);
      if (raw == null) return <Lesson>[];
      
      final decoded = jsonDecode(raw) as List<dynamic>;
      final lessons = decoded
          .map((e) => Lesson.fromMap(e['lesson'] as Map<String, dynamic>))
          .toList();
      
      print('Web: Retrieved ${lessons.length} total lessons');
      return lessons;
    } catch (e) {
      debugPrint("Web: Error loading all lessons: $e");
      return [];
    }
  }

  @override
  Future<int> updateLesson(Lesson lesson) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lessonsKey);
      if (raw == null) return 0;
      
      final decoded = jsonDecode(raw) as List<dynamic>;
      final updatedList = decoded.map((e) {
        if ((e['lesson'] as Map<String, dynamic>)['id'] == lesson.id) {
          return {'studentId': e['studentId'], 'lesson': lesson.toMap()};
        }
        return e;
      }).toList();
      
      await prefs.setString(_lessonsKey, jsonEncode(updatedList));
      print('Web: Updated lesson: ${lesson.title}');
      return 1;
    } catch (e) {
      debugPrint("Web: Error updating lesson: $e");
      return 0;
    }
  }

  @override
  Future<int> deleteLesson(String lessonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lessonsKey);
      if (raw == null) return 0;
      
      final decoded = jsonDecode(raw) as List<dynamic>;
      final updatedList = decoded
          .where((e) => (e['lesson'] as Map<String, dynamic>)['id'] != lessonId)
          .toList();
      
      await prefs.setString(_lessonsKey, jsonEncode(updatedList));
      print('Web: Deleted lesson with ID: $lessonId');
      return 1;
    } catch (e) {
      debugPrint("Web: Error deleting lesson: $e");
      return 0;
    }
  }

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lessonsKey);
      if (raw == null) return null;
      
      final decoded = jsonDecode(raw) as List<dynamic>;
      final lessonData = decoded.firstWhere(
        (e) => (e['lesson'] as Map<String, dynamic>)['id'] == lessonId,
        orElse: () => null,
      );
      
      if (lessonData == null) {
        print('Web: No lesson found with ID: $lessonId');
        return null;
      }
      
      return Lesson.fromMap(lessonData['lesson'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint("Web: Error getting lesson by ID $lessonId: $e");
      return null;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// FACTORY TO PROVIDE THE RIGHT IMPLEMENTATION
////////////////////////////////////////////////////////////////////////////////

class DatabaseHelper {
  static BaseDatabaseHelper get instance {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      print('Using WebDatabaseHelper implementation');
      return WebDatabaseHelper();
    } else {
      print('Using MobileDatabaseHelper implementation');
      return MobileDatabaseHelper();
    }
  }
}