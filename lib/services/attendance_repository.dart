import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:studenthouse/db/database_helper.dart';
import 'package:studenthouse/services/user_repository.dart';
class AttendanceRepository {
  static Future<void> updateAttendance(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.instance.database;

    // Extract user data
    final userInfo = data['user'] ?? [];
    Map<String, String> userMap = {};
    for (var item in userInfo) {
      item.forEach((key, value) {
        userMap[key.replaceAll(':', '').trim()] = value;
      });
    }

    // Get user ID
    final userId = await UserRepository.getUserId(userMap['Registration Number']);
    if (userId == null) return;

    // Insert courses and attendance records
    final attendanceList = data['attendance'] ?? [];
    for (var record in attendanceList) {
      await _insertCourse(db, record);
      await _insertUserCourse(db, userId, record);
      await _insertAttendance(db, userId, record);
    }
  }

  static Future<void> _insertCourse(Database db, Map<String, dynamic> record) async {
    await db.insert(
      DatabaseHelper.courseTableName,
      {
        'course_code': record['Course Code'],
        'course_title': record['Course Title'],
        'category': record['Category'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> _insertUserCourse(Database db, int userId, Map<String, dynamic> record) async {
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

  static Future<void> _insertAttendance(Database db, int userId, Map<String, dynamic> record) async {
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
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      DatabaseHelper.attendanceTableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    print('Fetched attendance records for user $userId:');
    print(result);
    return result;
  }
}
