class Medication {
  final int? id;
  final String name;
  final String dosage;
  final String frequency; // e.g., "Once daily", "Twice daily", "As needed"
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      frequency: map['frequency'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      notes: map['notes'],
    );
  }

  Medication copyWith({
    int? id,
    String? name,
    String? dosage,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
    );
  }

  bool isActive() {
    final now = DateTime.now();
    if (endDate == null) return true;
    return now.isBefore(endDate!) || now.isAtSameMomentAs(endDate!);
  }
}
