import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  User? get user => FirebaseAuth.instance.currentUser;

  CollectionReference get _cartRef =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('cart');
  Future<void> loadCart() async {
    if (user == null) return;

    final snapshot = await _cartRef.get();
    _items.clear();

    for (var doc in snapshot.docs) {
      _items[doc.id] = CartItem(
        id: doc.id,
        title: doc['title'],
        price: (doc['price'] as num).toDouble(),
        image: doc['image'],
        quantity: doc['quantity'],
        stock: doc['stock'],
      );
    }

    notifyListeners();
  }

  Future<void> addItem(
    String productId,
    String title,
    double price,
    String image, {
    required int stock,
  }) async {
    if (user == null) return;

    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity >= stock) {
        return;
      }

      _items[productId]!.quantity++;

      await _cartRef.doc(productId).update({
        'quantity': _items[productId]!.quantity,
      });
    } else {
      if (stock <= 0) return;

      _items[productId] = CartItem(
        id: productId,
        title: title,
        price: price,
        image: image,
        quantity: 1,
        stock: stock,
      );

      await _cartRef.doc(productId).set({
        'title': title,
        'price': price,
        'image': image,
        'quantity': 1,
        'stock': stock,
      });
    }

    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    if (user == null || !_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;

      await _cartRef.doc(productId).update({
        'quantity': _items[productId]!.quantity,
      });
    } else {
      _items.remove(productId);
      await _cartRef.doc(productId).delete();
    }

    notifyListeners();
  }

  double get totalAmount {
    double total = 0;
    for (var item in _items.values) {
      total += item.price * item.quantity;
    }
    return total;
  }

  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  Future<void> clearCart() async {
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final docs = await _cartRef.get();

    for (var doc in docs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    _items.clear();
    notifyListeners();
  }
}
