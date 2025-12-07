import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Get all users (penyewa)
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiService.dio.get(AppConfig.usersEndpoint);

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        final List<dynamic> users = data['data'];
        return users.map((json) => User.fromJson(json)).toList();
      }
      
      throw Exception('Gagal mengambil data penyewa');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Get user by ID
  Future<User> getUserById(int id) async {
    try {
      final response = await _apiService.dio.get(
        '${AppConfig.usersEndpoint}/$id',
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
      
      throw Exception('Gagal mengambil detail user');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Create user (penyewa)
  Future<User> createUser({
    required String nama,
    required String email,
    required String password,
    String? noTelepon,
  }) async {
    try {
      final response = await _apiService.dio.post(
        AppConfig.usersEndpoint,
        data: {
          'nama': nama,
          'email': email,
          'password': password,
          'no_telepon': noTelepon,
        },
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
      
      throw Exception(data['message'] ?? 'Gagal menambah penyewa');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Update user
  Future<User> updateUser({
    required int id,
    String? nama,
    String? email,
    String? password,
    String? noTelepon,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (nama != null) updateData['nama'] = nama;
      if (email != null) updateData['email'] = email;
      if (password != null) updateData['password'] = password;
      if (noTelepon != null) updateData['no_telepon'] = noTelepon;

      final response = await _apiService.dio.put(
        '${AppConfig.usersEndpoint}/$id',
        data: updateData,
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
      
      throw Exception(data['message'] ?? 'Gagal update user');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Delete user
  Future<void> deleteUser(int id) async {
    try {
      final response = await _apiService.dio.delete(
        '${AppConfig.usersEndpoint}/$id',
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Gagal menghapus user');
      }
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }
}