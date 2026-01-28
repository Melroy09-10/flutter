import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/notification_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final imageController = TextEditingController();

  final List<String> imageUrls = [];
  bool loading = false;

  // ---------------- ADD IMAGE ----------------
  void addImage() {
    if (imageController.text.trim().isEmpty) return;

    imageUrls.add(imageController.text.trim());
    imageController.clear();
    setState(() {});
  }

  // ---------------- ADD PRODUCT ----------------
  Future<void> addProduct() async {
    if (titleController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        stockController.text.trim().isEmpty ||
        imageUrls.isEmpty) {
      showMsg("Fill all fields and add at least one image");
      return;
    }

    setState(() => loading = true);

    try {
      final String productName = titleController.text.trim();
      final double price = double.parse(priceController.text.trim());
      final int stock = int.parse(stockController.text.trim());
      final String productImageUrl = imageUrls.first;

      // 🔥 SAVE PRODUCT TO FIRESTORE
      await FirebaseFirestore.instance.collection('products').add({
        'name': productName,
        'price': price,
        'stock': stock,
        'images': imageUrls,
        'createdAt': Timestamp.now(),
      });

      // 🔔 SEND NOTIFICATION
      await NotificationService.sendNewProductNotification(
        productName: productName,
        productImageUrl: productImageUrl,
      );

      showMsg("Product added successfully");

      // 🔄 CLEAR FORM
      titleController.clear();
      priceController.clear();
      stockController.clear();
      imageUrls.clear();

      setState(() {});
    } catch (e) {
      showMsg("Error adding product");
      debugPrint(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  // ---------------- MESSAGE ----------------
  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- PRODUCT DETAILS --------
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Product Title"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stock"),
            ),

            const SizedBox(height: 20),

            // -------- IMAGE INPUT --------
            const Text(
              "Product Images",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: imageController,
                    decoration:
                        const InputDecoration(labelText: "Image URL"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addImage,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // -------- IMAGE PREVIEW --------
            if (imageUrls.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: imageUrls.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                imageUrls.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: 25),

            // -------- ADD BUTTON --------
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : addProduct,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Product"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
