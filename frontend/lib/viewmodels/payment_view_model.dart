import 'package:flutter/material.dart';
import 'package:nova_mobile/repositories/payment_repository.dart';
import 'package:nova_mobile/core/network/exceptions.dart';
import 'package:dio/dio.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentRepository _repo;

  PaymentViewModel([PaymentRepository? repo]) : _repo = repo ?? PaymentRepository();

  bool _loading = false;
  String? _error;
  String? _paymentUrl;

  bool get loading => _loading;
  String? get error => _error;
  String? get paymentUrl => _paymentUrl;

  Future<void> createPayment({required double amount, String name = '', String description = '', String orderType = 'other'}) async {
    _loading = true;
    _error = null;
    _paymentUrl = null;
    notifyListeners();

    try {
      final payload = {
        'OrderType': orderType,
        'Amount': amount,
        'OrderDescription': description,
        'Name': name,
      };
      final url = await _repo.createPaymentUrl(payload);
      _paymentUrl = url;
    } on ApiException catch (e) {
      _error = e.message;
    } on DioException catch (d) {
      final err = d.error;
      if (err is ApiException) {
        _error = err.message;
      } else {
        _error = d.message ?? d.toString();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
