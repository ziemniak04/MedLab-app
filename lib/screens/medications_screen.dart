import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../services/database_helper.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List<Medication> _medications = [];
  bool _isLoading = true;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);
    final meds = _showAll
        ? await DatabaseHelper.instance.getAllMedications()
        : await DatabaseHelper.instance.getActiveMedications();
    setState(() {
      _medications = meds;
      _isLoading = false;
    });
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    String frequency = 'Once daily';
    DateTime startDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Medication'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (e.g., 10mg, 2 pills)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: frequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Once daily',
                    'Twice daily',
                    'Three times daily',
                    'As needed',
                    'Every other day',
                    'Weekly',
                  ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (value) {
                    setState(() => frequency = value!);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(DateFormat('MMM d, y').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => startDate = picked);
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
                if (nameController.text.isEmpty || dosageController.text.isEmpty) {
                  return;
                }
                final medication = Medication(
                  name: nameController.text,
                  dosage: dosageController.text,
                  frequency: frequency,
                  startDate: startDate,
                );
                await DatabaseHelper.instance.insertMedication(medication);
                if (context.mounted) Navigator.pop(context);
                _loadMedications();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMedication(Medication med) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Remove ${med.name} from your medications?'),
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

    if (confirm == true && med.id != null) {
      await DatabaseHelper.instance.deleteMedication(med.id!);
      _loadMedications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Medications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() => _showAll = !_showAll);
              _loadMedications();
            },
            icon: Icon(_showAll ? Icons.filter_list_off : Icons.filter_list),
            label: Text(_showAll ? 'Active' : 'All'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.purple.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Add Medication'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No medications tracked',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your medications to track them',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final med = _medications[index];
                    final isActive = med.isActive();
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isActive
                              ? Colors.purple.shade200
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.purple.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.medication,
                            color: isActive
                                ? Colors.purple.shade700
                                : Colors.grey.shade400,
                          ),
                        ),
                        title: Text(
                          med.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isActive ? null : Colors.grey.shade600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${med.dosage} • ${med.frequency}'),
                            const SizedBox(height: 2),
                            Text(
                              'Since ${DateFormat('MMM d, y').format(med.startDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (!isActive && med.endDate != null)
                              Text(
                                'Ended ${DateFormat('MMM d, y').format(med.endDate!)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red.shade400,
                          onPressed: () => _deleteMedication(med),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
