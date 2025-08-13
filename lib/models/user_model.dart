enum UserRole { student, teacher }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? studentId;
  final List<String>? classIds; // Classes student is enrolled in or teacher teaches

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.studentId,
    this.classIds,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.student,
      ),
      studentId: map['studentId'],
      classIds: List<String>.from(map['classIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'studentId': studentId,
      'classIds': classIds,
    };
  }
}

class ClassModel {
  final String id;
  final String name;
  final String teacherId;
  final String teacherName;
  final List<String> enrolledStudents;
  final DateTime createdAt;
  final bool isActive;

  ClassModel({
    required this.id,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.enrolledStudents,
    required this.createdAt,
    this.isActive = true,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      enrolledStudents: List<String>.from(map['enrolledStudents'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'enrolledStudents': enrolledStudents,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }
}

class AttendanceRecord {
  final String id;
  final String classId;
  final String className;
  final String studentId;
  final String studentName;
  final DateTime timestamp;
  final String status; // present, absent, late
  final String? notes;

  AttendanceRecord({
    required this.id,
    required this.classId,
    required this.className,
    required this.studentId,
    required this.studentName,
    required this.timestamp,
    required this.status,
    this.notes,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      status: map['status'] ?? 'present',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      'studentId': studentId,
      'studentName': studentName,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status,
      'notes': notes,
    };
  }
}