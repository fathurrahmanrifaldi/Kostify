class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Jika testing di device fisik, ganti dengan IP komputer:
  // static const String baseUrl = 'http://192.168.1.100:8000/api';
  
  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String profileEndpoint = '/profile';
  
  static const String kamarEndpoint = '/kamar';
  static const String kamarStatisticsEndpoint = '/kamar/statistics/dashboard';
  
  static const String usersEndpoint = '/users';
  
  static const String pembayaranEndpoint = '/pembayaran';
  static const String pembayaranLaporanEndpoint = '/pembayaran/laporan/dashboard';
  static const String pembayaranByKamarEndpoint = '/pembayaran/kamar';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';
  
  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // App Info
  static const String appName = 'Kostify';
  static const String appVersion = '1.0.0';
}