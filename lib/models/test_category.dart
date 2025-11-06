class TestCategory {
  final String name;
  final String icon;
  final List<TestTemplate> tests;

  TestCategory({
    required this.name,
    required this.icon,
    required this.tests,
  });
}

class TestTemplate {
  final String name;
  final String unit;
  final double? normalMin;
  final double? normalMax;
  final String? description;

  TestTemplate({
    required this.name,
    required this.unit,
    this.normalMin,
    this.normalMax,
    this.description,
  });
}

// Predefined test categories and templates
class TestCategories {
  static final List<TestCategory> all = [
    TestCategory(
      name: 'Blood Count',
      icon: '🩸',
      tests: [
        TestTemplate(
          name: 'Hemoglobin',
          unit: 'g/dL',
          normalMin: 12.0,
          normalMax: 16.0,
          description: 'Red blood cell count',
        ),
        TestTemplate(
          name: 'White Blood Cells',
          unit: 'K/µL',
          normalMin: 4.0,
          normalMax: 11.0,
        ),
        TestTemplate(
          name: 'Lymphocytes',
          unit: 'K/µL',
          normalMin: 1.0,
          normalMax: 4.8,
          description: 'Type of white blood cell',
        ),
        TestTemplate(
          name: 'Platelets',
          unit: 'K/µL',
          normalMin: 150.0,
          normalMax: 400.0,
        ),
      ],
    ),
    TestCategory(
      name: 'Cholesterol',
      icon: '💊',
      tests: [
        TestTemplate(
          name: 'Total Cholesterol',
          unit: 'mg/dL',
          normalMax: 200.0,
        ),
        TestTemplate(
          name: 'LDL',
          unit: 'mg/dL',
          normalMax: 100.0,
          description: 'Low-density lipoprotein',
        ),
        TestTemplate(
          name: 'HDL',
          unit: 'mg/dL',
          normalMin: 40.0,
          description: 'High-density lipoprotein',
        ),
        TestTemplate(
          name: 'Triglycerides',
          unit: 'mg/dL',
          normalMax: 150.0,
        ),
      ],
    ),
    TestCategory(
      name: 'Thyroid',
      icon: '🦋',
      tests: [
        TestTemplate(
          name: 'TSH',
          unit: 'mIU/L',
          normalMin: 0.4,
          normalMax: 4.0,
          description: 'Thyroid Stimulating Hormone',
        ),
        TestTemplate(
          name: 'T3',
          unit: 'ng/dL',
          normalMin: 80.0,
          normalMax: 200.0,
        ),
        TestTemplate(
          name: 'T4',
          unit: 'µg/dL',
          normalMin: 5.0,
          normalMax: 12.0,
        ),
      ],
    ),
    TestCategory(
      name: 'Blood Sugar',
      icon: '🍬',
      tests: [
        TestTemplate(
          name: 'Glucose (Fasting)',
          unit: 'mg/dL',
          normalMin: 70.0,
          normalMax: 100.0,
        ),
        TestTemplate(
          name: 'HbA1c',
          unit: '%',
          normalMax: 5.7,
          description: 'Average blood sugar over 3 months',
        ),
      ],
    ),
    TestCategory(
      name: 'Liver Function',
      icon: '🫀',
      tests: [
        TestTemplate(
          name: 'ALT',
          unit: 'U/L',
          normalMax: 40.0,
        ),
        TestTemplate(
          name: 'AST',
          unit: 'U/L',
          normalMax: 40.0,
        ),
        TestTemplate(
          name: 'Bilirubin',
          unit: 'mg/dL',
          normalMax: 1.2,
        ),
      ],
    ),
    TestCategory(
      name: 'Kidney Function',
      icon: '💧',
      tests: [
        TestTemplate(
          name: 'Creatinine',
          unit: 'mg/dL',
          normalMin: 0.6,
          normalMax: 1.2,
        ),
        TestTemplate(
          name: 'BUN',
          unit: 'mg/dL',
          normalMin: 7.0,
          normalMax: 20.0,
          description: 'Blood Urea Nitrogen',
        ),
      ],
    ),
  ];
}
