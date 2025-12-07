import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/pembayaran_model.dart';
import 'api_service.dart';

class PembayaranService {
  final ApiService _apiService = ApiService();

  // Get all pembayaran
  Future<List<Pembayaran>> getAllPembayaran({
    String? status,
    int? bulan,
    int? tahun,
    int? kamarId,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (bulan != null) queryParams['bulan'] = bulan;
      if (tahun != null) queryParams['tahun'] = tahun;
      if (kamarId != null) queryParams['kamar_id'] = kamarId;

      final response = await _apiService.dio.get(
        AppConfig.pembayaranEndpoint,
        queryParameters: queryParams,
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        final List<dynamic> pembayarans = data['data'];
        return pembayarans.map((json) => Pembayaran.fromJson(json)).toList();
      }
      
      throw Exception('Gagal mengambil data pembayaran');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Get pembayaran by ID
  Future<Pembayaran> getPembayaranById(int id) async {
    try {
      final response = await _apiService.dio.get(
        '${AppConfig.pembayaranEndpoint}/$id',
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return Pembayaran.fromJson(data['data']);
      }
      
      throw Exception('Gagal mengambil detail pembayaran');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Get pembayaran by kamar ID
  Future<List<Pembayaran>> getPembayaranByKamar(int kamarId) async {
    try {
      final response = await _apiService.dio.get(
        '${AppConfig.pembayaranByKamarEndpoint}/$kamarId',
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        final List<dynamic> pembayarans = data['data'];
        return pembayarans.map((json) => Pembayaran.fromJson(json)).toList();
      }
      
      throw Exception('Gagal mengambil riwayat pembayaran kamar');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Create pembayaran
  Future<Pembayaran> createPembayaran({
    required int kamarId,
    required int userId,
    required int bulanPembayaran,
    required int tahunPembayaran,
    required String tanggalBayar,
    required double jumlah,
    required String status,
    String? buktiBayar,
  }) async {
    try {
      final response = await _apiService.dio.post(
        AppConfig.pembayaranEndpoint,
        data: {
          'kamar_id': kamarId,
          'user_id': userId,
          'bulan_pembayaran': bulanPembayaran,
          'tahun_pembayaran': tahunPembayaran,
          'tanggal_bayar': tanggalBayar,
          'jumlah': jumlah,
          'status': status,
          'bukti_bayar': buktiBayar,
        },
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return Pembayaran.fromJson(data['data']);
      }
      
      throw Exception(data['message'] ?? 'Gagal mencatat pembayaran');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Update pembayaran
  Future<Pembayaran> updatePembayaran({
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
    try {
      Map<String, dynamic> updateData = {};
      if (kamarId != null) updateData['kamar_id'] = kamarId;
      if (userId != null) updateData['user_id'] = userId;
      if (bulanPembayaran != null) updateData['bulan_pembayaran'] = bulanPembayaran;
      if (tahunPembayaran != null) updateData['tahun_pembayaran'] = tahunPembayaran;
      if (tanggalBayar != null) updateData['tanggal_bayar'] = tanggalBayar;
      if (jumlah != null) updateData['jumlah'] = jumlah;
      if (status != null) updateData['status'] = status;
      if (buktiBayar != null) updateData['bukti_bayar'] = buktiBayar;

      final response = await _apiService.dio.put(
        '${AppConfig.pembayaranEndpoint}/$id',
        data: updateData,
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return Pembayaran.fromJson(data['data']);
      }
      
      throw Exception(data['message'] ?? 'Gagal update pembayaran');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Delete pembayaran
  Future<void> deletePembayaran(int id) async {
    try {
      final response = await _apiService.dio.delete(
        '${AppConfig.pembayaranEndpoint}/$id',
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Gagal menghapus pembayaran');
      }
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Get laporan
  Future<Map<String, dynamic>> getLaporan({
    required int bulan,
    required int tahun,
  }) async {
    try {
      final response = await _apiService.dio.get(
        AppConfig.pembayaranLaporanEndpoint,
        queryParameters: {
          'bulan': bulan,
          'tahun': tahun,
        },
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return data['data'];
      }
      
      throw Exception('Gagal mengambil laporan');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }
}