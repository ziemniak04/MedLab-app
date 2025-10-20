# AI Integration Guide - Future Development

This document outlines how to implement the AI-assisted data entry feature when ready.

## Current State

The app has a placeholder button for "AI Assist" that shows a "Coming Soon" dialog. This is located in `lib/screens/add_result_screen.dart`.

## Architecture for AI Integration

### 1. Camera Integration

**Package**: `camera` or `image_picker`

```yaml
dependencies:
  camera: ^0.10.5+5  # For camera access
  image_picker: ^1.0.4  # Alternative simpler option
```

**Implementation Steps**:
1. Request camera permissions (Android/iOS)
2. Capture photo of test results
3. Preview image before processing
4. Allow retake if needed

### 2. OCR Processing

**Options**:

#### Option A: Cloud API (Recommended for MVP)
- **OpenAI GPT-4 Vision**: Best for understanding context
- **Claude 3**: Good vision capabilities
- **Google Cloud Vision**: Specialized in OCR

#### Option B: On-Device (Better for privacy)
- **ML Kit**: Google's free OCR
- **Tesseract**: Open source OCR engine

### 3. Suggested Implementation Flow

```
User taps "AI Assist"
    ↓
Open Camera
    ↓
Take Photo
    ↓
[Show Preview with "Process" button]
    ↓
Send to AI API
    ↓
[Show Loading Indicator]
    ↓
Receive Structured JSON
    ↓
Parse and Pre-fill Form
    ↓
Show Review Screen
    ↓
User Reviews/Corrects
    ↓
Save to Database
```

## API Integration Example

### OpenAI GPT-4 Vision

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> processTestImage(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);
  
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_API_KEY',
    },
    body: jsonEncode({
      'model': 'gpt-4-vision-preview',
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': '''Extract medical test results from this image. 
              Return ONLY a JSON object with this structure:
              {
                "tests": [
                  {
                    "testName": "string",
                    "value": number,
                    "unit": "string",
                    "date": "YYYY-MM-DD"
                  }
                ]
              }
              If you can't find any tests, return {"tests": []}'''
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image'
              }
            }
          ]
        }
      ],
      'max_tokens': 500
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'];
    return jsonDecode(content);
  } else {
    throw Exception('Failed to process image');
  }
}
```

### Claude API

```dart
Future<Map<String, dynamic>> processTestImageClaude(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);
  
  final response = await http.post(
    Uri.parse('https://api.anthropic.com/v1/messages'),
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': 'YOUR_API_KEY',
      'anthropic-version': '2023-06-01',
    },
    body: jsonEncode({
      'model': 'claude-3-opus-20240229',
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
              'text': '''Extract medical test results from this image. 
              Return ONLY valid JSON with this structure:
              {
                "tests": [
                  {
                    "testName": "string",
                    "value": number,
                    "unit": "string", 
                    "date": "YYYY-MM-DD"
                  }
                ]
              }'''
            }
          ],
        }
      ],
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final content = data['content'][0]['text'];
    return jsonDecode(content);
  } else {
    throw Exception('Failed to process image');
  }
}
```

## Data Structure

### Expected JSON Response from AI

```json
{
  "tests": [
    {
      "testName": "Total Cholesterol",
      "value": 195.5,
      "unit": "mg/dL",
      "date": "2025-10-15"
    },
    {
      "testName": "LDL",
      "value": 120.0,
      "unit": "mg/dL",
      "date": "2025-10-15"
    }
  ]
}
```

## New Screen: AI Review Screen

Create `lib/screens/ai_review_screen.dart`:

```dart
class AIReviewScreen extends StatefulWidget {
  final File imageFile;
  final List<ParsedTestResult> parsedResults;
  
  const AIReviewScreen({
    required this.imageFile,
    required this.parsedResults,
    super.key,
  });
}
```

Features:
1. Show original image thumbnail
2. List all detected tests
3. Allow editing each field
4. Mark tests to include/exclude
5. Add tests if missed by AI
6. Batch save all results

## Error Handling

### Common Issues

1. **Poor image quality**
   - Solution: Show image quality tips before capture
   - Implement image preprocessing (contrast, brightness)

2. **Incorrect test name recognition**
   - Solution: Fuzzy matching against known test names
   - Show dropdown of suggestions

3. **Wrong values or units**
   - Solution: Always require user review
   - Validate against expected ranges
   - Flag suspicious values

4. **API failures**
   - Solution: Graceful fallback to manual entry
   - Show clear error messages
   - Cache image for retry

## UI/UX Considerations

### Before Photo
- Show tips: "Ensure good lighting"
- "Keep results flat and fully visible"
- "Avoid shadows and glare"

### During Processing
- Show progress indicator
- Display messages: "Analyzing image..."
- Estimated time: "This may take 10-15 seconds"

### Review Screen
- Highlight fields with low confidence
- Use color coding (green=confident, yellow=uncertain, red=error)
- Allow easy editing inline
- Show original image for reference

### After Save
- Confirmation message
- Option to add more results
- Navigate to chart view to see new data

## Security & Privacy

1. **API Keys**: Use environment variables, never commit
2. **Image Storage**: Delete after processing
3. **HTTPS**: Always use encrypted connections
4. **Permissions**: Request only when needed
5. **Data**: Never store images permanently

## Testing Strategy

### Unit Tests
- Test JSON parsing
- Test value validation
- Test fuzzy matching

### Integration Tests
- Test camera flow
- Test API calls (with mocks)
- Test error scenarios

### User Tests
- Test with real lab reports
- Test with different lighting
- Test with multiple formats
- Test with elderly users

## Cost Estimates

### OpenAI GPT-4 Vision
- ~$0.01-0.03 per image
- Good for initial testing

### Claude 3
- ~$0.01-0.025 per image
- Similar pricing

### Google Cloud Vision
- ~$0.0015 per image
- Cheaper but less contextual

### Recommendation
Start with OpenAI or Claude for better accuracy, optimize costs later.

## Files to Create

1. `lib/services/camera_service.dart` - Camera handling
2. `lib/services/ai_service.dart` - API calls
3. `lib/services/image_processor.dart` - Image preprocessing
4. `lib/screens/camera_screen.dart` - Camera UI
5. `lib/screens/ai_review_screen.dart` - Review parsed data
6. `lib/models/parsed_test_result.dart` - Temporary model for AI results

## Configuration File

Create `.env`:
```
OPENAI_API_KEY=your_key_here
CLAUDE_API_KEY=your_key_here
```

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

## Gradual Rollout

### Phase 1: Beta Testing
- Enable for limited users
- Collect feedback on accuracy
- Monitor API costs

### Phase 2: Manual Review Required
- All AI results require user confirmation
- Track accuracy metrics

### Phase 3: Smart Confidence
- High confidence results auto-save
- Low confidence requires review

### Phase 4: Learning System
- User corrections improve prompts
- Personalized for common test types

## Alternative: Simpler Approach

If full AI is complex, consider:
1. **Template matching**: Recognize common lab formats
2. **Barcode scanning**: Some labs use barcodes
3. **Structured input**: Guide user with forms

## Resources

- [OpenAI Vision API Docs](https://platform.openai.com/docs/guides/vision)
- [Claude Vision Guide](https://docs.anthropic.com/claude/docs/vision)
- [Flutter Camera Plugin](https://pub.dev/packages/camera)
- [ML Kit for Flutter](https://pub.dev/packages/google_mlkit_text_recognition)

---

**Ready to implement when you are!** Start with the camera integration, then add API calls, then build the review screen. Test with real medical reports throughout the process.
