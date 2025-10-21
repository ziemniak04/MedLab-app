import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static String get _apiKey {
    final key = dotenv.env['CLAUDE_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'CLAUDE_API_KEY not found in .env file. '
        'Please copy .env.example to .env and add your API key.',
      );
    }
    return key;
  }
  
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';

  static Future<Map<String, dynamic>> analyzeTestResult(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    final prompt = '''You are analyzing a medical test result document. Extract all available test results and their values.

Return ONLY a valid JSON object with the following structure:
{
  "results": [
    {
      "testCategory": "category name (Blood Count, Cholesterol, Thyroid, Blood Sugar, Liver Function, or Kidney Function)",
      "testName": "exact test name",
      "value": numeric_value,
      "unit": "unit of measurement",
      "date": "YYYY-MM-DD or null if not found"
    }
  ]
}

Available test categories and their tests:
- Blood Count: Hemoglobin (g/dL), White Blood Cells (K/µL), Platelets (K/µL)
- Cholesterol: Total Cholesterol (mg/dL), LDL (mg/dL), HDL (mg/dL), Triglycerides (mg/dL)
- Thyroid: TSH (mIU/L), T3 (ng/dL), T4 (µg/dL)
- Blood Sugar: Glucose (Fasting) (mg/dL), HbA1c (%)
- Liver Function: ALT (U/L), AST (U/L), Bilirubin (mg/dL)
- Kidney Function: Creatinine (mg/dL), BUN (mg/dL)

Match test names as closely as possible to the list above. Extract only the numeric value without text. If no date is visible, set it to null.''';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-5-haiku-20241022',
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
                {
                  'type': 'text',
                  'text': prompt,
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final textContent = data['content'][0]['text'] as String;
        
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(textContent);
        if (jsonMatch != null) {
          final extractedJson = jsonMatch.group(0)!;
          return jsonDecode(extractedJson) as Map<String, dynamic>;
        }
        
        return {'results': []};
      } else {
        throw Exception('API request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }

  static String? matchTestCategory(String categoryName) {
    final categories = {
      'blood count': 'Blood Count',
      'cholesterol': 'Cholesterol',
      'thyroid': 'Thyroid',
      'blood sugar': 'Blood Sugar',
      'liver function': 'Liver Function',
      'kidney function': 'Kidney Function',
    };
    
    final normalized = categoryName.toLowerCase().trim();
    return categories[normalized];
  }

  static String? matchTestName(String category, String testName) {
    final tests = {
      'Blood Count': {
        'hemoglobin': 'Hemoglobin',
        'hb': 'Hemoglobin',
        'hgb': 'Hemoglobin',
        'white blood cells': 'White Blood Cells',
        'wbc': 'White Blood Cells',
        'leukocytes': 'White Blood Cells',
        'platelets': 'Platelets',
        'plt': 'Platelets',
      },
      'Cholesterol': {
        'total cholesterol': 'Total Cholesterol',
        'cholesterol': 'Total Cholesterol',
        'ldl': 'LDL',
        'hdl': 'HDL',
        'triglycerides': 'Triglycerides',
      },
      'Thyroid': {
        'tsh': 'TSH',
        't3': 'T3',
        't4': 'T4',
      },
      'Blood Sugar': {
        'glucose': 'Glucose (Fasting)',
        'fasting glucose': 'Glucose (Fasting)',
        'hba1c': 'HbA1c',
        'a1c': 'HbA1c',
      },
      'Liver Function': {
        'alt': 'ALT',
        'ast': 'AST',
        'bilirubin': 'Bilirubin',
      },
      'Kidney Function': {
        'creatinine': 'Creatinine',
        'bun': 'BUN',
        'blood urea nitrogen': 'BUN',
      },
    };
    
    final categoryTests = tests[category];
    if (categoryTests == null) return null;
    
    final normalized = testName.toLowerCase().trim();
    return categoryTests[normalized];
  }
}
