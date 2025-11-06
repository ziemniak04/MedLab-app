class Reminder {
  final int? id;
  final String title;
  final String? description;
  final String testType; // "Blood Count", "Cholesterol", etc. or "General"
  final DateTime scheduledDate;
  final String? scheduledTime; // HH:mm format
  final bool isRecurring;
  final String? recurrencePattern; // "daily", "weekly", "monthly", "yearly"
  final bool isCompleted;
  final DateTime? completedDate;

  Reminder({
    this.id,
    required this.title,
    this.description,
    required this.testType,
    required this.scheduledDate,
    this.scheduledTime,
    this.isRecurring = false,
    this.recurrencePattern,
    this.isCompleted = false,
    this.completedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'testType': testType,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': scheduledTime,
      'isRecurring': isRecurring ? 1 : 0,
      'recurrencePattern': recurrencePattern,
      'isCompleted': isCompleted ? 1 : 0,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      testType: map['testType'],
      scheduledDate: DateTime.parse(map['scheduledDate']),
      scheduledTime: map['scheduledTime'],
      isRecurring: map['isRecurring'] == 1,
      recurrencePattern: map['recurrencePattern'],
      isCompleted: map['isCompleted'] == 1,
      completedDate: map['completedDate'] != null 
          ? DateTime.parse(map['completedDate']) 
          : null,
    );
  }

  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    String? testType,
    DateTime? scheduledDate,
    String? scheduledTime,
    bool? isRecurring,
    String? recurrencePattern,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      testType: testType ?? this.testType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  bool isPast() {
    final now = DateTime.now();
    return scheduledDate.isBefore(now) && !isCompleted;
  }

  bool isToday() {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }
}
