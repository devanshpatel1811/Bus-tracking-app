import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_screen.dart';

// IMPORTANT: Ensure AdminLoginScreen and other imports are defined.
// The Admin option redirects to the main Login screen.

// Define a placeholder for the Admin Login Screen (points to main LoginScreen)
class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}

// Data Model for Roles (defined locally for simplicity)
class RoleData {
  final String role;
  final IconData icon;
  final String description;
  final Color color;

  RoleData({
    required this.role,
    required this.icon,
    required this.description,
    required this.color,
  });
}

class RoleSelectorScreen extends StatefulWidget {
  const RoleSelectorScreen({Key? key}) : super(key: key);

  @override
  _RoleSelectorScreenState createState() => _RoleSelectorScreenState();
}

class _RoleSelectorScreenState extends State<RoleSelectorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedRole;

  final List<RoleData> roles = [
    RoleData(
      role: "Student",
      icon: Icons.school_rounded,
      description: "Track your bus in real-time",
      color: const Color(0xFF4DABF7),
    ),
    RoleData(
      role: "Driver",
      icon: Icons.directions_bus_rounded,
      description: "Manage routes and updates",
      color: const Color(0xFFFF922B),
    ),
    RoleData(
      role: "Admin",
      icon: Icons.admin_panel_settings_rounded,
      description: "System configuration and oversight",
      color: const Color(0xFF764ba2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- Helper Widgets ---

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.5),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context, RoleData roleData, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleData.role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 10),
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? roleData.color.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? roleData.color : Colors.white.withOpacity(0.3),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: roleData.color.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: roleData.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                roleData.icon,
                color: roleData.color,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleData.role,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? roleData.color : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roleData.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? roleData.color.withOpacity(0.8) : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated background elements
          Positioned(
            top: -100,
            right: -80,
            child: _blurCircle(250, const Color(0xFF667eea)),
          ),
          Positioned(
            bottom: -120,
            left: -60,
            child: _blurCircle(280, const Color(0xFF4DABF7)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -40,
            child: _blurCircle(180, const Color(0xFFFF922B)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/icon
                    FadeTransition(
                      opacity: _animationController,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    FadeTransition(
                      opacity: _animationController,
                      child: const Column(
                        children: [
                          Text(
                            "Bus Tracker",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Select your role to continue",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white60,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Role cards
                    ...roles.asMap().entries.map((entry) {
                      int index = entry.key;
                      RoleData roleData = entry.value;
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              0.2 + (index * 0.15),
                              0.8 + (index * 0.15),
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                        child: _roleCard(
                          context,
                          roleData,
                          isSelected: _selectedRole == roleData.role,
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 32),
                    // Continue button
                    if (_selectedRole != null)
                      FadeTransition(
                        opacity: _animationController,
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 8,
                              shadowColor: Colors.white.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (_selectedRole == "Admin") {
                                Navigator.pushNamed(context, '/login');
                              } else {
                                // Student and Driver go to the signup screen
                                Navigator.pushNamed(context, "/signup");
                              }
                            },
                            child: Text(
                              _selectedRole == "Admin" ? "Login as Admin" : "Continue as $_selectedRole",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Back to login
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}