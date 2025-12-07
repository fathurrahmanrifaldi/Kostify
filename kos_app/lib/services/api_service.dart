import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  Dio get dio => _dio;

  // Initialize Dio
  Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to header if exists
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  // Save token to SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
  }

  // Remove token from SharedPreferences
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userKey);
    await prefs.remove(AppConfig.roleKey);
  }

  // Handle API Response
  Map<String, dynamic> handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Handle API Error
  String handleError(DioException error) {
    String errorMessage = 'Terjadi kesalahan';

    if (error.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Koneksi timeout. Coba lagi.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Timeout menerima data. Coba lagi.';
    } else if (error.type == DioExceptionType.badResponse) {
      if (error.response?.statusCode == 401) {
        errorMessage = 'Unauthorized. Silakan login kembali.';
      } else if (error.response?.statusCode == 403) {
        errorMessage = 'Akses ditolak.';
      } else if (error.response?.statusCode == 404) {
        errorMessage = 'Data tidak ditemukan.';
      } else if (error.response?.statusCode == 422) {
        // Validation error
        final data = error.response?.data;
        if (data != null && data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first[0];
        } else if (data != null && data['message'] != null) {
          errorMessage = data['message'];
        }
      } else if (error.response?.statusCode == 500) {
        errorMessage = 'Server error. Coba lagi nanti.';
      } else {
        errorMessage = error.response?.data['message'] ?? errorMessage;
      }
    } else if (error.type == DioExceptionType.cancel) {
      errorMessage = 'Request dibatalkan.';
    } else {
      errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
    }

    return errorMessage;
  }
}