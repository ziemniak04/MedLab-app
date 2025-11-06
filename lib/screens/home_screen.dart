import 'package:flutter/material.dart';
import '../services/user_preferences.dart';
import '../services/database_helper.dart';
import '../services/ai_service.dart';
import '../models/test_result.dart';
import 'add_result_screen.dart';
import 'history_screen.dart';
import 'chart_screen.dart';
import 'profile_screen.dart';
import 'medications_screen.dart';
import 'reminders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  List<TestResult> _recentResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final userName = UserPreferences.instance.getUserName() ?? 'User';
    final results = await DatabaseHelper.instance.getAllTestResults();

    // Add mock data if this is the first time
    if (results.isEmpty && !UserPreferences.instance.isMockDataAdded()) {
      await DatabaseHelper.instance.insertMockData();
      await UserPreferences.instance.setMockDataAdded(true);
      final updatedResults = await DatabaseHelper.instance.getAllTestResults();
      setState(() {
        _userName = userName;
        _recentResults = updatedResults.take(5).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _userName = userName;
        _recentResults = results.take(5).toList();
        _isLoading = false;
      });
    }
  }

  void _showDoctorAdvice() async {
    // Show loading dialog
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
                Text('AI Doctor analizuje...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Get all test results
      final allResults = await DatabaseHelper.instance.getAllTestResults();
      
      // Convert to format expected by AI service
      final testData = allResults.map((result) => {
        'testType': result.testType,
        'testName': result.testName,
        'value': result.value,
        'unit': result.unit,
      }).toList();

      // Get advice from Uncle Good Doctor
      final advice = await AIService.getUncleGoodDoctorAdvice(testData);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show advice dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '👨‍⚕️',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'AI Doctor',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _DoctorAdviceText(advice: advice),
                    ),
                  ),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Dziękuję!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Błąd'),
            content: Text('Nie udało się uzyskać porady: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
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
          'MedLab',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showDoctorAdvice,
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.medical_services),
        label: const Text('AI Doctor'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Parallax Welcome Header
                  SliverAppBar(
                    expandedHeight: 180,
                    floating: false,
                    pinned: false,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade500,
                              Colors.blue.shade300,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Animated background circles
                            Positioned(
                              top: -50,
                              right: -50,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -30,
                              left: -30,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Hello, $_userName! 👋',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Track your health journey',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        // Quick Actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Actions',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade900,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _QuickActionCard(
                                      icon: Icons.add_circle_outline,
                                      title: 'Add Result',
                                      color: Colors.blue.shade700,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AddResultScreen(),
                                          ),
                                        );
                                        _loadData();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _QuickActionCard(
                                      icon: Icons.show_chart,
                                      title: 'View Charts',
                                      color: Colors.green.shade700,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ChartScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _QuickActionCard(
                                      icon: Icons.medication,
                                      title: 'Medications',
                                      color: Colors.purple.shade700,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const MedicationsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _QuickActionCard(
                                      icon: Icons.notifications_outlined,
                                      title: 'Reminders',
                                      color: Colors.orange.shade700,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const RemindersScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Recent Results
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Results',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade900,
                                    ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HistoryScreen(),
                                    ),
                                  );
                                },
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _recentResults.isEmpty
                            ? _EmptyState()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _recentResults.length,
                                itemBuilder: (context, index) {
                                  final result = _recentResults[index];
                                  return _ResultCard(result: result);
                                },
                              ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatefulWidget {
  final TestResult result;

  const _ResultCard({required this.result});

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  TestResult? _previousResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _loadPreviousResult();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPreviousResult() async {
    final previous = await DatabaseHelper.instance.getPreviousTestResult(
      widget.result.testName,
      widget.result.date,
    );
    setState(() {
      _previousResult = previous;
      _isLoading = false;
    });
  }

  Widget _buildTrendIndicator() {
    if (_isLoading || _previousResult == null) {
      return const SizedBox.shrink();
    }

    final currentValue = widget.result.value;
    final previousValue = _previousResult!.value;
    final difference = currentValue - previousValue;
    final percentageChange = (difference / previousValue * 100).abs();
    
    IconData icon;
    Color color;
    String trend;
    
    if (difference.abs() < 0.01) {
      // Stable
      icon = Icons.trending_flat;
      color = Colors.grey.shade600;
      trend = 'Stable';
    } else if (difference > 0) {
      // Increased
      icon = Icons.trending_up;
      color = Colors.orange.shade700;
      trend = '+${percentageChange.toStringAsFixed(1)}%';
    } else {
      // Decreased
      icon = Icons.trending_down;
      color = Colors.blue.shade700;
      trend = '-${percentageChange.toStringAsFixed(1)}%';
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.result.testName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _buildTrendIndicator(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.result.testType,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.result.value} ${widget.result.unit}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(widget.result.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (diff.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
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
          const SizedBox(height: 8),
          Text(
            'Add your first test result to start tracking your health',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DoctorAdviceText extends StatelessWidget {
  final String advice;

  const _DoctorAdviceText({required this.advice});

  @override
  Widget build(BuildContext context) {
    // Parse the advice text and format it nicely
    final lines = advice.split('\n');
    final List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Check if it's a numbered list item
      final numberedMatch = RegExp(r'^(\d+)\.\s*(.+)$').firstMatch(line);
      if (numberedMatch != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      numberedMatch.group(1)!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    numberedMatch.group(2)!,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Check if it's a bullet point
      final bulletMatch = RegExp(r'^[-•]\s*(.+)$').firstMatch(line);
      if (bulletMatch != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    bulletMatch.group(1)!,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Check if it's a bold/emphasis section (contains **)
      if (line.contains('**')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: _buildFormattedText(line),
          ),
        );
        continue;
      }

      // Regular text
      TextStyle textStyle = TextStyle(
        fontSize: 15,
        height: 1.6,
        color: Colors.grey.shade800,
      );

      // First line (greeting) - make it bigger and bolder
      if (i == 0) {
        textStyle = TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade900,
          height: 1.4,
        );
      }
      // Last line (doctor reminder) - make it italic and highlighted
      else if (i == lines.length - 1 && line.toLowerCase().contains('lekarz')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade900,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(line, style: textStyle),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildFormattedText(String text) {
    final spans = <TextSpan>[];
    final parts = text.split('**');
    
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      
      if (i % 2 == 1) {
        // Bold text
        spans.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        );
      } else {
        // Regular text
        spans.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(
              color: Colors.grey.shade800,
            ),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }
}
