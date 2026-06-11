import 'package:dio/dio.dart';

class ApiService {
  // Thay đổi IP này phù hợp với môi trường của bạn:
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static String? _accessToken;

  // ── Auth ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        _accessToken = response.data['access_token'];
        _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
        return {'success': true, 'user': response.data['user']};
      }
      return {'success': false, 'message': 'Lỗi không xác định'};
    } on DioException catch (e) {
      if (e.response != null) {
        return {'success': false, 'message': e.response?.data['detail'] ?? 'Lỗi từ server'};
      }
      return {'success': false, 'message': 'Không thể kết nối tới server'};
    }
  }

  static void logout() {
    _accessToken = null;
    _dio.options.headers.remove('Authorization');
  }

  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      if (response.statusCode == 200) return response.data;
    } catch (e) { print('Lỗi getMe: $e'); }
    return null;
  }

  static Future<Map<String, dynamic>?> updateMe(String fullName, String email) async {
    try {
      final response = await _dio.put('/auth/me', data: {
        'full_name': fullName,
        'email': email,
      });
      if (response.statusCode == 200) return response.data;
    } catch (e) { print('Lỗi updateMe: $e'); }
    return null;
  }

  // ── Jars (Hũ Chi Tiêu) ──────────────────────────────────────────────────
  static Future<List<dynamic>?> getJars() async {
    try {
      final response = await _dio.get('/jars');
      if (response.statusCode == 200) return response.data;
    } catch (e) { print('Lỗi getJars: $e'); }
    return null;
  }

  static Future<Map<String, dynamic>?> createJar(String name, double budget, String jarType, {String description = ""}) async {
    try {
      final response = await _dio.post('/jars', data: {
        'jar_name': name,
        'description': description,
        'budget': budget,
        'jar_type': jarType,
      });
      if (response.statusCode == 201) return response.data;
    } catch (e) { print('Lỗi createJar: $e'); }
    return null;
  }

  static Future<Map<String, dynamic>?> updateJar(String jarId, String name, double budget, int jarType) async {
    try {
      final response = await _dio.put('/jars/$jarId', data: {
        'jar_name': name,
        'budget': budget,
        'jar_type': jarType,
      });
      if (response.statusCode == 200) return response.data;
    } catch (e) { print('Lỗi updateJar: $e'); }
    return null;
  }

  // ── Jar Members ────────────────────────────────────────────────────────────
  static Future<List<dynamic>?> getJarMembers(String jarId) async {
    try {
      final response = await _dio.get('/jars/$jarId/members');
      if (response.statusCode == 200) return response.data;
    } catch (e) { print('Lỗi getJarMembers: $e'); }
    return null;
  }

  static Future<Map<String, dynamic>?> addJarMember(String jarId, String userId, {String role = 'Member'}) async {
    try {
      final response = await _dio.post('/jars/$jarId/members', data: {
        'user_id': userId,
        'role': role,
      });
      if (response.statusCode == 201) return response.data;
    } catch (e) { print('Lỗi addJarMember: $e'); }
    return null;
  }

  static Future<bool> removeJarMember(String jarId, String userId) async {
    try {
      final response = await _dio.delete('/jars/$jarId/members/$userId');
      if (response.statusCode == 204) return true;
    } catch (e) { print('Lỗi removeJarMember: $e'); }
    return false;
  }

  /// Tìm user theo email để mời
  static Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final response = await _dio.get('/auth/users', queryParameters: {'email': email});
      if (response.statusCode == 200) return response.data;
    } catch (e) { print('Lỗi findUserByEmail: $e'); }
    return null;
  }

  static Future<bool> deleteJar(String jarId) async {
    try {
      final response = await _dio.delete('/jars/$jarId');
      if (response.statusCode == 204) return true;
    } catch (e) { print('Lỗi deleteJar: $e'); }
    return false;
  }

  // ── Transactions (Giao dịch) ────────────────────────────────────────────
  static Future<List<dynamic>?> getTransactions({String? jarId, int? month, int? year, int limit = 50}) async {
    try {
      String path = '/transactions?limit=$limit';
      if (jarId != null) path += '&jar_id=$jarId';
      if (month != null) path += '&month=$month';
      if (year != null) path += '&year=$year';
      final response = await _dio.get(path);
      if (response.statusCode == 200) return response.data;
    } catch (e) { print('Lỗi getTransactions: $e'); }
    return null;
  }

  static Future<Map<String, dynamic>?> createTransaction(
    String jarId, String categoryId, double amount, String description, bool isIncome, String? date
  ) async {
    try {
      final response = await _dio.post('/transactions', data: {
        'jar_id': jarId,
        'category_id': categoryId,
        'amount': amount,
        'description': description,
        'transaction_type': isIncome,
        'transaction_date': date,
      });
      if (response.statusCode == 201) return response.data;
    } catch (e) { print('Lỗi createTransaction: $e'); }
    return null;
  }

  // ── Dashboard ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final response = await _dio.get('/dashboard');
      if (response.statusCode == 200) return response.data;
    } catch (e) { print('Lỗi getDashboard: $e'); }
    return null;
  }
}
