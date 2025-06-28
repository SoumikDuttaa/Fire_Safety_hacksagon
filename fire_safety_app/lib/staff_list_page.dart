import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffListPage extends StatelessWidget {
  final String managerId;

  const StaffListPage({Key? key, required this.managerId}) : super(key: key);

  Future<List<DocumentSnapshot>> fetchStaffDocs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('createdBy', isEqualTo: managerId)
        .get();
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0DC),
      appBar: AppBar(
        title: const Text('Staff Details'),
        backgroundColor: const Color(0xFFD09A5B),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchStaffDocs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No staff data found.'));
          }

          final staffDocs = snapshot.data!;

          return ListView.builder(
            itemCount: staffDocs.length,
            itemBuilder: (context, index) {
              final data = staffDocs[index].data() as Map<String, dynamic>;
              final fullName = data['Basic_Info']?['FullName'] ?? 'Unknown';
              final position = data['Job_Info']?['Position'] ?? 'N/A';
              final joiningDate = data['Job_Info']?['Joining']?.toDate()?.toString().split(' ')[0] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Position: $position"),
                      Text("Joining Date: $joiningDate"),
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
