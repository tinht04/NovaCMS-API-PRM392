import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const Text('Payment flow placeholder'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () {}, child: const Text('Pay')),
        ]),
      ),
    );
  }
}
