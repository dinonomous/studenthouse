import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:studenthouse/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static Future<void> setCurrentUserId(String regNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId(regNumber);
    await prefs.setInt('current_user_id', userId!);
  }

  static Future<void> removeCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');
    print("DEBUG: getCurrentUserId called with userId: $userId");
    if (userId != null) {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        DatabaseHelper.userTableName,
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (result.isEmpty) {
        await prefs.remove('current_user_id');
        return null;
      }
    }
    return userId;
  }

  static Future<int?> getUserId(String? regNumber) async {
    if (regNumber == null) {
      print("DEBUG: getUserId called with null regNumber.");
      return null;
    }
    print("DEBUG: getUserId called with regNumber: $regNumber");

    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      DatabaseHelper.userTableName,
      columns: ['id'],
      where: 'reg_number = ?',
      whereArgs: [regNumber],
    );

    print("DEBUG: Query result for regNumber $regNumber: $result");

    final userId = result.isNotEmpty ? result.first['id'] as int : null;
    print("DEBUG: Returning userId: $userId for regNumber: $regNumber");
    return userId;
  }

  static Future<Map<String, dynamic>> getUser(String? regNumber) async {
    if (regNumber == null) return {};
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      DatabaseHelper.userTableName,
      where: 'reg_number = ?',
      whereArgs: [regNumber],
    );
    return result.isNotEmpty ? result.first : {};
  }

  static Future<int?> setUser(
    Map<String, dynamic> user,
    String email,
    String password,
  ) async {
    try {
      // Hash the password using SHA-256.
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      print("DEBUG: Hashed password: $hashedPassword");

      final db = await DatabaseHelper.instance.database;
      final int userId = await db.insert(DatabaseHelper.userTableName, {
        'reg_number': user['Registration Number'],
        'name': user['Name'],
        'program': user['Program'],
        'department': user['Department'],
        'specialization': user['Specialization'],
        'semester': user['Semester'],
        'email': email,
        'password': hashedPassword, // Store hashed password
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print("DEBUG: User inserted/updated with ID: $userId");

      await setCurrentUserId(user['Registration Number']);
      return userId;
    } catch (e) {
      print("DEBUG: Error in setUser: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(DatabaseHelper.userTableName);
    return result;
  }

  static Future<String> getUserEmail(int? id) async {
    if (id == null) {
      print("DEBUG: getUserEmail called with null id.");
      return '';
    }
    print("DEBUG: getUserEmail called with id: $id");

    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      DatabaseHelper.userTableName,
      columns: ['email'],
      where: 'id = ?',
      whereArgs: [id],
    );

    print("DEBUG: Query result for id $id: $result");

    final email = result.isNotEmpty ? result.first['email'] as String : '';
    print("DEBUG: Returning email: $email for id: $id");
    return email;
  }
}
