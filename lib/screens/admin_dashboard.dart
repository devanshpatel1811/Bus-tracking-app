import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Assuming /login is set up in your main.dart
import 'login_screen.dart';

// ========================================
// GLOBAL HELPER FUNCTIONS (Moved outside classes for universal access)
// ========================================

Color _getRoleColor(String? role) {
  switch (role?.toLowerCase()) {
    case 'admin':
      return Colors.purple;
    case 'driver':
      return Colors.orange;
    case 'student':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

IconData _getRoleIcon(String? role) {
  switch (role?.toLowerCase()) {
    case 'admin':
      return Icons.admin_panel_settings;
    case 'driver':
      return Icons.person;
    case 'student':
      return Icons.school;
    default:
      return Icons.person_outline;
  }
}

Color _getStatusColor(bool isActive) {
  return isActive ? Colors.green : Colors.grey;
}

// --- Dialog Functions (for User Management) ---

void _showMakeAdminDialog(BuildContext context, String docId, String userName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Make Admin'),
      content: Text('Are you sure you want to make $userName an admin?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(docId)
                  .update({'role': 'admin'});

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$userName is now an admin'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Make Admin'),
        ),
      ],
    ),
  );
}

void _showEditDialog(BuildContext context, String docId, Map<String, dynamic> userData) {
  final nameController = TextEditingController(text: userData['name']);
  String selectedRole = userData['role'] ?? 'student';

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['student', 'driver', 'admin']
                    .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role.toUpperCase()),
                ))
                    .toList(),
                onChanged: (value) => setState(() => selectedRole = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(docId)
                    .update({
                  'name': nameController.text.trim(),
                  'role': selectedRole,
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

void _showDeleteDialog(BuildContext context, String docId, String userName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete User'),
      content: Text('Are you sure you want to delete $userName?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(docId)
                  .delete();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

// ========================================
// ADMIN DASHBOARD MAIN WIDGET
// ========================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardOverview(),
    UsersManagement(),
    RoutesManagement(),
    BusesManagement(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () async {
                  Future.delayed(Duration.zero, () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF667eea),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.route_outlined),
              activeIcon: Icon(Icons.route),
              label: 'Routes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined),
              activeIcon: Icon(Icons.directions_bus),
              label: 'Buses',
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// DASHBOARD OVERVIEW
// ========================================
class DashboardOverview extends StatelessWidget {
  const DashboardOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Users',
                  icon: Icons.people,
                  color: Colors.blue,
                  collection: 'users',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Active Buses',
                  icon: Icons.directions_bus,
                  color: Colors.orange,
                  collection: 'buses',
                  whereField: 'isActive',
                  whereValue: true,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Drivers',
                  icon: Icons.person,
                  color: Colors.green,
                  collection: 'users',
                  whereField: 'role',
                  whereValue: 'driver',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Students',
                  icon: Icons.school,
                  color: Colors.purple,
                  collection: 'users',
                  whereField: 'role',
                  whereValue: 'student',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          const _RecentActivityCard(),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String collection;
  final String? whereField;
  final dynamic whereValue;

  const _StatCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.collection,
    this.whereField,
    this.whereValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: whereField != null
          ? FirebaseFirestore.instance
          .collection(collection)
          .where(whereField!, isEqualTo: whereValue)
          .snapshots()
          : FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              var user = snapshot.data!.docs[index];
              var userData = user.data() as Map<String, dynamic>;
              String name = userData['name'] ?? userData['email'] ?? 'Unknown User';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(name),
                subtitle: Text('Role: ${userData['role'] ?? 'N/A'}'),
                trailing: Text(
                  'Recent',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ========================================
// USERS MANAGEMENT
// ========================================
class UsersManagement extends StatefulWidget {
  const UsersManagement({Key? key}) : super(key: key);

  @override
  _UsersManagementState createState() => _UsersManagementState();
}

class _UsersManagementState extends State<UsersManagement> {
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Filter: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all'),
                          _buildFilterChip('Students', 'student'),
                          _buildFilterChip('Drivers', 'driver'),
                          _buildFilterChip('Admins', 'admin'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _roleFilter == 'all'
                ? FirebaseFirestore.instance.collection('users').snapshots()
                : FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: _roleFilter)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No users found', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              var users = snapshot.data!.docs.where((doc) {
                if (_searchQuery.isEmpty) return true;
                var data = doc.data() as Map<String, dynamic>;
                var name = (data['name'] ?? '').toString().toLowerCase();
                var email = (data['email'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery) || email.contains(_searchQuery);
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var userData = users[index].data() as Map<String, dynamic>;
                  return _UserCard(
                    docId: users[index].id,
                    userData: userData,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _roleFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _roleFilter = value),
        selectedColor: const Color(0xFF667eea).withOpacity(0.2),
        checkmarkColor: const Color(0xFF667eea),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> userData;

  const _UserCard({
    Key? key,
    required this.docId,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIX: Using global helper functions
    Color roleColor = _getRoleColor(userData['role']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: roleColor.withOpacity(0.2),
          // FIX: Using global helper functions
          child: Icon(_getRoleIcon(userData['role']), color: roleColor),
        ),
        title: Text(
          userData['name'] ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(userData['email'] ?? 'No Email'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                userData['role']?.toUpperCase() ?? 'UNKNOWN',
                style: TextStyle(
                  color: roleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.admin_panel_settings, size: 20),
                title: Text('Make Admin'),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () {
                Future.delayed(
                  Duration.zero,
                      () => _showMakeAdminDialog(context, docId, userData['name'] ?? 'User'),
                );
              },
            ),
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.edit, size: 20),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () {
                Future.delayed(
                  Duration.zero,
                      () => _showEditDialog(context, docId, userData),
                );
              },
            ),
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.delete, color: Colors.red, size: 20),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () {
                Future.delayed(
                  Duration.zero,
                      () => _showDeleteDialog(context, docId, userData['name'] ?? 'this user'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
// FIX: The helper functions were moved to the global scope at the top of the file
// in the full code, so they are not included here again.

// ========================================
// ROUTES MANAGEMENT
// ========================================
class RoutesManagement extends StatelessWidget {
  const RoutesManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Routes Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddRouteDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Route'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('routes')
                .orderBy('routeName')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.route, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No routes found', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var route = snapshot.data!.docs[index];
                  var routeData = route.data() as Map<String, dynamic>;
                  return _RouteCard(
                    routeId: route.id,
                    routeData: routeData,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  static void _showAddRouteDialog(BuildContext context) {
    final routeNameController = TextEditingController();
    final routeCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Route'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: routeNameController,
                decoration: InputDecoration(
                  labelText: 'Route Name',
                  hintText: 'e.g., Route A',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.route),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: routeCodeController,
                decoration: InputDecoration(
                  labelText: 'Route Code',
                  hintText: 'e.g., RT-A',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.tag),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (routeNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Route name is required')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance.collection('routes').add({
                  'routeName': routeNameController.text.trim(),
                  'routeCode': routeCodeController.text.trim().toUpperCase(),
                  'stops': [],
                  'isActive': true,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Route created successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Create Route'),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final String routeId;
  final Map<String, dynamic> routeData;

  const _RouteCard({
    Key? key,
    required this.routeId,
    required this.routeData,
  }) : super(key: key);

  // Helper method for showing the route stops dialog
  void _showStopsDialog(BuildContext context, String routeName, List stops) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Stops for $routeName (${stops.length})'),
        content: SizedBox(
          width: double.maxFinite,
          child: stops.isEmpty
              ? const Center(child: Text('No stops defined yet.'))
              : ListView.builder(
            shrinkWrap: true,
            itemCount: stops.length,
            itemBuilder: (context, index) {
              var stop = stops[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(stop['name'] ?? 'Stop ${index + 1}'),
                subtitle: Text('Lat: ${stop['latitude'] ?? 'N/A'}, Lon: ${stop['longitude'] ?? 'N/A'}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper method for showing the edit dialog
  void _showEditRouteDialog(BuildContext context, String routeId, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['routeName']);
    final codeController = TextEditingController(text: data['routeCode']);
    bool isActive = data['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Route'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Route Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Route Code',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Active:'),
                    Switch(
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Button to manage stops
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Implement dedicated Stop Management screen')),
                    );
                  },
                  icon: const Icon(Icons.pin_drop),
                  label: Text('Manage Stops (${(data['stops'] as List?)?.length ?? 0})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('routes').doc(routeId).update({
                    'routeName': nameController.text.trim(),
                    'routeCode': codeController.text.trim().toUpperCase(),
                    'isActive': isActive,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Route updated successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for showing the delete dialog
  void _showDeleteRouteDialog(BuildContext context, String routeId, String routeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Route'),
        content: Text('Are you sure you want to delete route "$routeName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('routes').doc(routeId).delete();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Route deleted successfully'), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isActive = routeData['isActive'] ?? false;
    List stops = routeData['stops'] ?? [];

    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.route,
                color: isActive ? Colors.blue : Colors.grey,
                size: 28,
              ),
            ),
            title: Text(
              routeData['routeName'] ?? 'Unknown Route',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Code: ${routeData['routeCode'] ?? 'N/A'}'),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(isActive).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      color: _getStatusColor(isActive),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.keyboard_arrow_down),
            children: [
              const Divider(height: 1, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _RouteActionChip(
                      icon: Icons.pin_drop,
                      label: 'View Stops (${stops.length})',
                      color: Colors.blueGrey,
                      onTap: () => _showStopsDialog(context, routeData['routeName'] ?? 'Route', stops),
                    ),
                    _RouteActionChip(
                      icon: Icons.edit,
                      label: 'Edit Route',
                      color: Colors.orange,
                      onTap: () => _showEditRouteDialog(context, routeId, routeData),
                    ),
                    _RouteActionChip(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onTap: () => _showDeleteRouteDialog(context, routeId, routeData['routeName'] ?? 'Route'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class _RouteActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RouteActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ========================================
// BUSES MANAGEMENT (Placeholder)
// ========================================
class BusesManagement extends StatelessWidget {
  const BusesManagement({Key? key}) : super(key: key);

  // Helper method for showing the add bus dialog
  void _showAddBusDialog(BuildContext context) {
    final busNumberController = TextEditingController();
    final capacityController = TextEditingController();
    String? selectedDriverId;
    String? selectedRouteId; // <-- Route ID variable

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Bus'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Bus Number/Plate
                TextField(
                  controller: busNumberController,
                  decoration: InputDecoration(
                    labelText: 'Bus Number/Plate',
                    hintText: 'e.g., BR01-AA-1234',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Capacity
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Capacity',
                    hintText: 'e.g., 40',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Driver Dropdown (FETCHES DRIVERS)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'driver').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();

                    List<DropdownMenuItem<String>> driverItems = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(data['name'] ?? data['email']),
                      );
                    }).toList();

                    return DropdownButtonFormField<String>(
                      value: selectedDriverId,
                      decoration: InputDecoration(
                        labelText: 'Assign Driver',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Select Driver')),
                        ...driverItems
                      ],
                      onChanged: (value) => setState(() => selectedDriverId = value),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 4. Route Dropdown (FETCHES ROUTES) <-- NEW CODE BLOCK
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('routes').where('isActive', isEqualTo: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();

                    List<DropdownMenuItem<String>> routeItems = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(data['routeName'] ?? 'Route N/A'),
                      );
                    }).toList();

                    return DropdownButtonFormField<String>(
                      value: selectedRouteId,
                      decoration: InputDecoration(
                        labelText: 'Assign Route',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Select Route')),
                        ...routeItems
                      ],
                      onChanged: (value) => setState(() => selectedRouteId = value),
                    );
                  },
                ),
                // END NEW CODE BLOCK
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                // ... (Validation and Firestore logic remains the same)
                if (busNumberController.text.isEmpty || selectedDriverId == null || selectedRouteId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required!')),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('buses').add({
                    'busNumber': busNumberController.text.trim().toUpperCase(),
                    'capacity': int.tryParse(capacityController.text) ?? 0,
                    'driverId': selectedDriverId,
                    'routeId': selectedRouteId,
                    'isActive': true,
                    'status': 'stopped',
                    'currentOccupancy': 0,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bus added successfully'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Bus'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Buses Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBusDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Bus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('buses')
                .orderBy('busNumber')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No buses found', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var bus = snapshot.data!.docs[index];
                  var busData = bus.data() as Map<String, dynamic>;
                  return _BusCard(busId: bus.id, busData: busData);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BusCard extends StatelessWidget {
  final String busId;
  final Map<String, dynamic> busData;

  const _BusCard({
    required this.busId,
    required this.busData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIX: Using the global helper function _getRouteName to fetch route name.
    // NOTE: This assumes you have a separate Firestore lookup function to get routeName from routeId.
    // For now, we'll display the ID.
    String routeId = busData['routeId'] ?? 'N/A';
    String driverId = busData['driverId'] ?? 'Unassigned';
    Color statusColor = busData['status'] == 'moving' ? Colors.green : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_bus_filled, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  busData['busNumber'] ?? 'Bus N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                // Displaying IDs until we implement a proper lookup
                Text('Route ID: $routeId | Driver ID: $driverId', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}