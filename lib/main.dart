import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/student_dashboard_screen.dart';
// import 'screens/driver_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      routes: {
        '/login': (_) => LoginScreen(),
        '/admin': (_) => AdminDashboardScreen(),
        "/signup": (_) => SignUpScreen(),
        '/student': (_) => StudentDashboardScreen(),
        // '/driver': (_) => DriverDashboardScreen(),
      },
    );
  }
}

// Router to check role
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LoginScreen();

        final uid = snapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection("users").doc(uid).get(),
          builder: (context, snap) {
            if (!snap.hasData) return Scaffold(body: Center(child: CircularProgressIndicator()));

            String role = snap.data!.get("role");

            if (role == "admin") return AdminDashboardScreen();
            // if (role == "driver") return DriverDashboardScreen();
            return StudentDashboardScreen();
          },
        );
      },
    );
  }
}
