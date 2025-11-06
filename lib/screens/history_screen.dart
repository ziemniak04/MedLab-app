import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/test_result.dart';
import '../services/database_helper.dart';
import '../services/export_service.dart';
import '../services/user_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TestResult> _allResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    final results = await DatabaseHelper.instance.getAllTestResults();
    setState(() {
      _allResults = results;
      _isLoading = false;
    });
  }

  Future<void> _deleteResult(TestResult result) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Result'),
        content: Text('Are you sure you want to delete this ${result.testName} result?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && result.id != null) {
      await DatabaseHelper.instance.deleteTestResult(result.id!);
      _loadResults();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result deleted')),
        );
      }
    }
  }

  Future<void> _exportToPDF() async {
    if (_allResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No results to export')),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      final userName = UserPreferences.instance.getUserName() ?? 'User';
      final pdfFile = await ExportService.generatePDF(_allResults, userName);

      if (mounted) Navigator.pop(context); // Close loading

      // Show success and share
      if (mounted) {
        final share = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('PDF Generated'),
            content: const Text('Your health report has been generated. Would you like to share it?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );

        if (share == true) {
          await ExportService.sharePDF(pdfFile);
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'All Results',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
        actions: [
          if (_allResults.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Export to PDF',
              onPressed: _exportToPDF,
            ),
        ],
      ),
      floatingActionButton: _allResults.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _exportToPDF,
              backgroundColor: Colors.blue.shade700,
              icon: const Icon(Icons.file_download),
              label: const Text('Export PDF'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No test results yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadResults,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _allResults.length,
                    itemBuilder: (context, index) {
                      final result = _allResults[index];
                      return _ResultCard(
                        result: result,
                        onDelete: () => _deleteResult(result),
                      );
                    },
                  ),
                ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final TestResult result;
  final VoidCallback onDelete;

  const _ResultCard({
    required this.result,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => _ResultDetails(result: result),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.science_outlined,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.testName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.testType,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(result.date),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${result.value}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    result.unit,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultDetails extends StatelessWidget {
  final TestResult result;

  const _ResultDetails({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.science_outlined,
                  color: Colors.blue.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.testName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.testType,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DetailRow(
            icon: Icons.analytics_outlined,
            label: 'Value',
            value: '${result.value} ${result.unit}',
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value: DateFormat('MMMM dd, yyyy').format(result.date),
          ),
          if (result.notes != null && result.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.note_outlined,
              label: 'Notes',
              value: result.notes!,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
