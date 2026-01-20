import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    if (cart.items.isEmpty) {
      return const Center(child: Text("Cart is empty"));
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: cart.items.values.map((item) {
              return ListTile(
                leading: Image.network(item.image, width: 50),
                title: Text(item.title),
                subtitle: Text(
                    "₹ ${item.price} × ${item.quantity}"),
                trailing: Text(
                    "₹ ${item.price * item.quantity}"),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Total: ₹ ${cart.totalAmount}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
