class TestResult {
  final int? id;
  final String testType;
  final String testName;
  final double value;
  final String unit;
  final DateTime date;
  final String? notes;

  TestResult({
    this.id,
    required this.testType,
    required this.testName,
    required this.value,
    required this.unit,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testType': testType,
      'testName': testName,
      'value': value,
      'unit': unit,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      id: map['id'],
      testType: map['testType'],
      testName: map['testName'],
      value: map['value'],
      unit: map['unit'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
    );
  }

  TestResult copyWith({
    int? id,
    String? testType,
    String? testName,
    double? value,
    String? unit,
    DateTime? date,
    String? notes,
  }) {
    return TestResult(
      id: id ?? this.id,
      testType: testType ?? this.testType,
      testName: testName ?? this.testName,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
