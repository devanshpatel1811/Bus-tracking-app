class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'admin', 'driver', or 'student'
  final bool isActive;
  final String? assignedRouteId;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
    this.assignedRouteId,
  });

factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'student',
      isActive: data['isActive'] ?? true,
      assignedRouteId: data['assignedRouteId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
      'assignedRouteId': assignedRouteId,
    };
  }
}