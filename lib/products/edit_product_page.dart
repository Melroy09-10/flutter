import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/product_model.dart';

class EditProductPage extends StatefulWidget {
  final ProductModel product;
  const EditProductPage(this.product, {super.key});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  final imageController = TextEditingController();

  late List<String> imageUrls;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.product.title);
    priceController =
        TextEditingController(text: widget.product.price.toString());
    stockController =
        TextEditingController(text: widget.product.stock.toString());
    imageUrls = List<String>.from(widget.product.imageUrls);
  }

  // ---------------- ADD IMAGE ----------------
  void addImage() {
    if (imageController.text.trim().isEmpty) return;

    setState(() {
      imageUrls.add(imageController.text.trim());
      imageController.clear();
    });
  }

  // ---------------- CONFIRM IMAGE DELETE ----------------
  void confirmDeleteImage(int index) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Image"),
          content: const Text("Are you sure you want to delete this image?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        imageUrls.removeAt(index);
      });
    }
  }

  // ---------------- CONFIRM UPDATE ----------------
  void confirmUpdateProduct() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Product"),
          content: const Text("Do you want to save the changes?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      updateProduct();
    }
  }

  // ---------------- UPDATE PRODUCT ----------------
  Future<void> updateProduct() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id)
        .update({
      'title': titleController.text.trim(),
      'price': double.parse(priceController.text),
      'stock': int.parse(stockController.text),
      'imageUrls': imageUrls,
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- BASIC INFO --------
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

            // -------- ADD IMAGE --------
            const Text(
              "Add New Image",
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

            const SizedBox(height: 20),

            // -------- IMAGE GRID --------
            const Text(
              "Product Images",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (imageUrls.isEmpty)
              const Text("No images added"),

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
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
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
                              Icons.delete,
                              size: 14,
                              color: Colors.white,
                            ),
                            onPressed: () =>
                                confirmDeleteImage(index),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: 30),

            // -------- UPDATE BUTTON --------
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : confirmUpdateProduct,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Product"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
