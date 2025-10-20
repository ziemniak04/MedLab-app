# MedLab - Medical Test Results Tracker

A modern, accessible Flutter application for tracking and visualizing medical test results over time.

## Overview

MedLab helps users store and manage their medical test results such as blood counts, cholesterol levels, thyroid functions, and more. The app provides interactive charts and visual trends to help track changes over time.

## Features

### ✅ MVP Features (Current)

- **No Login Required**: One device, one user - everything stored locally
- **User Profile**: Simple name input on first launch
- **Dashboard**: 
  - Personalized welcome
  - Quick access to add results and view charts
  - Recent test results preview
- **Manual Entry**: Step-by-step guided process to add test results
  - Select from 6 pre-defined test categories
  - Multiple tests per category with normal ranges
  - Date selection
  - Optional notes
- **AI-Assisted Entry Placeholder**: "Coming Soon" notification for future feature
- **History View**: Complete list of all test results with delete capability
- **Charts & Trends**: 
  - Interactive line charts
  - Statistical analysis (latest, average, min, max)
  - Visual trends over time
- **Modern UI**: 
  - Google Material Design 3
  - Clean white theme
  - Large, accessible buttons
  - Elder-friendly interface

### 🔜 Future Features

- AI-assisted data entry with camera and OCR
- Cloud backup and sync
- Export to PDF/CSV
- Reminders for regular tests
- Health insights
- Multi-language support

## Test Categories

The app includes 6 pre-configured test categories:

1. **Blood Count** 🩸
   - Hemoglobin, White Blood Cells, Platelets

2. **Cholesterol** 💊
   - Total Cholesterol, LDL, HDL, Triglycerides

3. **Thyroid** 🦋
   - TSH, T3, T4

4. **Blood Sugar** 🍬
   - Glucose (Fasting), HbA1c

5. **Liver Function** 🫀
   - ALT, AST, Bilirubin

6. **Kidney Function** 💧
   - Creatinine, BUN

## Technical Stack

- **Framework**: Flutter ^3.9.2
- **Database**: SQLite (sqflite)
- **Charts**: FL Chart
- **Storage**: Shared Preferences
- **UI**: Material Design 3

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  shared_preferences: ^2.2.2
  fl_chart: ^0.66.0
  intl: ^0.19.0
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── test_result.dart        # Test result data model
│   └── test_category.dart      # Category and template models
├── services/
│   ├── database_helper.dart    # SQLite database operations
│   └── user_preferences.dart   # User settings storage
└── screens/
    ├── welcome_screen.dart     # First-time onboarding
    ├── home_screen.dart        # Main dashboard
    ├── add_result_screen.dart  # Add new test result
    ├── history_screen.dart     # All test results
    └── chart_screen.dart       # Charts and trends
```

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.2
- Android Studio / VS Code
- Android SDK / iOS SDK

### Installation

1. Clone the repository
2. Navigate to project directory:
   ```bash
   cd flutter_application_1
   ```

3. **(Linux only)** Install SQLite3 library:
   ```bash
   sudo apt-get install -y libsqlite3-dev
   ```

4. Install dependencies:
   ```bash
   flutter pub get
   ```

5. Run the app:
   
   **For Android/iOS:**
   ```bash
   flutter run
   ```
   
   **For Linux (recommended - release mode):**
   ```bash
   flutter build linux --release
   ./build/linux/x64/release/bundle/flutter_application_1
   ```
   
   **For Linux (debug mode):**
   ```bash
   flutter run -d linux
   ```
   Note: Debug mode may experience compiler issues on some Linux systems. Use release mode if debug crashes.

### First Launch

On first launch, the app will:
1. Ask for your name
2. Create a local database
3. Add sample data for demonstration
4. Navigate to the home screen

## Usage

### Adding a Test Result

1. Tap "Add Result" on the home screen
2. Choose "Manual Entry"
3. Select a test category (e.g., Blood Count)
4. Select a specific test (e.g., Hemoglobin)
5. Enter the value with normal ranges as reference
6. Select the test date
7. Optionally add notes
8. Save

### Viewing Charts

1. Tap "View Charts" on the home screen
2. Select a test from the available options
3. View the trend line chart
4. See statistics: latest, average, lowest, highest
5. Scroll down to see all measurements

### Managing Results

- **View Details**: Tap any result to see full details
- **Delete**: Tap the delete icon on any result
- **Refresh**: Pull down to refresh the list

## Design Principles

### Accessibility

- Large, easy-to-read text
- High contrast colors
- Clear visual hierarchy
- Simple navigation
- Guided workflows

### User Experience

- Progressive disclosure (step-by-step)
- Helpful empty states
- Clear feedback (loading, success, errors)
- Confirmation for destructive actions
- Normal ranges shown for context

### Visual Design

- Modern Google Material Design 3
- Clean white background
- Blue accent color (#0D47A1)
- Rounded corners (12px)
- Subtle shadows and borders
- Emoji icons for categories

## Database Schema

### test_results

| Column    | Type    | Description                    |
|-----------|---------|--------------------------------|
| id        | INTEGER | Primary key (auto-increment)   |
| testType  | TEXT    | Category name                  |
| testName  | TEXT    | Specific test name             |
| value     | REAL    | Test result value              |
| unit      | TEXT    | Unit of measurement            |
| date      | TEXT    | Test date (ISO 8601)           |
| notes     | TEXT    | Optional notes (nullable)      |

## Mock Data

The app includes mock data for demonstration:
- 6 months of Total Cholesterol readings (trending down)
- 3 months of Glucose (Fasting) readings
- 2 TSH readings

Mock data is automatically added on first launch if no data exists.

## Contributing

This is an MVP. Future contributions should focus on:
- AI/OCR integration
- Additional test categories
- Data export features
- Cloud sync
- Enhanced visualizations

## License

[Add your license here]

## Contact

[Add contact information]

---

**MedLab** - Track your health, visualize your progress 📊💪
