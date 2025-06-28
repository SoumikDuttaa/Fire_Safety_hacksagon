import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffListPage extends StatefulWidget {
  final String managerId;

  const StaffListPage({Key? key, required this.managerId}) : super(key: key);

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  Future<List<DocumentSnapshot>> fetchStaffDocs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('createdBy', isEqualTo: widget.managerId)
        .get();
    return snapshot.docs;
  }

  void toggleStatus(String uid, bool currentStatus) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isactive': !currentStatus,
    });
    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0DC),
      appBar: AppBar(
        title: const Text('Staff List'),
        backgroundColor: const Color(0xFFD09A5B),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchStaffDocs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No staff found.'));
          }

          final staffDocs = snapshot.data!;

          return ListView.builder(
            itemCount: staffDocs.length,
            itemBuilder: (context, index) {
              final data = staffDocs[index].data() as Map<String, dynamic>;

              final fullName = data['Basic_Info']?['FullName'] ?? 'Unknown';
              final email = data['Contacts']?['Email'] ?? 'No email';
              final position = data['Job_Info']?['Position'] ?? 'N/A';
              final shift = data['Job_Info']?['Shift'] ?? 'N/A';
              final uid = data['uid'] ?? 'N/A';
              final isActive = data['isactive'] ?? true;
              final profileBase64 = data['profile'];

              ImageProvider avatarImage;
              if (profileBase64 != null && profileBase64 != '') {
                avatarImage = MemoryImage(base64Decode(profileBase64));
              } else {
                avatarImage = const AssetImage('assets/default_avatar.png');
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: avatarImage,
                            radius: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fullName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("Position: $position"),
                                Text("Email: $email"),
                                Text("Shift: $shift"),
                                Text("UID: $uid", style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text("10% Completed", style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.1,
                        color: Colors.deepPurple,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isActive ? "Status: Active" : "Status: Inactive",
                            style: TextStyle(
                              color: isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: isActive,
                            activeColor: Colors.deepPurple,
                            onChanged: (_) => toggleStatus(uid, isActive),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
