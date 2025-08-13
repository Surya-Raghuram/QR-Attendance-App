import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AttendanceService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new class
  Future<String> createClass({
    required String name,
    required String teacherId,
    required String teacherName,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('classes').add({
        'name': name,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'enrolledStudents': <String>[],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'isActive': true,
      });

      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      print('Create class error: $e');
      rethrow;
    }
  }

  // Get classes for teacher
  Stream<List<ClassModel>> getTeacherClasses(String teacherId) {
    return _firestore
        .collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return ClassModel.fromMap(data);
      }).toList();
    });
  }

  // Get classes for student
  Stream<List<ClassModel>> getStudentClasses(List<String> classIds) {
    if (classIds.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('classes')
        .where(FieldPath.documentId, whereIn: classIds)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return ClassModel.fromMap(data);
      }).toList();
    });
  }

  // Mark attendance by QR scan
  Future<void> markAttendance({
    required String classId,
    required String studentId,
    required String studentName,
  }) async {
    try {
      // Check if already marked today
      DateTime today = DateTime.now();
      String dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      QuerySnapshot existingAttendance = await _firestore
          .collection('attendance')
          .where('classId', isEqualTo: classId)
          .where('studentId', isEqualTo: studentId)
          .where('dateStr', isEqualTo: dateStr)
          .get();

      if (existingAttendance.docs.isNotEmpty) {
        throw Exception('Attendance already marked for today');
      }

      // Get class info
      DocumentSnapshot classDoc = await _firestore.collection('classes').doc(classId).get();
      if (!classDoc.exists) {
        throw Exception('Class not found');
      }

      String className = (classDoc.data() as Map<String, dynamic>?)?['name'] ?? 'Unknown Class';


      // Mark attendance
      await _firestore.collection('attendance').add({
        'id': '',
        'classId': classId,
        'className': className,
        'studentId': studentId,
        'studentName': studentName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'status': 'present',
        'dateStr': dateStr,
        'notes': null,
      });

    } catch (e) {
      print('Mark attendance error: $e');
      rethrow;
    }
  }

  // Get attendance records for a class
  Stream<List<AttendanceRecord>> getClassAttendance(String classId, {DateTime? date}) {
    Query query = _firestore
        .collection('attendance')
        .where('classId', isEqualTo: classId);

    if (date != null) {
      String dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      query = query.where('dateStr', isEqualTo: dateStr);
    }

    return query
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return AttendanceRecord.fromMap(data);
      }).toList();
    });
  }

  // Get student's attendance history
  Stream<List<AttendanceRecord>> getStudentAttendance(String studentId) {
    return _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return AttendanceRecord.fromMap(data);
      }).toList();
    });
  }

  // Update attendance status
  Future<void> updateAttendanceStatus(String attendanceId, String status, {String? notes}) async {
    try {
      await _firestore.collection('attendance').doc(attendanceId).update({
        'status': status,
        'notes': notes,
      });
    } catch (e) {
      print('Update attendance status error: $e');
      rethrow;
    }
  }

  // Join class (for students)
  Future<void> joinClass(String classCode, String studentId) async {
    try {
      // Find class by ID
      DocumentSnapshot classDoc = await _firestore.collection('classes').doc(classCode).get();

      if (!classDoc.exists) {
        throw Exception('Class not found');
      }

      Map<String, dynamic> classData = classDoc.data() as Map<String, dynamic>;
      List<String> enrolledStudents = List<String>.from(classData['enrolledStudents'] ?? []);

      if (!enrolledStudents.contains(studentId)) {
        enrolledStudents.add(studentId);

        await _firestore.collection('classes').doc(classCode).update({
          'enrolledStudents': enrolledStudents,
        });
      }
    } catch (e) {
      print('Join class error: $e');
      rethrow;
    }
  }
}