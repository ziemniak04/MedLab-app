import 'package:flutter/material.dart';
import '../services/user_preferences.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      await UserPreferences.instance.setUserName(name);
      await UserPreferences.instance.setFirstLaunch(false);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medical_information_outlined,
                    size: 64,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  'Welcome to MedLab',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Track your medical test results and monitor your health trends over time',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Name input
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    labelStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.shade700,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Continue button
                ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Info text
                Text(
                  'Your data is stored locally on your device',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
