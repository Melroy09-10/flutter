import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

      Navigator.pop(context); // 🔥 back to login
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

      Navigator.pop(context); // 🔥 back to login
    } catch (_) {
      showMsg("Google sign-up failed");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration fieldStyle(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 🔥 back to login
        ),
        title: const Text("Register"),
      ),
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        fieldStyle("Name", Icons.person_outline),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: emailController,
                    decoration:
                        fieldStyle("Email", Icons.email_outlined),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: fieldStyle(
                      "Password",
                      Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : registerUser,
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Register"),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 🔹 GOOGLE ICON
                  IconButton(
                    iconSize: 30,
                    
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.red,
                    ),
                    onPressed: googleRegister,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
