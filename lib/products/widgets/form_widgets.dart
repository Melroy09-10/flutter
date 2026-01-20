import 'package:flutter/material.dart';

Widget appTextFormField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

Widget sectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    ),
  );
}

Widget appPrimaryButton({
  required String text,
  required VoidCallback? onPressed,
  bool loading = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: onPressed,
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(text),
    ),
  );
}

Widget stockStatus(int stock) {
  return Text(
    stock == 0 ? "Out of stock" : "Stock: $stock",
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: stock == 0 ? Colors.red : Colors.grey[700],
    ),
  );
}
