import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Dismissible(
                  key: ValueKey(item.product.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    cart.removeItem(item.product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.product.title} removed from cart'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: item.product.image != null
                        ? Image.network(
                            item.product.image!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey,
                            child: const Icon(Icons.image, color: Colors.white),
                          ),
                    title: Text(item.product.title),
                    subtitle: Text('\$${item.product.price.toStringAsFixed(2)}'),
                    trailing: Text('x${item.quantity}'),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: cart.items.isEmpty
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Checkout functionality not implemented yet'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
          child: Text('Checkout (\$${cart.totalPrice.toStringAsFixed(2)})'),
        ),
      ),
    );
  }
}