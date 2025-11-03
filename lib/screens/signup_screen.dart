import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final adminCodeController = TextEditingController(); // Controller for secret code

  // !! DANGER: REPLACE WITH A REAL, COMPLEX SECRET KEY IN PRODUCTION !!
  static const String _adminCode = "BUSADMIN123";

  String selectedRole = "Student";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    adminCodeController.dispose();
    super.dispose();
  }

  // --- Validation Methods ---

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Include at least one uppercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  // --- Sign Up Logic ---

  Future<void> signUp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // 1. ADMIN CODE CHECK
      if (selectedRole.toLowerCase() == 'admin' && adminCodeController.text != _adminCode) {
        throw Exception('Invalid Admin Secret Code');
      }

      // 2. Pre-check if email is already registered
      final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailController.text.trim());
      if (signInMethods.isNotEmpty) {
        throw Exception('An account with this email already exists');
      }

      // 3. Create user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await userCredential.user!.updateDisplayName(nameController.text.trim());

      // 4. Save user profile data to Firestore
      await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "role": selectedRole.toLowerCase(),
        "uid": userCredential.user!.uid,
        "createdAt": FieldValue.serverTimestamp(),
        "isActive": true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Account created successfully!', style: TextStyle(fontSize: 14))),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account with this email already exists';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = e.message ?? 'Sign up failed. Please try again';
      }
      if (mounted) _showErrorSnackBar(errorMessage);
    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- UI Build & Helper Methods ---

  @override
  Widget build(BuildContext context) {
    bool isAdmin = selectedRole.toLowerCase() == 'admin';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(top: -80, left: -50, child: _blurCircle(200, const Color(0xFF667eea))),
          Positioned(bottom: -100, right: -60, child: _blurCircle(250, const Color(0xFF764ba2))),
          Positioned(top: MediaQuery.of(context).size.height * 0.4, left: -30, child: _blurCircle(150, const Color(0xFF4DABF7))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                              ),
                              child: const Icon(Icons.person_add_rounded, size: 50, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            const Text("Create Account", style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text("Sign up to get started", style: TextStyle(fontSize: 15, color: Colors.white60)),
                            const SizedBox(height: 28),

                            // Input Fields
                            _inputField("Full Name", nameController, Icons.person_outline, validator: _validateName),
                            _inputField("Email", emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: _validateEmail),
                            _inputField("Password", passwordController, Icons.lock_outline, obscureText: _obscurePassword, validator: _validatePassword, suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white60, size: 20),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            )),
                            _inputField("Confirm Password", confirmPasswordController, Icons.lock_outline, obscureText: _obscureConfirmPassword, validator: _validateConfirmPassword, suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white60, size: 20),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            )),

                            const SizedBox(height: 4),

                            // Role Dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white.withOpacity(0.15),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: DropdownButtonFormField<String>(
                                dropdownColor: Colors.grey.shade900,
                                value: selectedRole,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.badge_outlined, color: Colors.white70, size: 22),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                items: ["Student", "Driver", "Admin"].map((role) => DropdownMenuItem(value: role, child: Text(role, style: const TextStyle(color: Colors.white)))).toList(),
                                onChanged: (value) => setState(() => selectedRole = value!),
                              ),
                            ),

                            // Admin Secret Code Field (Conditional)
                            if (isAdmin)
                              Padding(
                                padding: const EdgeInsets.only(top: 14.0),
                                child: _inputField(
                                  "Admin Secret Code",
                                  adminCodeController,
                                  Icons.vpn_key_outlined,
                                  obscureText: true,
                                  validator: (value) => isAdmin && value!.isEmpty ? 'Admin code is required' : null,
                                ),
                              ),

                            const SizedBox(height: 28),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: isLoading ? null : signUp,
                                child: isLoading
                                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                                    : const Text("Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account? ", style: TextStyle(color: Colors.white60, fontSize: 14)),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _inputField(String hint, TextEditingController controller, IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70, size: 22),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70, fontSize: 15),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: TextStyle(color: Colors.yellow.shade200, fontSize: 11),
        ),
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 80, spreadRadius: 40)],
      ),
    );
  }
}