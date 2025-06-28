import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddStaffPage extends StatefulWidget {
  final Function onSubmit;
  final String managerUid;

  const AddStaffPage({super.key, required this.onSubmit, required this.managerUid});

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final _formKey = GlobalKey<FormState>();

  String fullName = '';
  String gender = 'Male';
  DateTime? dob;

  String email = '';
  String phone = '';

  String hotel = '';
  String location = '';

  DateTime? joiningDate;
  String managerName = '';
  String position = 'Security';
  String shift = 'Morning';

  bool isActive = true;

  File? _selectedImage;
  String? _base64Image;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchManagerData();
  }

  Future<void> _fetchManagerData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.managerUid)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          managerName = data['Basic_Info']['FullName'] ?? '';
          hotel = data['Hotel_Info']['Hotel'] ?? '';
          location = data['Hotel_Info']['Location'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching manager info: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImage = File(picked.path);
        _base64Image = base64Encode(bytes);
      });
    }
  }

Future<void> _submit() async {
  if (!_formKey.currentState!.validate() || dob == null || joiningDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all required fields")),
    );
    return;
  }

  _formKey.currentState!.save();
  setState(() => isLoading = true);

  try {
    final tempPassword = "Temp@123";

    // 1. Create user
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: tempPassword);
    final user = userCredential.user!;

    // ✅ 2. Update display name in Firebase Auth
    await user.updateDisplayName(fullName);

    // 3. Save to Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'Basic_Info': {
        'FullName': fullName,
        'Gender': gender,
        'Age': Timestamp.fromDate(dob!),
      },
      'Contacts': {
        'Email': email,
        'Phone': phone,
      },
      'Hotel_Info': {
        'Hotel': hotel,
        'Location': location,
        'Image': '/profileImages/${user.uid}.jpg',
      },
      'Job_Info': {
        'ManagerName': managerName,
        'Position': position,
        'Shift': shift,
        'Joining': Timestamp.fromDate(joiningDate!),
      },
      'role': 'user',
      'isactive': isActive,
      'email': email,
      'uid': user.uid,
      'createdBy': widget.managerUid,
      'profile': _base64Image ?? '',
    });

    // 4. Update manager staff count
    await FirebaseFirestore.instance.collection('users').doc(widget.managerUid).update({
      'staffcount': FieldValue.increment(1),
    });

    // ✅ 5. Send password reset email
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    widget.onSubmit(null);
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }

  setState(() => isLoading = false);
}

  Future<void> _pickDate(bool isDob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isDob) {
          dob = picked;
        } else {
          joiningDate = picked;
        }
      });
    }
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 6),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Staff"),
        backgroundColor: Colors.deepOrange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Basic Info"),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      onSaved: (val) => fullName = val!.trim(),
                      validator: (val) => val!.isEmpty ? 'Required' : null,
                    ),
                    DropdownButtonFormField(
                      value: gender,
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) => setState(() => gender = val!),
                      decoration: const InputDecoration(labelText: 'Gender'),
                    ),
                    TextButton.icon(
                      onPressed: () => _pickDate(true),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        dob == null ? "Pick DOB" : "DOB: ${dob!.day}/${dob!.month}/${dob!.year}",
                      ),
                    ),

                    _sectionTitle("Contact Info"),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (val) => email = val!,
                      validator: (val) => val!.contains('@') ? null : 'Invalid email',
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                      onSaved: (val) => phone = val!,
                      validator: (val) => val!.length >= 10 ? null : 'Invalid phone',
                    ),

                    _sectionTitle("Job Info"),
                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(labelText: 'Manager Name', hintText: managerName),
                    ),
                    DropdownButtonFormField(
                      value: position,
                      items: [
                        'Security',
                        'Cleaner',
                        'Housekeeping',
                        'Receptionist',
                        'Kitchen Staff',
                        'Electrician',
                        'Maintenance',
                        'Guard'
                      ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) => setState(() => position = val!),
                      decoration: const InputDecoration(labelText: 'Position'),
                    ),
                    DropdownButtonFormField(
                      value: shift,
                      items: ['Morning', 'Evening', 'Night']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => shift = val!),
                      decoration: const InputDecoration(labelText: 'Shift'),
                    ),
                    TextButton.icon(
                      onPressed: () => _pickDate(false),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        joiningDate == null
                            ? "Pick Joining Date"
                            : "Joining: ${joiningDate!.day}/${joiningDate!.month}/${joiningDate!.year}",
                      ),
                    ),

                    _sectionTitle("Profile Image"),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade400,
                        child: _base64Image != null
                            ? ClipOval(
                                child: Image.memory(
                                  base64Decode(_base64Image!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.add_a_photo, size: 30, color: Colors.white),
                      ),
                    ),

                    _sectionTitle("Active Status"),
                    SwitchListTile(
                      title: const Text("Is Active"),
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text("Create Staff"),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}