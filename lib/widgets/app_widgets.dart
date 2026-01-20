import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

InputDecoration appFieldStyle(
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

Widget appTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscure = false,
  Widget? suffix,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    decoration: appFieldStyle(label, icon, suffix: suffix),
  );
}


Widget appButton({
  required String text,
  required VoidCallback? onPressed,
  bool loading = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(text),
    ),
  );
}

Widget googleButton(VoidCallback onPressed) {
  return IconButton(
    iconSize: 30,
    icon: const FaIcon(
      FontAwesomeIcons.google,
      color: Colors.red,
    ),
    onPressed: onPressed,
  );
}


Widget authCard({required List<Widget> children}) {
  return Card(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    ),
  );
}

Widget appDrawerHeader(User? user) {
  return UserAccountsDrawerHeader(
    accountName: Text(user?.displayName ?? "User"),
    accountEmail: Text(user?.email ?? ""),
    currentAccountPicture: CircleAvatar(
      backgroundImage:
          user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
      child: user?.photoURL == null
          ? const Icon(Icons.person, size: 40)
          : null,
    ),
  );
}

Widget appDrawerItem({
  required IconData icon,
  required String title,
  Color? color,
  VoidCallback? onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(
      title,
      style: TextStyle(color: color),
    ),
    onTap: onTap,
  );
}

Widget priceText(dynamic price) {
  return Text(
    "₹ $price",
    style: const TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget imageDots({
  required int count,
  required int currentIndex,
}) {
  return Row(
    children: List.generate(
      count,
      (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: currentIndex == index ? 10 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: currentIndex == index
              ? Colors.white
              : Colors.white54,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    ),
  );
}
