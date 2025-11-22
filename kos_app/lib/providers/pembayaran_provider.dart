// lib/providers/pembayaran_provider.dart

import 'package:flutter/material.dart';
import '../models/pembayaran_model.dart';
import '../services/pembayaran_service.dart';

class PembayaranProvider with ChangeNotifier {
  final PembayaranService _pembayaranService = PembayaranService();

  List<Pembayaran> _pembayarans = [];
  Pembayaran? _selectedPembayaran;
  Map<String, dynamic>? _laporan;
  bool _isLoading = false;
  String? _errorMessage;

  List<Pembayaran> get pembayarans => _pembayarans;
  Pembayaran? get selectedPembayaran => _selectedPembayaran;
  Map<String, dynamic>? get laporan => _laporan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get all pembayaran
  Future<void> fetchPembayarans({
    String? status,
    int? bulan,
    int? tahun,
    int? kamarId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pembayarans = await _pembayaranService.getAllPembayaran(
        status: status,
        bulan: bulan,
        tahun: tahun,
        kamarId: kamarId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get pembayaran by ID
  Future<void> fetchPembayaranById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPembayaran = await _pembayaranService.getPembayaranById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create pembayaran
  Future<bool> createPembayaran({
    required int kamarId,
    required int userId,
    required int bulanPembayaran,
    required int tahunPembayaran,
    required String tanggalBayar,
    required double jumlah,
    required String status,
    String? buktiBayar,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _pembayaranService.createPembayaran(
        kamarId: kamarId,
        userId: userId,
        bulanPembayaran: bulanPembayaran,
        tahunPembayaran: tahunPembayaran,
        tanggalBayar: tanggalBayar,
        jumlah: jumlah,
        status: status,
        buktiBayar: buktiBayar,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update pembayaran
  Future<bool> updatePembayaran({
    required int id,
    int? kamarId,
    int? userId,
    int? bulanPembayaran,
    int? tahunPembayaran,
    String? tanggalBayar,
    double? jumlah,
    String? status,
    String? buktiBayar,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _pembayaranService.updatePembayaran(
        id: id,
        kamarId: kamarId,
        userId: userId,
        bulanPembayaran: bulanPembayaran,
        tahunPembayaran: tahunPembayaran,
        tanggalBayar: tanggalBayar,
        jumlah: jumlah,
        status: status,
        buktiBayar: buktiBayar,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete pembayaran
  Future<bool> deletePembayaran(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _pembayaranService.deletePembayaran(id);
      _pembayarans.removeWhere((p) => p.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get laporan
  Future<void> fetchLaporan({
    required int bulan,
    required int tahun,
  }) async {
    try {
      _laporan = await _pembayaranService.getLaporan(
        bulan: bulan,
        tahun: tahun,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Filter pembayarans locally
  List<Pembayaran> filterPembayarans({String? status}) {
    return _pembayarans.where((pembayaran) {
      bool matchStatus = status == null || pembayaran.status == status;
      return matchStatus;
    }).toList();
  }
}