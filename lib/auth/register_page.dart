import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/app_widgets.dart';
import 'google_signin_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------- EMAIL REGISTER ----------------
  Future<void> registerUser() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showMsg("Please fill all fields");
      return;
    }

    setState(() => loading = true);

    try {
      UserCredential user =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _firestore.collection("users").doc(user.user!.uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "role": "user",
        "createdAt": Timestamp.now(),
      });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = "Registration failed";

      if (e.code == 'email-already-in-use') {
        msg = "Email already registered";
      } else if (e.code == 'weak-password') {
        msg = "Password is too weak";
      } else if (e.code == 'invalid-email') {
        msg = "Please enter a valid email";
      }

      showMsg(msg);
    } catch (_) {
      showMsg("Something went wrong");
    }

    setState(() => loading = false);
  }

  // ---------------- GOOGLE REGISTER ----------------
  Future<void> googleRegister() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential user =
          await _auth.signInWithCredential(credential);

      await _firestore.collection("users").doc(user.user!.uid).set(
        {
          "name": user.user!.displayName ?? "",
          "email": user.user!.email ?? "",
          "role": "user",
          "createdAt": Timestamp.now(),
        },
        SetOptions(merge: true),
      );

      Navigator.pop(context);
    } catch (_) {
      showMsg("Google sign-up failed");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: authCard(
            children: [
              appTextField(
                controller: nameController,
                label: "Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 15),

              appTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 15),

              appTextField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                obscure: hidePassword,
                suffix: IconButton(
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => hidePassword = !hidePassword),
                ),
              ),
              const SizedBox(height: 25),

              appButton(
                text: "Register",
                loading: loading,
                onPressed: registerUser,
              ),
              const SizedBox(height: 18),

              googleButton(googleRegister),
            ],
          ),
        ),
      ),
    );
  }
}
