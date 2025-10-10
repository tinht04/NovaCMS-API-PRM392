import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Your cart is empty'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/payment'), child: const Text('Checkout')),
        ]),
      ),
    );
  }
}
