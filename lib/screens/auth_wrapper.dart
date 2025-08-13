import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'auth/login_screen.dart';
import 'student/student_home.dart';
import 'teacher/teacher_home.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder(
            future: context.read<AuthService>().getCurrentUser(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return Consumer<AuthService>(
                builder: (context, authService, child) {
                  if (authService.currentUser == null) {
                    return LoginScreen();
                  }

                  if (authService.currentUser!.role == UserRole.student) {
                    return StudentHome();
                  } else {
                    return TeacherHome();
                  }
                },
              );
            },
          );
        }

        return LoginScreen();
      },
    );
  }
}