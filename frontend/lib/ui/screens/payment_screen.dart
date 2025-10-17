import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nova_mobile/viewmodels/payment_view_model.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _amountCtrl = TextEditingController(text: '100000');
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _vm = PaymentViewModel();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open payment url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: _vm,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create payment (VnPay)'),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (VND)'),
                ),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Payer name'),
                ),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                if (_vm.error != null) ...[
                  Text('Error: ${_vm.error}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                _vm.loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0.0;
                          await _vm.createPayment(amount: amount, name: _nameCtrl.text, description: _descCtrl.text);
                          if (_vm.paymentUrl != null) {
                            await _launchUrl(_vm.paymentUrl!);
                          }
                        },
                        child: const Text('Pay'),
                      ),
                const SizedBox(height: 12),
                if (_vm.paymentUrl != null) ...[
                  const Text('Payment URL:'),
                  SelectableText(_vm.paymentUrl!),
                ]
              ],
            );
          },
        ),
      ),
    );
  }
}
