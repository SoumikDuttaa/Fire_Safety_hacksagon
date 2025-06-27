import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'dart:typed_data';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = "Alex Firestorm";
  String gender = "Male";
  String age = "29";
  String phone = "+91-9876543210";
  String email = "alex.fire@example.com";
  String position = "Fire Safety Officer";
  String shift = "08:00 AM - 05:00 PM";
  String managerName = "John Blaze";
  String joiningDate = "10/06/2021";
  String hotel = "Ignite Inn";
  String location = "Mumbai";
  String modulesCompleted = "6/10";
  String lastDrill = "15/06/2024";
  String safetyLevel = "Level 2";
  String emergencyRole = "Evacuation Leader";

  Uint8List? profileImageBytes;
  bool isImageLoading = false;
  bool isManager = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 16.0 : 32.0;
    final sectionWidth = isMobile ? double.infinity : 500.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF1E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF1E1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
            child: SizedBox(
              width: sectionWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  const _SectionTitle("Basic Info", Icons.diamond, color: Colors.blue),
                  _InfoRow("Full Name", fullName),
                  _InfoRow("Age", age),
                  _InfoRow("Gender", gender),
                  _InfoRow("Employee ID", widget.userId),
                  const Divider(height: 32),
                  const _SectionTitle("Contact Info", Icons.contact_mail, color: Colors.teal),
                  _InfoRow("Email", email),
                  _InfoRow("Phone", phone),
                  const Divider(height: 32),
                  const _SectionTitle("Hotel Info", Icons.apartment, color: Colors.brown),
                  _InfoRow("Hotel", hotel),
                  _InfoRow("Location", location),
                  const Divider(height: 32),
                  const _SectionTitle("Job Info", Icons.badge, color: Colors.indigo),
                  _InfoRow("Position", position),
                  if (!isManager) _InfoRow("Shift Timings", shift),
                  _InfoRow("Date of Joining", joiningDate),
                  if (!isManager) _InfoRow("Manager Name", managerName),
                  const Divider(height: 32),
                  if (!isManager) ...[
                    const _SectionTitle("Drill Info", Icons.local_fire_department, color: Colors.red),
                    _InfoRow("Modules Completed", modulesCompleted),
                    _InfoRow("Last Drill Date", lastDrill),
                    _InfoRow("Fire Safety Level", safetyLevel),
                    _InfoRow("Emergency Role", emergencyRole),
                    const Divider(height: 32),
                  ],
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (_) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Logout", style: TextStyle(color: Colors.red)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5D6A8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                child: profileImageBytes != null
                    ? ClipOval(
                        child: Image.memory(profileImageBytes!, width: 60, height: 60, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.person, size: 30, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: $fullName", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Age: $age"),
                    Text("Position: $position"),
                    Text("Hotel Name: $hotel"),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black87),
                onPressed: () {
                  _showPlaceholderDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          BarcodeWidget(
            barcode: Barcode.code128(),
            data: widget.userId,
            width: 200,
            height: 50,
            drawText: false,
          ),
        ],
      ),
    );
  }

  void _showPlaceholderDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Profile"),
        content: const Text("EditStaffPage is not yet implemented."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.icon, {this.color = Colors.black});
  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          children: [TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.normal))],
        ),
      ),
    );
  }
}
