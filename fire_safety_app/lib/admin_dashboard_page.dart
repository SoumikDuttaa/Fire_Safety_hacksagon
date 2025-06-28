import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'add_staff_page.dart';
import 'profile_page.dart';
import 'staff.dart';
import 'staff_profile_page.dart';

class FireSafetyAdminDashboard extends StatefulWidget {
  final String userId;

  const FireSafetyAdminDashboard({super.key, required this.userId});

  @override
  _FireSafetyAdminDashboardState createState() =>
      _FireSafetyAdminDashboardState();
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
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();

      final data = docSnapshot.data();
      if (data != null && data.containsKey('profile')) {
        final base64Image = data['profile'] as String?;
        if (base64Image != null && base64Image.isNotEmpty) {
          final cleanedBase64 =
              base64Image.contains(',')
                  ? base64Image.split(',').last
                  : base64Image;
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
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('createdBy', isEqualTo: widget.userId)
              .get();

      final List<Staff> loaded =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return Staff(
              id: doc.id,
              name: data['Basic_Info']?['FullName'] ?? '',
              doj:
                  data['Job_Info']?['Joining']?.toDate()?.toString().split(
                    ' ',
                  )[0] ??
                  '',
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
              builder:
                  (_) => AddStaffPage(
                    onSubmit: (_) => _fetchStaffList(),
                    managerUid: widget.userId,
                  ),
            ),
          );
        },
        onRemove: (id) async {
          try {
            await FirebaseFirestore.instance.collection('users').doc(id).update(
              {'isactive': false},
            );

            setState(() => staffList.removeWhere((s) => s.id == id));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Staff account has been disabled.")),
            );
          } catch (e) {
            print('❌ Error disabling staff: $e');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },
      ),
      const Center(
        child: Text(
          "Drill Reports Coming Soon...",
          style: TextStyle(fontSize: 18),
        ),
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
              
                const Text(
                  'BlazeON',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Admin notifications coming soon!"),
                          ),
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
                        backgroundImage:
                            profileImageBytes != null
                                ? MemoryImage(profileImageBytes!)
                                : null,
                        child:
                            profileImageBytes == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
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
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : pages[_currentIndex],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Staff'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Drills',
          ),
        ],
      ),
      ),
    );
  }
}

class StaffProgressTab extends StatefulWidget {
  final List<Staff> staffList;
  final VoidCallback onAdd;
  final Function(String) onRemove;

  const StaffProgressTab({
    required this.staffList,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  @override
  State<StaffProgressTab> createState() => _StaffProgressTabState();
}

class _StaffProgressTabState extends State<StaffProgressTab> {
  late List<Staff> _localStaffList;

  @override
  void initState() {
    super.initState();
    _localStaffList = List.from(widget.staffList);
  }

  void _toggleStatus(int index, bool newValue) async {
    final staff = _localStaffList[index];
    try {
      await FirebaseFirestore.instance.collection('users').doc(staff.id).update(
        {'isactive': newValue},
      );

      setState(() {
        _localStaffList[index] = Staff(
          id: staff.id,
          name: staff.name,
          doj: staff.doj,
          email: staff.email,
          phone: staff.phone,
          idProof: staff.idProof,
          position: staff.position,
          shift: staff.shift,
          progress: staff.progress,
          profile: staff.profile,
          isActive: newValue,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newValue ? "User re-enabled" : "User disabled")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update status")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStaff = _localStaffList.where((s) => s.isActive).toList();
    final inactiveStaff = _localStaffList.where((s) => !s.isActive).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Staff List",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add),
                label: const Text("Add Staff"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _localStaffList.isEmpty
                  ? const Center(child: Text("No staff added yet."))
                  : ListView(
                    children: [
                      if (activeStaff.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Active Staff",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ...activeStaff.map((staff) => _buildStaffCard(staff)),

                      if (inactiveStaff.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 24, bottom: 8),
                          child: Text(
                            "Disabled Staff",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ...inactiveStaff.map((staff) => _buildStaffCard(staff)),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildStaffCard(Staff staff) {
    final index = _localStaffList.indexWhere((s) => s.id == staff.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StaffProfilePage(staffId: staff.id), // Pass ID
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  staff.profile.isNotEmpty
                      ? CircleAvatar(
                        radius: 25,
                        backgroundImage: MemoryImage(
                          base64Decode(staff.profile),
                        ),
                      )
                      : const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staff.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text("Position: ${staff.position}"),
                        Text("Email: ${staff.email}"),
                        Text("Phone: ${staff.phone}"),
                        Text("Shift: ${staff.shift}"),
                        Text(
                          "UID: ${staff.id}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: staff.progress / 100,
                backgroundColor: Colors.grey.shade300,
                color: Colors.deepOrange,
              ),
              Text("${staff.progress}% Complete"),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    staff.isActive ? "Status: Active" : "Status: Disabled",
                    style: TextStyle(
                      color: staff.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: staff.isActive,
                    onChanged: (newValue) => _toggleStatus(index, newValue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FireOverviewTab extends StatefulWidget {
  final String userId;

  const FireOverviewTab({super.key, required this.userId});

  @override
  State<FireOverviewTab> createState() => _FireOverviewTabState();
}

class _FireOverviewTabState extends State<FireOverviewTab> {
  int userRegisterCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserRegisterCount();
  }

  Future<void> fetchUserRegisterCount() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          userRegisterCount = data['staffcount'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching staff count: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCard(
              "Staff Registered",
              "$userRegisterCount",
              Icons.people_alt,
            ),
            const SizedBox(height: 16),
            _buildStatCard("Active Drills", "3", Icons.play_arrow),
            const SizedBox(height: 16),
            _buildStatCard("Avg Score", "78%", Icons.score),
            const SizedBox(height: 16),
            _buildStatCard("Incidents Today", "1", Icons.report),
          ],
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
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}