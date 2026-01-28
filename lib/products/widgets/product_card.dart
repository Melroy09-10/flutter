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
    // ✅ DATA IS GUARANTEED CLEAN
    final List images = widget.data['imageUrls'];
    final String title = widget.data['title'];
    final int stock = widget.data['stock'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // IMAGE SLIDER
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (i) =>
                      setState(() => currentIndex = i),
                  itemBuilder: (_, i) {
                    return ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      child: Image.network(
                        images[i],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
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

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),
                priceText(widget.data['price']),
                const SizedBox(height: 4),

                Text(
                  stock > 0 ? "Stock: $stock" : "Out of stock",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        stock > 0 ? Colors.grey : Colors.red,
                  ),
                ),

                const SizedBox(height: 10),

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
                                    title,
                                    (widget.data['price']
                                            as num)
                                        .toDouble(),
                                    images[0],
                                    stock: stock,
                                  );
                                },
                          child:
                              const Text("Add to Cart"),
                        ),
                      );
                    }

                    return Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.remove),
                          onPressed: () =>
                              cart.removeItem(
                                  widget.productId),
                        ),
                        Text(qty.toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: qty >= stock
                              ? null
                              : () {
                                  cart.addItem(
                                    widget.productId,
                                    title,
                                    (widget.data['price']
                                            as num)
                                        .toDouble(),
                                    images[0],
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
        ],
      ),
    );
  }
}
