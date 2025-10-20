import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/test_result.dart';
import '../services/database_helper.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  Map<String, List<TestResult>> _groupedResults = {};
  String? _selectedTestName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    final results = await DatabaseHelper.instance.getAllTestResults();

    // Group results by test name
    final grouped = <String, List<TestResult>>{};
    for (var result in results) {
      final key = result.testName;
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(result);
    }

    // Sort each group by date
    grouped.forEach((key, value) {
      value.sort((a, b) => a.date.compareTo(b.date));
    });

    // Filter to only tests with multiple results
    final filteredGrouped = Map.fromEntries(
      grouped.entries.where((entry) => entry.value.length >= 2),
    );

    setState(() {
      _groupedResults = filteredGrouped;
      if (filteredGrouped.isNotEmpty && _selectedTestName == null) {
        _selectedTestName = filteredGrouped.keys.first;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Charts & Trends',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupedResults.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No trends available yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add at least 2 results for the same test to see trends',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Test selector
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Select Test',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _groupedResults.keys.map((testName) {
                                final isSelected = testName == _selectedTestName;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(testName),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _selectedTestName = testName);
                                      }
                                    },
                                    selectedColor: Colors.blue.shade700,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chart
                    Expanded(
                      child: _selectedTestName == null
                          ? const SizedBox()
                          : _TestChart(
                              results: _groupedResults[_selectedTestName]!,
                              testName: _selectedTestName!,
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _TestChart extends StatelessWidget {
  final List<TestResult> results;
  final String testName;

  const _TestChart({
    required this.results,
    required this.testName,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox();

    final firstResult = results.first;
    final unit = firstResult.unit;

    // Calculate stats
    final values = results.map((r) => r.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final avgValue = values.reduce((a, b) => a + b) / values.length;

    // Prepare chart data
    final spots = results.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Latest',
                  value: '${results.last.value}',
                  unit: unit,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Average',
                  value: avgValue.toStringAsFixed(1),
                  unit: unit,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Lowest',
                  value: '$minValue',
                  unit: unit,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Highest',
                  value: '$maxValue',
                  unit: unit,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Trend Over Time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: (maxValue - minValue) / 4,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < results.length) {
                                  final date = results[value.toInt()].date;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      DateFormat('MMM dd').format(date),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(0),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        minX: 0,
                        maxX: (results.length - 1).toDouble(),
                        minY: minValue * 0.9,
                        maxY: maxValue * 1.1,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: Colors.blue.shade700,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.blue.shade700,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.shade700.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Data points list
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'All Measurements',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...results.reversed.map((result) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(result.date),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '${result.value} ${result.unit}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
