import 'package:flutter/material.dart';

class PaymentResultScreen extends StatelessWidget {
  final bool success;

  const PaymentResultScreen({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Result')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline, 
              color: success ? Colors.green : Colors.red, 
              size: 80
            ),
            const SizedBox(height: 24),
            Text(
              success ? 'Payment Successful!' : 'Payment Failed', 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: success ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              success 
                ? 'Your order has been processed successfully.'
                : 'Please try again or contact support.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Close', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
