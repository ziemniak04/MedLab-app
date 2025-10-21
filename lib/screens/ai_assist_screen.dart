import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/test_category.dart';
import '../models/test_result.dart';
import '../services/ai_service.dart';
import '../services/database_helper.dart';

class AIAssistScreen extends StatefulWidget {
  const AIAssistScreen({super.key});

  @override
  State<AIAssistScreen> createState() => _AIAssistScreenState();
}

class _AIAssistScreenState extends State<AIAssistScreen> {
  File? _imageFile;
  bool _isAnalyzing = false;
  List<ExtractedTestResult> _extractedResults = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'AI Assist',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_imageFile == null) {
      return _buildPhotoCapture();
    } else if (_isAnalyzing) {
      return _buildAnalyzing();
    } else if (_extractedResults.isEmpty) {
      return _buildNoResults();
    } else {
      return _buildReviewResults();
    }
  }

  Widget _buildPhotoCapture() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 60,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Scan Your Test Results',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Take a clear photo of your lab test results.\nAI will help extract the information automatically.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 24),
                label: const Text(
                  'Take Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 24),
                label: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade700, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'For best results, ensure the document is well-lit and text is clearly visible.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_imageFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _imageFile!,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 32),
            ],
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Analyzing Your Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'AI is extracting information from the image.\nThis may take a few moments...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t extract any test results from this image.\nPlease try again with a clearer photo.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                    _extractedResults = [];
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewResults() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.blue.shade700, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Results Extracted',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review and edit the results below',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _extractedResults.length,
            itemBuilder: (context, index) {
              return _ExtractedResultCard(
                result: _extractedResults[index],
                onEdit: (updated) {
                  setState(() {
                    _extractedResults[index] = updated;
                  });
                },
                onDelete: () {
                  setState(() {
                    _extractedResults.removeAt(index);
                  });
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _saveAllResults,
                  icon: const Icon(Icons.save, size: 24),
                  label: Text(
                    'Save ${_extractedResults.length} Result${_extractedResults.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                    _extractedResults = [];
                  });
                },
                child: const Text('Scan Another Document'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isAnalyzing = true;
        });
        await _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;

    try {
      final result = await AIService.analyzeTestResult(_imageFile!);
      final results = result['results'] as List<dynamic>;
      
      final extractedResults = <ExtractedTestResult>[];
      for (final item in results) {
        final category = AIService.matchTestCategory(item['testCategory'] ?? '');
        final testName = category != null 
            ? AIService.matchTestName(category, item['testName'] ?? '')
            : null;
        
        if (category != null && testName != null) {
          DateTime? date;
          if (item['date'] != null && item['date'] != 'null') {
            try {
              date = DateTime.parse(item['date']);
            } catch (_) {}
          }

          extractedResults.add(ExtractedTestResult(
            testCategory: category,
            testName: testName,
            value: (item['value'] as num?)?.toDouble(),
            unit: item['unit'] ?? '',
            date: date,
          ));
        }
      }

      setState(() {
        _extractedResults = extractedResults;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _saveAllResults() async {
    int saved = 0;
    for (final extracted in _extractedResults) {
      if (extracted.value != null) {
        final result = TestResult(
          testType: extracted.testCategory,
          testName: extracted.testName,
          value: extracted.value!,
          unit: extracted.unit,
          date: extracted.date ?? DateTime.now(),
          notes: 'Added via AI Assist',
        );
        await DatabaseHelper.instance.insertTestResult(result);
        saved++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$saved result${saved != 1 ? 's' : ''} saved successfully')),
      );
      Navigator.pop(context);
    }
  }
}

class ExtractedTestResult {
  final String testCategory;
  final String testName;
  double? value;
  final String unit;
  DateTime? date;

  ExtractedTestResult({
    required this.testCategory,
    required this.testName,
    this.value,
    required this.unit,
    this.date,
  });
}

class _ExtractedResultCard extends StatefulWidget {
  final ExtractedTestResult result;
  final Function(ExtractedTestResult) onEdit;
  final VoidCallback onDelete;

  const _ExtractedResultCard({
    required this.result,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ExtractedResultCard> createState() => _ExtractedResultCardState();
}

class _ExtractedResultCardState extends State<_ExtractedResultCard> {
  late TextEditingController _valueController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(
      text: widget.result.value?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  TestTemplate? _getTestTemplate() {
    for (final category in TestCategories.all) {
      if (category.name == widget.result.testCategory) {
        for (final test in category.tests) {
          if (test.name == widget.result.testName) {
            return test;
          }
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final template = _getTestTemplate();
    final isOutOfRange = template != null && widget.result.value != null
        ? (template.normalMin != null && widget.result.value! < template.normalMin!) ||
          (template.normalMax != null && widget.result.value! > template.normalMax!)
        : false;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOutOfRange ? Colors.orange.shade300 : Colors.grey.shade300,
          width: isOutOfRange ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.result.testName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.result.testCategory,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.check : Icons.edit_outlined,
                    color: Colors.blue.shade700,
                  ),
                  onPressed: () {
                    if (_isEditing) {
                      final newValue = double.tryParse(_valueController.text);
                      if (newValue != null) {
                        widget.result.value = newValue;
                        widget.onEdit(widget.result);
                      }
                    }
                    setState(() => _isEditing = !_isEditing);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isEditing) ...[
              TextField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Value',
                  suffixText: widget.result.unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Text(
                    widget.result.value?.toString() ?? 'N/A',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isOutOfRange
                          ? Colors.orange.shade700
                          : Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.result.unit,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
            if (template != null &&
                (template.normalMin != null || template.normalMax != null)) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOutOfRange
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOutOfRange ? Icons.warning_amber : Icons.check_circle,
                      size: 16,
                      color: isOutOfRange
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Normal: ${template.normalMin ?? ''} - ${template.normalMax ?? ''} ${template.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOutOfRange
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: widget.result.date ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  widget.result.date = picked;
                  widget.onEdit(widget.result);
                  setState(() {});
                }
              },
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                widget.result.date != null
                    ? '${widget.result.date!.day}/${widget.result.date!.month}/${widget.result.date!.year}'
                    : 'Set date',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
