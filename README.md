# QR Attendance App

A Flutter-based mobile application for QR code attendance management with Firebase integration. This app allows teachers to create classes, generate QR codes, and students to mark attendance by scanning QR codes.

## Features

### For Students
- 📱 Register and login with email/password
- 🔍 Join classes using class codes
- 📷 Scan QR codes to mark attendance
- 📊 View personal attendance history
- 🚫 Prevent duplicate attendance marking per day

### For Teachers
- 👨‍🏫 Create and manage classes
- 🎯 Generate unique QR codes for each class
- 📋 View and manage attendance records
- ✏️ Update attendance status (Present/Late/Absent)
- 📅 Filter attendance by date
- 📊 View attendance statistics

## Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore, Authentication)
- **QR Code Generation:** qr_flutter
- **QR Code Scanning:** qr_code_scanner
- **State Management:** Provider

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── user_model.dart      # User, Class, and Attendance models
├── services/                 # Business logic and Firebase services
│   ├── auth_service.dart    # Authentication service
│   └── attendance_service.dart # Attendance management service
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── student/             # Student screens
│   │   ├── student_home.dart
│   │   ├── qr_scanner_screen.dart
│   │   ├── student_attendance_history.dart
│   │   └── join_class_screen.dart
│   ├── teacher/             # Teacher screens
│   │   ├── teacher_home.dart
│   │   ├── create_class_screen.dart
│   │   ├── class_details_screen.dart
│   │   └── attendance_list_screen.dart
│   └── auth_wrapper.dart    # Authentication state handler
└── utils/
    └── theme.dart           # App theme configuration
```

## Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication and Firestore Database

### 2. Configure Authentication
- Enable Email/Password authentication in Firebase Console
- Go to Authentication > Sign-in method > Enable Email/Password

### 3. Configure Firestore Database
- Create a Firestore database in production mode
- Set up the following security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read classes, only teachers can write
    match /classes/{classId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        resource.data.teacherId == request.auth.uid;
    }
    
    // Attendance records
    match /attendance/{attendanceId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Add Firebase Configuration
1. Download `google-services.json` for Android and place in `android/app/`
2. Download `GoogleService-Info.plist` for iOS and place in `ios/Runner/`
3. Update `lib/firebase_options.dart` with your Firebase project configuration

## Installation & Setup

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code
- Firebase CLI (optional)

### Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd qr_attendance_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
- Follow the Firebase setup instructions above
- Update `firebase_options.dart` with your project details

4. **Run the app**
```bash
flutter run
```

## Usage Guide

### For Teachers

1. **Register/Login** with email and password, select "Teacher" role
2. **Create a Class** from the dashboard
3. **Share Class Code** with students for enrollment
4. **Generate QR Code** for attendance in class details
5. **View Attendance** records and manage student attendance status

### For Students

1. **Register/Login** with email and password, select "Student" role and enter Student ID
2. **Join Class** using the class code provided by teacher
3. **Scan QR Code** during class to mark attendance
4. **View History** to check personal attendance records

## Key Features Implementation

### QR Code Format
- Format: `attendance:{classId}`
- Example: `attendance:abc123def456`

### Attendance Logic
- Students can only mark attendance once per day per class
- Automatic timestamp recording
- Status can be updated by teachers (Present/Late/Absent)

### Security Features
- Firebase Authentication for user management
- Firestore security rules to protect data
- Input validation on all forms
- Error handling for network issues

## Database Schema

### Users Collection
```javascript
{
  uid: string,
  email: string,
  name: string,
  role: "student" | "teacher",
  studentId?: string, // Only for students
  classIds: string[] // Classes enrolled/teaching
}
```

### Classes Collection
```javascript
{
  id: string,
  name: string,
  teacherId: string,
  teacherName: string,
  enrolledStudents: string[],
  createdAt: timestamp,
  isActive: boolean
}
```

### Attendance Collection
```javascript
{
  id: string,
  classId: string,
  className: string,
  studentId: string,
  studentName: string,
  timestamp: timestamp,
  status: "present" | "late" | "absent",
  dateStr: string, // YYYY-MM-DD format for daily uniqueness
  notes?: string
}
```

## Permissions

The app requires the following permissions:

### Android (`android/app/src/main/AndroidManifest.xml`)
- `CAMERA` - For QR code scanning
- `INTERNET` - For Firebase connectivity
- `ACCESS_NETWORK_STATE` - For network status

## Customization

### Theme
- Modify `lib/utils/theme.dart` to customize app colors and styling
- Primary color: `#6366F1` (Indigo)
- Secondary color: `#EC4899` (Pink)

### Features to Add
- [ ] Push notifications for attendance reminders
- [ ] Export attendance data to CSV
- [ ] Attendance analytics and reports
- [ ] Bulk student import
- [ ] Class schedule management
- [ ] Offline attendance marking

## Troubleshooting

### Common Issues

1. **QR Scanner not working**
   - Ensure camera permissions are granted
   - Check if device has a working camera
   - Restart the app if scanner freezes

2. **Firebase connection issues**
   - Verify internet connection
   - Check Firebase configuration
   - Ensure Firestore rules allow access

3. **Build errors**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart SDK versions
   - Verify all dependencies are compatible

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions, please open an issue in the repository or contact the development team.