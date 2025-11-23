// lib/services/auth_service.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        AppConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        // Save token and user data
        final token = data['data']['token'];
        final user = User.fromJson(data['data']['user']);
        
        await _apiService.saveToken(token);
        await _saveUserData(user);
        
        return {
          'success': true,
          'user': user,
          'token': token,
        };
      }
      
      throw Exception(data['message'] ?? 'Login gagal');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String role,
    String? noTelepon,
  }) async {
    try {
      final response = await _apiService.dio.post(
        AppConfig.registerEndpoint,
        data: {
          'nama': nama,
          'email': email,
          'password': password,
          'role': role,
          'no_telepon': noTelepon,
        },
      );

      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        // Save token and user data
        final token = data['data']['token'];
        final user = User.fromJson(data['data']['user']);
        
        await _apiService.saveToken(token);
        await _saveUserData(user);
        
        return {
          'success': true,
          'user': user,
          'token': token,
        };
      }
      
      throw Exception(data['message'] ?? 'Registrasi gagal');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.dio.post(AppConfig.logoutEndpoint);
      await _apiService.removeToken();
    } on DioException catch (e) {
      // Even if API call fails, remove local token
      await _apiService.removeToken();
      throw Exception(_apiService.handleError(e));
    }
  }

  // Get Profile
  Future<User> getProfile() async {
    try {
      final response = await _apiService.dio.get(AppConfig.profileEndpoint);
      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true) {
        final user = User.fromJson(data['data']);
        await _saveUserData(user);
        return user;
      }
      
      throw Exception('Gagal mengambil profile');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }

  // Get current user from SharedPreferences
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConfig.userKey);
      
      if (userJson != null) {
        final userData = json.decode(userJson); // PAKAI JSON DECODE
        return User.fromJson(userData);
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    
    return null;
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.userKey, json.encode(user.toJson())); // PAKAI JSON ENCODE
    await prefs.setString(AppConfig.roleKey, user.role);
  }
}