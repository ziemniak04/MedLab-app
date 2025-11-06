import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../services/database_helper.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final reminders = await DatabaseHelper.instance.getPendingReminders();
    setState(() {
      _reminders = reminders;
      _isLoading = false;
    });
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String testType = 'General';
    DateTime scheduledDate = DateTime.now();
    TimeOfDay? scheduledTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: testType,
                  decoration: const InputDecoration(
                    labelText: 'Test Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'General',
                    'Blood Count',
                    'Cholesterol',
                    'Thyroid',
                    'Blood Sugar',
                    'Liver Function',
                    'Kidney Function',
                  ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (value) {
                    setState(() => testType = value!);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('MMM d, y').format(scheduledDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: scheduledDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => scheduledDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Time (optional)'),
                  subtitle: Text(scheduledTime != null 
                      ? scheduledTime!.format(context) 
                      : 'Not set'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: scheduledTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => scheduledTime = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;
                
                final reminder = Reminder(
                  title: titleController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  testType: testType,
                  scheduledDate: scheduledDate,
                  scheduledTime: scheduledTime != null 
                      ? '${scheduledTime!.hour.toString().padLeft(2, '0')}:${scheduledTime!.minute.toString().padLeft(2, '0')}'
                      : null,
                );
                await DatabaseHelper.instance.insertReminder(reminder);
                if (context.mounted) Navigator.pop(context);
                _loadReminders();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    if (reminder.id == null) return;
    await DatabaseHelper.instance.deleteReminder(reminder.id!);
    _loadReminders();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder deleted')),
      );
    }
  }

  Future<void> _markCompleted(Reminder reminder) async {
    if (reminder.id == null) return;
    await DatabaseHelper.instance.markReminderCompleted(reminder.id!);
    _loadReminders();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder completed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.orange.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reminders set',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set reminders for upcoming tests',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _reminders[index];
                    final isPast = reminder.isPast();
                    final isToday = reminder.isToday();
                    
                    return Dismissible(
                      key: Key(reminder.id.toString()),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          _markCompleted(reminder);
                          return false;
                        } else {
                          return true;
                        }
                      },
                      onDismissed: (direction) {
                        _deleteReminder(reminder);
                      },
                      child: Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isToday
                                ? Colors.orange.shade300
                                : isPast
                                    ? Colors.red.shade200
                                    : Colors.grey.shade200,
                            width: isToday || isPast ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Colors.orange.shade50
                                  : isPast
                                      ? Colors.red.shade50
                                      : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.notifications_active,
                              color: isToday
                                  ? Colors.orange.shade700
                                  : isPast
                                      ? Colors.red.shade700
                                      : Colors.blue.shade700,
                            ),
                          ),
                          title: Text(
                            reminder.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(reminder.testType),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, 
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('MMM d, y').format(reminder.scheduledDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (reminder.scheduledTime != null) ...[
                                    const SizedBox(width: 12),
                                    Icon(Icons.access_time, 
                                        size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      reminder.scheduledTime!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (isToday)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Today!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              if (isPast)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Overdue',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            color: Colors.green.shade700,
                            onPressed: () => _markCompleted(reminder),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
