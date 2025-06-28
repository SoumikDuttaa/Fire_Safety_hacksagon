import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../EditStaffPage.dart';
import '../login_page.dart'; // ✅ Import login page

class UserProfilePanel extends StatelessWidget {
  final String userId;

  const UserProfilePanel({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _errorPanel("No data found");
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;

        if (userData == null) return _errorPanel("Invalid user data");

        final basicInfo = userData['Basic_Info'] ?? {};
        final hotelInfo = userData['Hotel_Info'] ?? {};
        final jobInfo = userData['Job_Info'] ?? {};
        final drillInfo = userData['Drill_Info'] ?? {};

        final base64Image = userData['profile'];
        final imageProvider = base64Image != null && base64Image != ''
            ? MemoryImage(base64Decode(base64Image))
            : const AssetImage('assets/default_avatar.jpg') as ImageProvider;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) => Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFDF0DC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: imageProvider,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name: ${basicInfo['FullName'] ?? 'N/A'}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Age: ${_calculateAge(basicInfo['Age'])}"),
                            Text("Position: ${jobInfo['Position'] ?? 'N/A'}"),
                            Text("Hotel Name: ${hotelInfo['Hotel'] ?? 'N/A'}"),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditStaffPage(staffId: userId)),
                          );
                          Navigator.pop(context); // Close after edit
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1.2),

                  _sectionTitle("📘 Basic Info"),
                  _infoText("Full Name", basicInfo['FullName']),
                  _infoText("Age", _calculateAge(basicInfo['Age'])),
                  _infoText("Gender", basicInfo['Gender']),
                  _infoText("Employee ID", basicInfo['EmployeeId']),

                  _sectionTitle("🏨 Hotel Info"),
                  _infoText("Hotel", hotelInfo['Hotel']),
                  _infoText("Address", hotelInfo['Address']),
                  _infoText("Contact", hotelInfo['Phone']),

                  _sectionTitle("💼 Job Info"),
                  _infoText("Position", jobInfo['Position']),
                  _infoText("Shift Timings", jobInfo['Shift']),
                  _infoText("Date of Joining", jobInfo['Joining']),
                  _infoText("Manager Name", jobInfo['Manager']),

                  _sectionTitle("🔥 Drill Info"),
                  _infoText("Modules Completed", drillInfo['Completed']),
                  _infoText("Last Drill Date", drillInfo['LastDate']),
                  _infoText("Safety Level", drillInfo['Level']),
                  _infoText("Emergency Role", drillInfo['Role']),

                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _calculateAge(Timestamp? dob) {
    if (dob == null) return 'N/A';
    final birth = dob.toDate();
    final today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age.toString();
  }

  Widget _infoText(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 8),
      child: Text.rich(
        TextSpan(
          text: "$label: ",
          style: const TextStyle(fontWeight: FontWeight.w600),
          children: [
            TextSpan(
              text: value?.toString() ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _errorPanel(String message) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFFDF0DC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(child: Text(message, style: const TextStyle(fontSize: 16))),
      ),
    );
  }
}
