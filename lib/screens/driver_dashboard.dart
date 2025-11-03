import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _selectedIndex = 0;
  String? _driverName;
  String? _selectedBusId;
  String? _selectedRouteId;
  bool _isOnline = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDriverData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      var doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (mounted) {
        setState(() {
          _driverName = doc.data()?['name'];
          _selectedBusId = doc.data()?['selectedBusId'];
          _selectedRouteId = doc.data()?['selectedRouteId'];
        });
      }
    } catch (e) {
      print('Error loading driver data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DriverHomePage(
        isOnline: _isOnline,
        onToggleOnline: _toggleOnlineStatus,
        selectedBusId: _selectedBusId,
        selectedRouteId: _selectedRouteId,
        onBusSelected: (busId) => setState(() => _selectedBusId = busId),
        onRouteSelected: (routeId) => setState(() => _selectedRouteId = routeId),
      ),
      const DriverTripHistory(),
      DriverProfilePage(driverName: _driverName),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Driver Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF922B), Color(0xFFFF6B6B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isOnline ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(_isOnline ? 'Online' : 'Offline', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF922B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), activeIcon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _toggleOnlineStatus() {
    if (_selectedBusId == null || _selectedRouteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select bus and route first'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isOnline = !_isOnline);

    if (_isOnline) {
      _startLocationUpdates();
      _updateBusStatus('moving');
    } else {
      _locationTimer?.cancel();
      _updateBusStatus('stopped');
    }
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition();
        await _updateLocation(position);
      } catch (e) {
        print('Error getting location: $e');
      }
    });
  }

  Future<void> _updateLocation(Position position) async {
    if (_selectedBusId != null) {
      await FirebaseFirestore.instance.collection('buses').doc(_selectedBusId).update({
        'currentLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'speed': position.speed * 3.6,
          'heading': position.heading,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _updateBusStatus(String status) async {
    if (_selectedBusId != null) {
      await FirebaseFirestore.instance.collection('buses').doc(_selectedBusId).update({'status': status});
    }
  }
}

// ==================== DRIVER HOME PAGE ====================
class DriverHomePage extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggleOnline;
  final String? selectedBusId;
  final String? selectedRouteId;
  final Function(String) onBusSelected;
  final Function(String) onRouteSelected;

  const DriverHomePage({
    Key? key,
    required this.isOnline,
    required this.onToggleOnline,
    this.selectedBusId,
    this.selectedRouteId,
    required this.onBusSelected,
    required this.onRouteSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus Selection Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF922B), Color(0xFFFF6B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFFFF922B).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.directions_bus, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Trip', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Select bus and route', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SelectBusButton(selectedBusId: selectedBusId, onBusSelected: onBusSelected),
                const SizedBox(height: 12),
                _SelectRouteButton(selectedRouteId: selectedRouteId, onRouteSelected: onRouteSelected),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Start/Stop Trip Button
          Container(
            width: double.infinity,
            height: 120,
            child: ElevatedButton(
              onPressed: onToggleOnline,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOnline ? Colors.red.shade400 : Colors.green.shade400,
                elevation: 8,
                shadowColor: (isOnline ? Colors.red : Colors.green).withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isOnline ? Icons.stop_circle : Icons.play_circle_filled, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(isOnline ? 'Stop Trip' : 'Start Trip', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text("Today's Stats", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.timer, label: 'Trip Time', value: '2h 15m', color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.route, label: 'Distance', value: '45 km', color: Colors.green)),
            ],
          ),

          const SizedBox(height: 24),

          const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _ActionButton(icon: Icons.warning, label: 'Report Issue', color: Colors.red, onTap: () => _showReportDialog(context))),
              const SizedBox(width: 12),
              Expanded(child: _ActionButton(icon: Icons.notifications, label: 'Send Alert', color: Colors.orange, onTap: () => _showAlertDialog(context))),
            ],
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final issueController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Report Issue'),
        content: TextField(
          controller: issueController,
          maxLines: 4,
          decoration: InputDecoration(hintText: 'Describe the issue...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('issues').add({
                'driverId': FirebaseAuth.instance.currentUser!.uid,
                'issue': issueController.text,
                'timestamp': FieldValue.serverTimestamp(),
                'status': 'pending',
              });
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue reported successfully')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Send Alert to Students'),
        content: TextField(
          controller: messageController,
          maxLines: 3,
          decoration: InputDecoration(hintText: 'Enter message...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alert sent to students')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF922B)),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _SelectBusButton extends StatelessWidget {
  final String? selectedBusId;
  final Function(String) onBusSelected;

  const _SelectBusButton({Key? key, this.selectedBusId, required this.onBusSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: selectedBusId != null ? FirebaseFirestore.instance.collection('buses').doc(selectedBusId).snapshots() : null,
      builder: (context, snapshot) {
        String busText = 'Select Bus';
        if (snapshot.hasData && snapshot.data!.exists) {
          busText = snapshot.data!['busNumber'] ?? 'Unknown Bus';
        }

        return ElevatedButton(
          onPressed: () => _showBusSelectionDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFFF922B),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(busText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      },
    );
  }

  void _showBusSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Bus'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('buses').where('isActive', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              if (snapshot.data!.docs.isEmpty) return const Text('No buses available');

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var bus = snapshot.data!.docs[index];
                  var busData = bus.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.directions_bus, color: Color(0xFFFF922B)),
                    title: Text(busData['busNumber'] ?? 'Unknown'),
                    subtitle: Text('Capacity: ${busData['capacity']}'),
                    onTap: () async {
                      onBusSelected(bus.id);
                      String uid = FirebaseAuth.instance.currentUser!.uid;
                      await FirebaseFirestore.instance.collection('users').doc(uid).update({'selectedBusId': bus.id});
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SelectRouteButton extends StatelessWidget {
  final String? selectedRouteId;
  final Function(String) onRouteSelected;

  const _SelectRouteButton({Key? key, this.selectedRouteId, required this.onRouteSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: selectedRouteId != null ? FirebaseFirestore.instance.collection('routes').doc(selectedRouteId).snapshots() : null,
      builder: (context, snapshot) {
        String routeText = 'Select Route';
        if (snapshot.hasData && snapshot.data!.exists) {
          routeText = snapshot.data!['routeName'] ?? 'Unknown Route';
        }

        return ElevatedButton(
          onPressed: () => _showRouteSelectionDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFFF922B),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(routeText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        );
      },
    );
  }

  void _showRouteSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Route'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('routes').where('isActive', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              if (snapshot.data!.docs.isEmpty) return const Text('No routes available');

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var route = snapshot.data!.docs[index];
                  var routeData = route.data() as Map<String, dynamic>;
                  List stops = routeData['stops'] ?? [];
                  return ListTile(
                    leading: const Icon(Icons.route, color: Color(0xFFFF922B)),
                    title: Text(routeData['routeName'] ?? 'Unknown'),
                    subtitle: Text('${stops.length} stops'),
                    onTap: () async {
                      onRouteSelected(route.id);
                      String uid = FirebaseAuth.instance.currentUser!.uid;
                      await FirebaseFirestore.instance.collection('users').doc(uid).update({'selectedRouteId': route.id});
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({Key? key, required this.icon, required this.label, required this.value, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({Key? key, required this.icon, required this.label, required this.color, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ==================== DRIVER TRIP HISTORY ====================
class DriverTripHistory extends StatelessWidget {
  const DriverTripHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trip History', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Center(child: Text('Trip history will appear here', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}

// ==================== DRIVER PROFILE ====================
class DriverProfilePage extends StatelessWidget {
  final String? driverName;

  const DriverProfilePage({Key? key, this.driverName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(radius: 50, backgroundColor: const Color(0xFFFF922B).withOpacity(0.2), child: const Icon(Icons.person, size: 50, color: Color(0xFFFF922B))),
          const SizedBox(height: 16),
          Text(driverName ?? 'Driver Name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Professional Driver', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          const _ProfileOption(Icons.settings, 'Settings'),
          const _ProfileOption(Icons.help, 'Help & Support'),
          const _ProfileOption(Icons.info, 'About'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileOption(this.icon, this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF922B)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}