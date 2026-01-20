import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/profile_widgets.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  bool loading = false;

  late TextEditingController nameController;
  late TextEditingController phoneController;

  late TextEditingController houseController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController pincodeController;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: user.displayName ?? "");
    phoneController = TextEditingController();

    houseController = TextEditingController();
    streetController = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    pincodeController = TextEditingController();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    phoneController.text = data['phone'] ?? '';

    final address = data['address'] ?? {};
    houseController.text = address['houseNo'] ?? '';
    streetController.text = address['street'] ?? '';
    cityController.text = address['city'] ?? '';
    stateController.text = address['state'] ?? '';
    pincodeController.text = address['pincode'] ?? '';
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    await user.updateDisplayName(nameController.text.trim());
    await user.reload();


    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'name': nameController.text.trim(),
      'email': user.email,
      'phone': phoneController.text.trim(),
      'address': {
        'houseNo': houseController.text.trim(),
        'street': streetController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'pincode': pincodeController.text.trim(),
      },
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileSectionTitle("Basic Information"),

              profileTextField(
                controller: nameController,
                label: "Full Name",
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? "Name is required"
                        : null,
              ),
              const SizedBox(height: 16),

              profileTextField(
                controller: phoneController,
                label: "Phone Number",
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Phone number is required";
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                    return "Enter a valid 10-digit phone number";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              profileSectionTitle("Address"),

              profileTextField(
                controller: houseController,
                label: "House / Building No",
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? "House number is required"
                        : null,
              ),
              const SizedBox(height: 12),

              profileTextField(
                controller: streetController,
                label: "Street / Area",
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? "Street is required"
                        : null,
              ),
              const SizedBox(height: 12),

              profileTextField(
                controller: cityController,
                label: "City",
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? "City is required"
                        : null,
              ),
              const SizedBox(height: 12),

              profileTextField(
                controller: stateController,
                label: "State",
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? "State is required"
                        : null,
              ),
              const SizedBox(height: 12),

              profileTextField(
                controller: pincodeController,
                label: "Pincode",
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Pincode is required";
                  }
                  if (!RegExp(r'^[0-9]{6}$').hasMatch(v)) {
                    return "Enter a valid 6-digit pincode";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              profileSaveButton(
                text: "Save Changes",
                loading: loading,
                onPressed: loading ? null : updateProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
