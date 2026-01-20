import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cart/cart_provider.dart';
import '../../widgets/app_widgets.dart';

class ProductCard extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> data;

  const ProductCard({
    super.key,
    required this.productId,
    required this.data,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List images = widget.data['imageUrls'] ?? [];
    final int stock = widget.data['stock'] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  },
                ),

                if (images.length > 1)
                  Positioned(
                    bottom: 6,
                    child: imageDots(
                      count: images.length,
                      currentIndex: currentIndex,
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE + PRICE
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data['title'] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      priceText(widget.data['price']),
                      const SizedBox(height: 2),
                      Text(
                        stock > 0
                            ? "Stock: $stock"
                            : "Out of stock",
                        style: TextStyle(
                          fontSize: 12,
                          color: stock > 0
                              ? Colors.grey
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),

                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      final qty =
                          cart.getQuantity(widget.productId);

                      if (qty == 0) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: stock == 0
                                ? null
                                : () {
                                    cart.addItem(
                                      widget.productId,
                                      widget.data['title'],
                                      (widget.data['price']
                                              as num)
                                          .toDouble(),
                                      images.isNotEmpty
                                          ? images[0]
                                          : '',
                                      stock: stock,
                                    );
                                  },
                            child: const Text("Add to Cart"),
                          ),
                        );
                      }

                      return Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              cart.removeItem(
                                  widget.productId);
                            },
                          ),
                          Text(
                            qty.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: qty >= stock
                                ? null
                                : () {
                                    cart.addItem(
                                      widget.productId,
                                      widget.data['title'],
                                      (widget.data['price']
                                              as num)
                                          .toDouble(),
                                      images.isNotEmpty
                                          ? images[0]
                                          : '',
                                      stock: stock,
                                    );
                                  },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
