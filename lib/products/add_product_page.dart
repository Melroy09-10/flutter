import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/product_model.dart';

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

  void addImage() {
    if (imageController.text.isEmpty) return;

    imageUrls.add(imageController.text.trim());
    imageController.clear();
    setState(() {});
  }

  Future<void> addProduct() async {
    if (titleController.text.isEmpty ||
        priceController.text.isEmpty ||
        stockController.text.isEmpty ||
        imageUrls.isEmpty) {
      showMsg("Fill all fields and add at least one image");
      return;
    }

    setState(() => loading = true);

    final product = ProductModel(
      id: '',
      title: titleController.text.trim(),
      price: double.parse(priceController.text),
      stock: int.parse(stockController.text),
      imageUrls: imageUrls,
    );

    await FirebaseFirestore.instance
        .collection('products')
        .add(product.toMap());

    showMsg("Product added successfully");

    titleController.clear();
    priceController.clear();
    stockController.clear();
    imageController.clear();
    imageUrls.clear();

    setState(() => loading = false);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

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

            // -------- IMAGE PREVIEW GRID --------
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

                          // 🔥 IMPORTANT FOR WEB (CORS-safe)
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

            // -------- ADD PRODUCT BUTTON --------
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
