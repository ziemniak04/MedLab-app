import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/test_category.dart';
import '../models/test_result.dart';
import '../services/database_helper.dart';

class AddResultScreen extends StatefulWidget {
  const AddResultScreen({super.key});

  @override
  State<AddResultScreen> createState() => _AddResultScreenState();
}

class _AddResultScreenState extends State<AddResultScreen> {
  int _currentStep = 0;
  TestCategory? _selectedCategory;
  TestTemplate? _selectedTest;
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAIComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon! 🚀'),
        content: const Text(
          'AI-assisted data entry is currently under development.\n\n'
          'Soon you\'ll be able to:\n'
          '• Take a photo of your test results\n'
          '• Let AI automatically extract the data\n'
          '• Review and confirm the entries\n\n'
          'For now, please use the manual entry option.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveResult() async {
    if (_selectedCategory == null ||
        _selectedTest == null ||
        _valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    final value = double.tryParse(_valueController.text);
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
      return;
    }

    final result = TestResult(
      testType: _selectedCategory!.name,
      testName: _selectedTest!.name,
      value: value,
      unit: _selectedTest!.unit,
      date: _selectedDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    await DatabaseHelper.instance.insertTestResult(result);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test result saved successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Test Result',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Method selection buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _MethodButton(
                    icon: Icons.edit_outlined,
                    title: 'Manual Entry',
                    isSelected: true,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MethodButton(
                    icon: Icons.camera_alt_outlined,
                    title: 'AI Assist',
                    isSelected: false,
                    badge: 'Soon',
                    onTap: _showAIComingSoon,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Manual entry form
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  if (_currentStep == 0 && _selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select a test category')),
                    );
                    return;
                  }
                  if (_currentStep == 1 && _selectedTest == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a test')),
                    );
                    return;
                  }
                  setState(() => _currentStep++);
                } else {
                  _saveResult();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text(_currentStep == 3 ? 'Save' : 'Continue'),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Select Category'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                  content: _CategorySelection(
                    selected: _selectedCategory,
                    onSelect: (category) {
                      setState(() {
                        _selectedCategory = category;
                        _selectedTest = null;
                      });
                    },
                  ),
                ),
                Step(
                  title: const Text('Select Test'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                  content: _selectedCategory == null
                      ? const Text('Please select a category first')
                      : _TestSelection(
                          category: _selectedCategory!,
                          selected: _selectedTest,
                          onSelect: (test) {
                            setState(() => _selectedTest = test);
                          },
                        ),
                ),
                Step(
                  title: const Text('Enter Value'),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.indexed,
                  content: _selectedTest == null
                      ? const Text('Please select a test first')
                      : _ValueInput(
                          test: _selectedTest!,
                          controller: _valueController,
                          date: _selectedDate,
                          onDateChanged: (date) {
                            setState(() => _selectedDate = date);
                          },
                        ),
                ),
                Step(
                  title: const Text('Add Notes (Optional)'),
                  isActive: _currentStep >= 3,
                  state: StepState.indexed,
                  content: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add any notes about this test...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _MethodButton({
    required this.icon,
    required this.title,
    required this.isSelected,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isSelected
                        ? Colors.blue.shade700
                        : Colors.grey.shade600,
                  ),
                  if (badge != null)
                    Positioned(
                      right: -20,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.blue.shade700
                      : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySelection extends StatelessWidget {
  final TestCategory? selected;
  final Function(TestCategory) onSelect;

  const _CategorySelection({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: TestCategories.all.map((category) {
        final isSelected = selected?.name == category.name;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => onSelect(category),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    category.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.grey.shade900,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.blue.shade700,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TestSelection extends StatelessWidget {
  final TestCategory category;
  final TestTemplate? selected;
  final Function(TestTemplate) onSelect;

  const _TestSelection({
    required this.category,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: category.tests.map((test) {
        final isSelected = selected?.name == test.name;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => onSelect(test),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.blue.shade700
                                : Colors.grey.shade900,
                          ),
                        ),
                        if (test.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            test.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Unit: ${test.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (test.normalMin != null || test.normalMax != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Normal range: ${test.normalMin ?? ''} - ${test.normalMax ?? ''} ${test.unit}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.blue.shade700,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ValueInput extends StatelessWidget {
  final TestTemplate test;
  final TextEditingController controller;
  final DateTime date;
  final Function(DateTime) onDateChanged;

  const _ValueInput({
    required this.test,
    required this.controller,
    required this.date,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          test.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (test.normalMin != null || test.normalMax != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Normal range: ${test.normalMin ?? ''} - ${test.normalMax ?? ''} ${test.unit}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            labelText: 'Value',
            suffixText: test.unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          leading: const Icon(Icons.calendar_today),
          title: const Text('Test Date'),
          subtitle: Text(
            '${date.day}/${date.month}/${date.year}',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
        ),
      ],
    );
  }
}
