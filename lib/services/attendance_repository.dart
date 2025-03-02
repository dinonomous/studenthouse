import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:studenthouse/db/database_helper.dart';
import 'package:studenthouse/services/user_repository.dart';

class AttendanceRepository {
  static Future<void> updateAttendance(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    // Get user ID
    final userId = await UserRepository.getUserId(data['user']);
    if (userId == null) return;

    // Insert courses and attendance records
    final attendanceList = data['attendance'] ?? [];
    for (var record in attendanceList) {
      await _insertCourse(db, record);
      await _insertUserCourse(db, userId, record);
      await _insertAttendance(db, userId, record);
    }
  }

  static Future<void> _insertCourse(
    Database db,
    Map<String, dynamic> record,
  ) async {
    await db.insert(DatabaseHelper.courseTableName, {
      'course_code': record['Course Code'],
      'course_title': record['Course Title'],
      'category': record['Category'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> _insertUserCourse(
    Database db,
    int userId,
    Map<String, dynamic> record,
  ) async {
    await db.insert(
      DatabaseHelper.userCoursesTableName,
      {
        'user_id': userId,
        'course_code': record['Course Code'],
        'faculty': record['Faculty Name'],
        'slot': record['Slot'],
        'university_practical_details': record['University Practical Details'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> _insertAttendance(
    Database db,
    int userId,
    Map<String, dynamic> record,
  ) async {
    await db.insert(
      DatabaseHelper.attendanceTableName,
      {
        'user_id': userId,
        'course_code': record['Course Code'],
        'faculty': record['Faculty Name'],
        'slot': record['Slot'],
        'hours_conducted': int.tryParse(record['Hours Conducted']) ?? 0,
        'hours_absent': int.tryParse(record['Hours Absent']) ?? 0,
        'attendance_percent': double.tryParse(record['Attn %']) ?? 0.0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getAttendance(int userId) async {
    final userId = await UserRepository.getCurrentUserId();
    if (userId == null) {
      return [];
    }
    final attendanceList = await DatabaseHelper.instance.getAttendanceWithCourse(userId);
    print('Fetched attendance records for user $userId:');
    print(attendanceList);
    return attendanceList;
  }
}
