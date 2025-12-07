import 'package:flutter/material.dart';
import '../models/kamar_model.dart';
import '../services/kamar_service.dart';

class KamarProvider with ChangeNotifier {
  final KamarService _kamarService = KamarService();

  List<Kamar> _kamars = [];
  Kamar? _selectedKamar;
  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  List<Kamar> get kamars => _kamars;
  Kamar? get selectedKamar => _selectedKamar;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get all kamar
  Future<void> fetchKamars({String? status, String? tipe}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kamars = await _kamarService.getAllKamar(status: status, tipe: tipe);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get kamar by ID
  Future<void> fetchKamarById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedKamar = await _kamarService.getKamarById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create kamar
  Future<bool> createKamar({
    required String nomorKamar,
    required String tipe,
    required double hargaBulanan,
    required String status,
    String? fasilitas,
    int? userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _kamarService.createKamar(
        nomorKamar: nomorKamar,
        tipe: tipe,
        hargaBulanan: hargaBulanan,
        status: status,
        fasilitas: fasilitas,
        userId: userId,
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

  // Update kamar
  Future<bool> updateKamar({
    required int id,
    String? nomorKamar,
    String? tipe,
    double? hargaBulanan,
    String? status,
    String? fasilitas,
    int? userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _kamarService.updateKamar(
        id: id,
        nomorKamar: nomorKamar,
        tipe: tipe,
        hargaBulanan: hargaBulanan,
        status: status,
        fasilitas: fasilitas,
        userId: userId,
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

  // Delete kamar
  Future<bool> deleteKamar(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _kamarService.deleteKamar(id);
      _kamars.removeWhere((k) => k.id == id);
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

  // Get statistics
  Future<void> fetchStatistics() async {
    try {
      _statistics = await _kamarService.getStatistics();
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

  // Filter kamars locally
  List<Kamar> filterKamars({String? status, String? tipe}) {
    return _kamars.where((kamar) {
      bool matchStatus = status == null || kamar.status == status;
      bool matchTipe = tipe == null || kamar.tipe == tipe;
      return matchStatus && matchTipe;
    }).toList();
  }
}