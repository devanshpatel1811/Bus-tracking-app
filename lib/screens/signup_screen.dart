import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String ADMIN_SECRET_CODE = "BUSADMIN123";

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final adminCodeController = TextEditingController();

  String selectedRole = "Student";
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool isLoading = false;

  // ✅ VALIDATION FUNCTIONS
  String? validateName(val) =>
      val!.isEmpty ? "Enter name" : val.length < 2 ? "Too short" : null;

  String? validateEmail(val) {
    if (val!.isEmpty) return "Enter email";
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return !regex.hasMatch(val) ? "Invalid email" : null;
  }

  String? validatePassword(val) {
    if (val!.isEmpty) return "Enter password";
    if (val.length < 6) return "Min 6 characters";
    if (!val.contains(RegExp(r"[A-Z]"))) return "Add uppercase letter";
    if (!val.contains(RegExp(r"[0-9]"))) return "Add number";
    return null;
  }

  String? validateConfirmPassword(val) =>
      val != passwordController.text ? "Passwords not match" : null;

  // ✅ SIGNUP FUNCTION
  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      // Check if email already exists
      final existing = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(emailController.text.trim());
      if (existing.isNotEmpty) throw Exception("Email already registered");

      // Create user
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      // ✅ Assign role
      String role = selectedRole.toLowerCase(); // student/driver

      // ✅ Admin secret code check
      if (adminCodeController.text.trim().isNotEmpty) {
        if (adminCodeController.text.trim() != ADMIN_SECRET_CODE) {
          throw Exception("Invalid Admin Secret Code");
        }
        role = "admin";
      }

      // ✅ Save to Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(cred.user!.uid)
          .set({
        "uid": cred.user!.uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "role": role,
        "createdAt": FieldValue.serverTimestamp(),
        "isActive": true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created! ✅")),
      );

      Navigator.pop(context); // back to login
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ✅ GLASS INPUT FIELD UI
  Widget glassField(String hint, TextEditingController c, IconData icon,
      {bool obscure = false,
        Widget? suffix,
        TextInputType type = TextInputType.text,
        String? Function(String?)? validator}) {
    return Container(
      margin: EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        validator: validator,
        style: TextStyle(color: Colors.white),
        keyboardType: type,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white70),
          suffixIcon: suffix,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget blurCircle(double size, Color color) => Positioned(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(.5),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        blurCircle(200, Color(0xFF667eea)),
        blurCircle(250, Color(0xFF764ba2)),
        blurCircle(160, Color(0xFF4DABF7)),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(22),
              child: Form(
                key: _formKey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(children: [
                        Icon(Icons.person_add_rounded, size: 60, color: Colors.white),
                        SizedBox(height: 10),
                        Text("Create Account",
                            style: TextStyle(fontSize: 28, color: Colors.white)),
                        SizedBox(height: 20),

                        glassField("Full Name", nameController, Icons.person,
                            validator: validateName),

                        glassField("Email", emailController, Icons.email,
                            type: TextInputType.emailAddress,
                            validator: validateEmail),

                        glassField("Password", passwordController, Icons.lock,
                            obscure: _obscurePass,
                            validator: validatePassword,
                            suffix: IconButton(
                              icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white70),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            )),

                        glassField("Confirm Password", confirmPasswordController,
                            Icons.lock_outline,
                            obscure: _obscureConfirm,
                            validator: validateConfirmPassword,
                            suffix: IconButton(
                              icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white70),
                              onPressed: () =>
                                  setState(() => _obscureConfirm = !_obscureConfirm),
                            )),

                        // ✅ Role dropdown
                        Container(
                          margin: EdgeInsets.only(top: 14),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(color: Colors.white.withOpacity(.3)),
                          ),
                          child: DropdownButtonFormField(
                            dropdownColor: Colors.black87,
                            value: selectedRole,
                            iconEnabledColor: Colors.white,
                            decoration: InputDecoration(border: InputBorder.none),
                            items: ["Student", "Driver"]
                                .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: TextStyle(color: Colors.white)),
                            ))
                                .toList(),
                            onChanged: (v) => setState(() => selectedRole = v!),
                          ),
                        ),

                        glassField("Admin Secret Code (optional)",
                            adminCodeController, Icons.key),

                        SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16))),
                            onPressed: isLoading ? null : signUp,
                            child: isLoading
                                ? CircularProgressIndicator(color: Colors.black)
                                : Text("Sign Up",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Already have an account? Login",
                                style: TextStyle(color: Colors.white)))
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
