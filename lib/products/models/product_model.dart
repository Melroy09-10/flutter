import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final double price;
  final int stock;
  final List<String> imageUrls;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.stock,
    required this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'stock': stock,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.now(),
    };
  }
}
