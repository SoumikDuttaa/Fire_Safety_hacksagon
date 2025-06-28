import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditStaffPage extends StatefulWidget {
  final String staffId;

  const EditStaffPage({super.key, required this.staffId});

  @override
  State<EditStaffPage> createState() => _EditStaffPageState();
}

class _EditStaffPageState extends State<EditStaffPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController locationController;

  Uint8List? profileImageBytes;
  String? base64Image;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStaffData();
  }

  Future<void> fetchStaffData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.staffId).get();
    final data = doc.data()!;
    final basic = data['Basic_Info'];
    final contacts = data['Contacts'];
    final hotel = data['Hotel_Info'];

    fullNameController = TextEditingController(text: basic['FullName'] ?? '');
    phoneController = TextEditingController(text: contacts['Phone']?.toString() ?? '');
    locationController = TextEditingController(text: hotel['Location'] ?? '');

    if (data['profile'] != null && data['profile'] != '') {
      final raw = base64Decode(data['profile']);
      profileImageBytes = raw;
      base64Image = data['profile'];
    }

    setState(() => isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        profileImageBytes = bytes;
        base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.staffId).update({
        'Basic_Info.FullName': fullNameController.text,
        'Contacts.Phone': phoneController.text,
        'Hotel_Info.Location': locationController.text,
        'profile': base64Image ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Staff Profile"),
        backgroundColor: Colors.deepOrange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: profileImageBytes != null ? MemoryImage(profileImageBytes!) : null,
                        child: profileImageBytes == null
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(fullNameController, "Full Name"),
                    _buildTextField(phoneController, "Phone Number", TextInputType.phone),
                    _buildTextField(locationController, "Location"),

                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text("Save Changes"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}