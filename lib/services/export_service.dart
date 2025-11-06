import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/test_result.dart';

class ExportService {
  static Future<File> generatePDF(List<TestResult> results, String userName) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM d, y');
    final timeFormat = DateFormat('h:mm a');

    // Group results by test type
    final groupedResults = <String, List<TestResult>>{};
    for (var result in results) {
      if (!groupedResults.containsKey(result.testType)) {
        groupedResults[result.testType] = [];
      }
      groupedResults[result.testType]!.add(result);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.blue700, width: 2),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MedLab Health Report',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Patient: $userName',
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                ),
                pw.Text(
                  'Generated: ${dateFormat.format(now)} at ${timeFormat.format(now)}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Total Tests', results.length.toString()),
                _buildStat('Categories', groupedResults.length.toString()),
                _buildStat(
                  'Date Range',
                  results.isEmpty
                      ? 'N/A'
                      : '${DateFormat('MMM d').format(results.last.date)} - ${DateFormat('MMM d, y').format(results.first.date)}',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Results by category
          ...groupedResults.entries.map((entry) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  entry.key,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1.5),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _buildTableHeader('Test Name'),
                        _buildTableHeader('Value'),
                        _buildTableHeader('Unit'),
                        _buildTableHeader('Date'),
                      ],
                    ),
                    // Data rows
                    ...entry.value.map((result) {
                      return pw.TableRow(
                        children: [
                          _buildTableCell(result.testName),
                          _buildTableCell(result.value.toString()),
                          _buildTableCell(result.unit),
                          _buildTableCell(DateFormat('MMM d, y').format(result.date)),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 24),
              ],
            );
          }),

          // Footer
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Text(
            'This report is for informational purposes only. Please consult with your healthcare provider for medical advice.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/medlab_report_${now.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  static Future<void> sharePDF(File pdfFile) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      subject: 'MedLab Health Report',
      text: 'Here is my health report from MedLab',
    );
  }
}
