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
          'model': 'claude-haiku-4-5-20251001',
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

  /// AI Doctor - Get friendly medical advice based on test results
  static Future<String> getUncleGoodDoctorAdvice(List<Map<String, dynamic>> testResults) async {
    if (testResults.isEmpty) {
      return 'Hello! 👨‍⚕️\n\nI don\'t see any test results yet. '
          'Add your results, and I\'ll help you understand them and give you some friendly advice!\n\n'
          'Remember: always consult your results with your doctor!';
    }

    // Prepare test results summary for Claude
    final resultsText = testResults.map((result) {
      return '- ${result['testName']}: ${result['value']} ${result['unit']} (Category: ${result['testType']})';
    }).join('\n');

    final prompt = '''You are "AI Doctor" (Uncle Good Doctor) - a friendly, warm, and caring doctor who explains medical test results in a simple, conversational way.
Here are the patient's recent test results:
$resultsText

Reference ranges:
- Hemoglobin: 12.0-16.0 g/dL
- White Blood Cells: 4.0-11.0 K/µL
- Platelets: 150.0-400.0 K/µL
- Total Cholesterol: <200 mg/dL (optimal)
- LDL: <100 mg/dL (optimal)
- HDL: >40 mg/dL (optimal)
- Triglycerides: <150 mg/dL
- TSH: 0.4-4.0 mIU/L
- T3: 80.0-200.0 ng/dL
- T4: 5.0-12.0 µg/dL
- Glucose (Fasting): 70.0-100.0 mg/dL
- HbA1c: <5.7%
- ALT: <40 U/L
- AST: <40 U/L
- Bilirubin: <1.2 mg/dL
- Creatinine: 0.6-1.2 mg/dL
- BUN: 7.0-20.0 mg/dL

Please provide advice in English following these guidelines:
1. Start with a warm greeting like "Hey, how are you doing?" (one line)
2. Brief comment on results (one short paragraph)
3. Section titled "**What's great:**" listing good values with - bullet points
4. Section titled "**But listen - [test name] has increased:**" (if any high values) with explanation
5. Section titled "**What you can do:**" with numbered practical tips (1. 2. 3. etc)
6. End with: "Remember: if the results are concerning, contact your doctor!"

Format requirements:
- Use ** for bold section headers
- Use numbered lists (1. 2. 3.) for action items
- Use - bullet points for simple lists
- Keep paragraphs short (2-3 sentences max)
- Use emojis ONLY in the greeting (1 emoji max, like 😊)
- Keep total response under 250 words
- Be conversational like a caring uncle, not a formal doctor

Be warm, supportive, and honest. Don't be alarming but highlight what needs attention.''';


    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-haiku-4-5-20251001',
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final textContent = data['content'][0]['text'] as String;
        return textContent.trim();
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      return 'Sorry, there was a connection problem. 😔\n\n'
          'I can\'t analyze your results right now, but remember: '
          'if you have any concerns about your results, '
          'contact your doctor!';
    }
  }
}
