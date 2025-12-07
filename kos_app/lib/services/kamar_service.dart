import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/kamar_model.dart';
import 'api_service.dart';

class KamarService {
  final ApiService _apiService = ApiService();

  // Get all kamar
  Future<List<Kamar>> getAllKamar({String? status, String? tipe}) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (tipe != null) queryParams['tipe'] = tipe;

      final response = await _apiService.dio.get(
        AppConfig.kamarEndpoint,
        queryParameters: queryParams,
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        final List<dynamic> kamars = data['data'];
        return kamars.map((json) => Kamar.fromJson(json)).toList();
      }
      
      throw Exception('Gagal mengambil data kamar');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Get kamar by ID
  Future<Kamar> getKamarById(int id) async {
    try {
      final response = await _apiService.dio.get(
        '${AppConfig.kamarEndpoint}/$id',
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return Kamar.fromJson(data['data']);
      }
      
      throw Exception('Gagal mengambil detail kamar');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Create kamar
  Future<Kamar> createKamar({
    required String nomorKamar,
    required String tipe,
    required double hargaBulanan,
    required String status,
    String? fasilitas,
    int? userId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        AppConfig.kamarEndpoint,
        data: {
          'nomor_kamar': nomorKamar,
          'tipe': tipe,
          'harga_bulanan': hargaBulanan,
          'status': status,
          'fasilitas': fasilitas,
          'user_id': userId,
        },
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return Kamar.fromJson(data['data']);
      }
      
      throw Exception(data['message'] ?? 'Gagal menambah kamar');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Update kamar
  Future<Kamar> updateKamar({
    required int id,
    String? nomorKamar,
    String? tipe,
    double? hargaBulanan,
    String? status,
    String? fasilitas,
    int? userId,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (nomorKamar != null) updateData['nomor_kamar'] = nomorKamar;
      if (tipe != null) updateData['tipe'] = tipe;
      if (hargaBulanan != null) updateData['harga_bulanan'] = hargaBulanan;
      if (status != null) updateData['status'] = status;
      if (fasilitas != null) updateData['fasilitas'] = fasilitas;
      if (userId != null) updateData['user_id'] = userId;

      final response = await _apiService.dio.put(
        '${AppConfig.kamarEndpoint}/$id',
        data: updateData,
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return Kamar.fromJson(data['data']);
      }
      
      throw Exception(data['message'] ?? 'Gagal update kamar');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Delete kamar
  Future<void> deleteKamar(int id) async {
    try {
      final response = await _apiService.dio.delete(
        '${AppConfig.kamarEndpoint}/$id',
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Gagal menghapus kamar');
      }
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _apiService.dio.get(
        AppConfig.kamarStatisticsEndpoint,
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return data['data'];
      }
      
      throw Exception('Gagal mengambil statistik');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }
}