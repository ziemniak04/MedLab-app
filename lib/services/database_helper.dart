import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/test_result.dart';
import '../models/medication.dart';
import '../models/reminder.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medlab.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Initialize sqflite_ffi for desktop platforms
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Updated version
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add medications table
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS medications (
          id $idType,
          name $textType,
          dosage $textType,
          frequency $textType,
          startDate $textType,
          endDate TEXT,
          notes TEXT
        )
      ''');

      // Add reminders table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reminders (
          id $idType,
          title $textType,
          description TEXT,
          testType $textType,
          scheduledDate $textType,
          scheduledTime TEXT,
          isRecurring INTEGER DEFAULT 0,
          recurrencePattern TEXT,
          isCompleted INTEGER DEFAULT 0,
          completedDate TEXT
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE test_results (
        id $idType,
        testType $textType,
        testName $textType,
        value $realType,
        unit $textType,
        date $textType,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE medications (
        id $idType,
        name $textType,
        dosage $textType,
        frequency $textType,
        startDate $textType,
        endDate TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id $idType,
        title $textType,
        description TEXT,
        testType $textType,
        scheduledDate $textType,
        scheduledTime TEXT,
        isRecurring INTEGER DEFAULT 0,
        recurrencePattern TEXT,
        isCompleted INTEGER DEFAULT 0,
        completedDate TEXT
      )
    ''');
  }

  Future<int> insertTestResult(TestResult result) async {
    final db = await database;
    return await db.insert('test_results', result.toMap());
  }

  Future<List<TestResult>> getAllTestResults() async {
    final db = await database;
    final result = await db.query(
      'test_results',
      orderBy: 'date DESC',
    );
    return result.map((map) => TestResult.fromMap(map)).toList();
  }

  Future<List<TestResult>> getTestResultsByType(String testType) async {
    final db = await database;
    final result = await db.query(
      'test_results',
      where: 'testType = ?',
      whereArgs: [testType],
      orderBy: 'date DESC',
    );
    return result.map((map) => TestResult.fromMap(map)).toList();
  }

  Future<List<TestResult>> getTestResultsByName(String testName) async {
    final db = await database;
    final result = await db.query(
      'test_results',
      where: 'testName = ?',
      whereArgs: [testName],
      orderBy: 'date ASC',
    );
    return result.map((map) => TestResult.fromMap(map)).toList();
  }

  Future<TestResult?> getPreviousTestResult(String testName, DateTime currentDate) async {
    final db = await database;
    final result = await db.query(
      'test_results',
      where: 'testName = ? AND date < ?',
      whereArgs: [testName, currentDate.toIso8601String()],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return TestResult.fromMap(result.first);
  }

  Future<int> updateTestResult(TestResult result) async {
    final db = await database;
    return await db.update(
      'test_results',
      result.toMap(),
      where: 'id = ?',
      whereArgs: [result.id],
    );
  }

  Future<int> deleteTestResult(int id) async {
    final db = await database;
    return await db.delete(
      'test_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertMockData() async {
    final now = DateTime.now();
    
    // Mock data for cholesterol over 6 months
    final mockResults = [
      TestResult(
        testType: 'Cholesterol',
        testName: 'Total Cholesterol',
        value: 210.0,
        unit: 'mg/dL',
        date: now.subtract(const Duration(days: 180)),
      ),
      TestResult(
        testType: 'Cholesterol',
        testName: 'Total Cholesterol',
        value: 205.0,
        unit: 'mg/dL',
        date: now.subtract(const Duration(days: 150)),
      ),
      TestResult(
        testType: 'Cholesterol',
        testName: 'Total Cholesterol',
        value: 198.0,
        unit: 'mg/dL',
        date: now.subtract(const Duration(days: 120)),
      ),
      TestResult(
        testType: 'Cholesterol',
        testName: 'Total Cholesterol',
        value: 192.0,
        unit: 'mg/dL',
        date: now.subtract(const Duration(days: 90)),
      ),
      TestResult(
        testType: 'Cholesterol',
        testName: 'Total Cholesterol',
        value: 188.0,
        unit: 'mg/dL',
        date: now.subtract(const Duration(days: 60)),
      ),
      TestResult(
        testType: 'Cholesterol',
        testName: 'Total Cholesterol',
        value: 185.0,
        unit: 'mg/dL',
        date: now.subtract(const Duration(days: 30)),
      ),
      // Blood sugar
      TestResult(
        testType: 'Blood Sugar',
        testName: 'Glucose (Fasting)',
        value: 95.0,
        unit: 'mg/dL',
        date: now.subtract(const Duration(days: 90)),
      ),
      TestResult(
        testType: 'Blood Sugar',
        testName: 'Glucose (Fasting)',
        value: 92.0,
        unit: 'mg/dL',
        date: now.subtract(const Duration(days: 60)),
      ),
      TestResult(
        testType: 'Blood Sugar',
        testName: 'Glucose (Fasting)',
        value: 88.0,
        unit: 'mg/dL',
        date: now.subtract(const Duration(days: 30)),
      ),
      // Thyroid
      TestResult(
        testType: 'Thyroid',
        testName: 'TSH',
        value: 2.5,
        unit: 'mIU/L',
        date: now.subtract(const Duration(days: 90)),
      ),
      TestResult(
        testType: 'Thyroid',
        testName: 'TSH',
        value: 2.3,
        unit: 'mIU/L',
        date: now.subtract(const Duration(days: 30)),
      ),
    ];

    for (var result in mockResults) {
      await insertTestResult(result);
    }
  }

  // Medication CRUD operations
  Future<int> insertMedication(Medication medication) async {
    final db = await database;
    return await db.insert('medications', medication.toMap());
  }

  Future<List<Medication>> getAllMedications() async {
    final db = await database;
    final result = await db.query(
      'medications',
      orderBy: 'startDate DESC',
    );
    return result.map((map) => Medication.fromMap(map)).toList();
  }

  Future<List<Medication>> getActiveMedications() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final result = await db.query(
      'medications',
      where: 'endDate IS NULL OR endDate >= ?',
      whereArgs: [now],
      orderBy: 'startDate DESC',
    );
    return result.map((map) => Medication.fromMap(map)).toList();
  }

  Future<int> updateMedication(Medication medication) async {
    final db = await database;
    return await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  Future<int> deleteMedication(int id) async {
    final db = await database;
    return await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reminder CRUD operations
  Future<int> insertReminder(Reminder reminder) async {
    final db = await database;
    return await db.insert('reminders', reminder.toMap());
  }

  Future<List<Reminder>> getAllReminders() async {
    final db = await database;
    final result = await db.query(
      'reminders',
      orderBy: 'scheduledDate ASC',
    );
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getPendingReminders() async {
    final db = await database;
    final result = await db.query(
      'reminders',
      where: 'isCompleted = 0',
      orderBy: 'scheduledDate ASC',
    );
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getTodayReminders() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    
    final result = await db.query(
      'reminders',
      where: 'scheduledDate >= ? AND scheduledDate <= ? AND isCompleted = 0',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'scheduledTime ASC',
    );
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<int> updateReminder(Reminder reminder) async {
    final db = await database;
    return await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markReminderCompleted(int id) async {
    final db = await database;
    return await db.update(
      'reminders',
      {
        'isCompleted': 1,
        'completedDate': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    await db.close();
  }
}
