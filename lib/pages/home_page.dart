import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../auth/google_signin_service.dart';
import '../cart/cart_provider.dart';
import '../products/product_list_page.dart';
import '../products/widgets/product_card.dart';
import '../widgets/app_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> logout(BuildContext context) async {
    Provider.of<CartProvider>(context, listen: false).clearCart();
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            appDrawerHeader(user),

            appDrawerItem(
              icon: Icons.shopping_bag,
              title: "Products",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductListPage(),
                  ),
                );
              },
            ),

            const Spacer(),
            const Divider(),

            appDrawerItem(
              icon: Icons.logout,
              title: "Logout",
              color: Colors.red,
              onTap: () => logout(context),
            ),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.45,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final raw = docs[index].data() as Map<String, dynamic>;

              // ✅ FULL NORMALIZATION (THIS FIXES EVERYTHING)
              final List<String> images = List<String>.from(
                raw['imageUrls'] ?? raw['images'] ?? [],
              );

              final Map<String, dynamic> normalizedData = {
                'title': raw['title'] ?? raw['name'] ?? '',
                'price': raw['price'] ?? 0,
                'stock': raw['stock'] ?? 0,
                'imageUrls': images, // 🔑 SINGLE SOURCE OF TRUTH
              };

              return ProductCard(
                productId: docs[index].id,
                data: normalizedData,
              );
            },
          );
        },
      ),
    );
  }
}
