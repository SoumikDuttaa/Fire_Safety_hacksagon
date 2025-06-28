import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_staff_page.dart';
import 'profile_page.dart';
import 'staff.dart';
import 'staff_profile_page.dart';
import 'staff_list_page.dart';

class FireSafetyAdminDashboard extends StatefulWidget {
  final String userId;

  const FireSafetyAdminDashboard({super.key, required this.userId});

  @override
  _FireSafetyAdminDashboardState createState() => _FireSafetyAdminDashboardState();
}

class _FireSafetyAdminDashboardState extends State<FireSafetyAdminDashboard> {
  int _currentIndex = 0;
  List<Staff> staffList = [];
  Uint8List? profileImageBytes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _fetchStaffList();
  }

  Future<void> fetchUserData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      final data = docSnapshot.data();
      if (data != null && data.containsKey('profile')) {
        final base64Image = data['profile'] as String?;
        if (base64Image != null && base64Image.isNotEmpty) {
          final cleanedBase64 = base64Image.contains(',') ? base64Image.split(',').last : base64Image;
          profileImageBytes = base64Decode(cleanedBase64);
        }
      }
    } catch (e) {
      print('❌ Error fetching user data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchStaffList() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('createdBy', isEqualTo: widget.userId)
          .get();

      final List<Staff> loaded = snapshot.docs.map((doc) {
        final data = doc.data();
        return Staff(
          id: doc.id,
          name: data['Basic_Info']?['FullName'] ?? '',
          doj: data['Job_Info']?['Joining']?.toDate()?.toString().split(' ')[0] ?? '',
          email: data['Contacts']?['Email'] ?? '',
          phone: data['Contacts']?['Phone']?.toString() ?? '',
          idProof: '',
          position: data['Job_Info']?['Position'] ?? '',
          shift: data['Job_Info']?['Shift'] ?? '',
          progress: 0,
          profile: data['profile'] ?? '',
          isActive: data['isactive'] ?? true,
        );
      }).toList();

      setState(() {
        staffList = loaded;
      });
    } catch (e) {
      print("❌ Failed to fetch staff: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      FireOverviewTab(userId: widget.userId),
      StaffProgressTab(
        staffList: staffList,
        onAdd: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddStaffPage(
                onSubmit: (_) => _fetchStaffList(),
                managerUid: widget.userId,
              ),
            ),
          );
        },
        onRemove: (id) async {
          try {
            await FirebaseFirestore.instance.collection('users').doc(id).update({'isactive': false});
            setState(() => staffList.removeWhere((s) => s.id == id));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Staff account has been disabled.")));
          } catch (e) {
            print('❌ Error disabling staff: $e');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },
      ),
      const Center(
        child: Text("Drill Reports Coming Soon...", style: TextStyle(fontSize: 18)),
      ),
    ];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF0DC),
        body: Column(
          children: [
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: const Color(0xFFFDF0DC),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('BlazeON', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Admin notifications coming soon!")),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfilePage(userId: widget.userId),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                          backgroundImage: profileImageBytes != null ? MemoryImage(profileImageBytes!) : null,
                          child: profileImageBytes == null ? const Icon(Icons.person, color: Colors.white) : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: isLoading ? const Center(child: CircularProgressIndicator()) : pages[_currentIndex],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFFD09A5B),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          onTap: (index) async {
            setState(() => _currentIndex = index);
            if (index == 1) await _fetchStaffList();
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Staff'),
            BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: 'Drills'),
          ],
        ),
      ),
    );
  }
}

// FIREOVERVIEW TAB
class FireOverviewTab extends StatelessWidget {
  final String userId;
  const FireOverviewTab({super.key, required this.userId});

  Future<List<DocumentSnapshot>> fetchStaffDocs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('createdBy', isEqualTo: userId)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: fetchStaffDocs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final count = snapshot.data!.length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StaffListPage(managerId: userId),
                  ),
                );
              },
              child: _buildStatCard("Staff Registered", "$count", Icons.people_alt),
            ),
            const SizedBox(height: 16),
            _buildStatCard("Active Drills", "3", Icons.play_arrow),
            const SizedBox(height: 16),
            _buildStatCard("Avg Score", "78%", Icons.score),
            const SizedBox(height: 16),
            _buildStatCard("Incidents Today", "1", Icons.report),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.deepOrange),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ STAFFPROGRESS TAB (newly added)
class StaffProgressTab extends StatelessWidget {
  final List<Staff> staffList;
  final VoidCallback onAdd;
  final Function(String) onRemove;

  const StaffProgressTab({
    Key? key,
    required this.staffList,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.person_add),
          label: const Text("Add Staff"),
          onPressed: onAdd,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              final staff = staffList[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: staff.profile.isNotEmpty ? NetworkImage(staff.profile) : null,
                  child: staff.profile.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(staff.name),
                subtitle: Text(staff.position),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => onRemove(staff.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
