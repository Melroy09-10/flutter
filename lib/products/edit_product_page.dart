import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './widgets/form_widgets.dart';
import 'models/product_model.dart';

class EditProductPage extends StatefulWidget {
  final ProductModel product;
  const EditProductPage(this.product, {super.key});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

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

  void addImage() {
    final url = imageController.text.trim();
    if (url.isEmpty) {
      showMsg("Image URL cannot be empty");
      return;
    }

    setState(() {
      imageUrls.add(url);
      imageController.clear();
    });
  }

  void confirmDeleteImage(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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
      ),
    );

    if (confirm == true) {
      setState(() {
        imageUrls.removeAt(index);
      });
    }
  }

  void confirmUpdateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (imageUrls.isEmpty) {
      showMsg("Please add at least one product image");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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
      ),
    );

    if (confirm == true) {
      updateProduct();
    }
  }

  Future<void> updateProduct() async {
    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id)
        .update({
      'title': titleController.text.trim(),
      'price': double.parse(priceController.text.trim()),
      'stock': int.parse(stockController.text.trim()),
      'imageUrls': imageUrls,
    });

    if (mounted) Navigator.pop(context);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              appTextFormField(
                controller: titleController,
                label: "Product Title",
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? "Product title is required"
                        : null,
              ),
              const SizedBox(height: 12),

              appTextFormField(
                controller: priceController,
                label: "Price",
                keyboardType: TextInputType.number,
                validator: (v) {
                  final price = double.tryParse(v ?? "");
                  if (price == null || price <= 0) {
                    return "Enter a valid price (> 0)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              appTextFormField(
                controller: stockController,
                label: "Stock",
                keyboardType: TextInputType.number,
                validator: (v) {
                  final stock = int.tryParse(v ?? "");
                  if (stock == null || stock < 0) {
                    return "Stock must be 0 or more";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 6),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: stockController,
                builder: (context, value, _) {
                  final stock = int.tryParse(value.text) ?? 0;
                  return stockStatus(stock);
                },
              ),

              const SizedBox(height: 24),

              sectionTitle("Add New Image"),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: "Image URL",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: addImage,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              sectionTitle("Product Images"),
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

              appPrimaryButton(
                text: "Update Product",
                loading: loading,
                onPressed: loading ? null : confirmUpdateProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
