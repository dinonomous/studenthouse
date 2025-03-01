import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = "students_data.db";

  // table name
  static const String userTableName = "users";
  static const String attendanceTableName = "attendance";
  static const String marksTable = "marks";
  static const String courseTableName = "courses";
  static const String userCoursesTableName = "user_courses";
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize Database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create Tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reg_number TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        program TEXT NOT NULL,
        department TEXT NOT NULL,
        specialization TEXT NOT NULL,
        semester TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Global Courses Table
    await db.execute('''
      CREATE TABLE $courseTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_code TEXT UNIQUE NOT NULL,
        course_title TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    // User-Specific Courses Table with Composite Primary Key
    await db.execute('''
      CREATE TABLE $userCoursesTableName (
        user_id INTEGER NOT NULL,
        course_code TEXT NOT NULL,
        faculty TEXT NOT NULL,
        slot TEXT NOT NULL,
        university_practical_details TEXT,
        PRIMARY KEY (user_id, course_code, faculty, slot),
        FOREIGN KEY (user_id) REFERENCES $userTableName(id) ON DELETE CASCADE,
        FOREIGN KEY (course_code) REFERENCES $courseTableName(course_code) ON DELETE CASCADE
      );
    ''');

    // Attendance Table Linked to a Specific User-Course Enrollment
    await db.execute('''
      CREATE TABLE $attendanceTableName (
        user_id INTEGER NOT NULL,
        course_code TEXT NOT NULL,
        faculty TEXT NOT NULL,
        slot TEXT NOT NULL,
        hours_conducted INTEGER NOT NULL,
        hours_absent INTEGER NOT NULL,
        attendance_percent REAL NOT NULL CHECK (attendance_percent BETWEEN 0 AND 100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, course_code, faculty, slot),
        FOREIGN KEY (user_id, course_code, faculty, slot)
          REFERENCES $userCoursesTableName(user_id, course_code, faculty, slot)
          ON DELETE CASCADE
      )
    ''');

    // Marks Table with Composite Primary Key to Avoid Ambiguity
    await db.execute('''
      CREATE TABLE $marksTable (
        user_id INTEGER NOT NULL,
        course_code TEXT NOT NULL,
        faculty TEXT NOT NULL,
        slot TEXT NOT NULL,
        test_type TEXT NOT NULL,
        max_marks INTEGER NOT NULL,
        obtained_marks REAL NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, course_code, faculty, slot, test_type),
        FOREIGN KEY (user_id, course_code, faculty, slot)
          REFERENCES $userCoursesTableName(user_id, course_code, faculty, slot)
          ON DELETE CASCADE
      )
    ''');
  }

  // Insert a user into the users table.
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      userTableName,
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert a record into the global courses table (if needed).
  Future<int> insertCourse(Map<String, dynamic> course) async {
    final db = await database;
    return await db.insert(
      courseTableName,
      course,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert a user-specific course enrollment (with faculty, slot, etc.).
  Future<int> insertUserCourse(Map<String, dynamic> userCourse) async {
    final db = await database;
    return await db.insert(
      userCoursesTableName,
      userCourse,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert Attendance record using the composite key (user_id, course_code, faculty, slot).
  Future<int> insertAttendance(Map<String, dynamic> attendance) async {
    final db = await database;
    return await db.insert(
      attendanceTableName,
      attendance,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert Marks record using the composite key (user_id, course_code, faculty, slot, test_type).
  Future<int> insertMarks(Map<String, dynamic> marks) async {
    final db = await database;
    return await db.insert(
      marksTable,
      marks,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all users from the users table.
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query(userTableName);
  }

  // Fetch attendance records for a specific user.
  // This will return all attendance rows for the given user_id, regardless of course/faculty/slot.
  Future<List<Map<String, dynamic>>> getAttendance(int userId) async {
    final db = await database;
    return await db.query(
      attendanceTableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Fetch marks records for a specific user.
  // This will return all marks rows for the given user_id.
  Future<List<Map<String, dynamic>>> getMarks(int userId) async {
    final db = await database;
    return await db.query(
      marksTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
