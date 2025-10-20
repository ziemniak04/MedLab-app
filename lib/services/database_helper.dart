import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/test_result.dart';

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
      version: 1,
      onCreate: _createDB,
    );
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

  Future close() async {
    final db = await database;
    await db.close();
  }
}
