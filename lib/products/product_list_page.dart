import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_product_page.dart';
import 'edit_product_page.dart';
import 'models/product_model.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  Future<void> confirmDeleteProduct(
      BuildContext context, String productId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content:
              const Text("Are you sure you want to delete this product?"),
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
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product deleted")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddProductPage(),
                ),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // 🔒 SAFE FIELD READING (NO CRASH)
              final String title =
                  (data['title'] ?? data['name'] ?? '').toString();

              final double price =
                  (data['price'] as num?)?.toDouble() ?? 0.0;

              final int stock =
                  (data['stock'] as num?)?.toInt() ?? 0;

              final List<String> imageUrls =
                  List<String>.from(
                    data['imageUrls'] ??
                        data['images'] ??
                        [],
                  );

              final product = ProductModel(
                id: doc.id,
                title: title,
                price: price,
                stock: stock,
                imageUrls: imageUrls,
              );

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: imageUrls.isNotEmpty
                        ? Image.network(
                            imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.image_not_supported),
                  ),
                  title: Text(
                    product.title.isNotEmpty
                        ? product.title
                        : "Unnamed Product",
                  ),
                  subtitle: Text(
                    "₹${product.price} | Stock: ${product.stock}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProductPage(product),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            confirmDeleteProduct(context, product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
