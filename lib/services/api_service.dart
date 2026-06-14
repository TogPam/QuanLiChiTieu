import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/login_screen.dart';

class ApiService {
  // Thay đổi IP này phù hợp với môi trường của bạn:
  //static const String baseUrl = 'http://10.0.2.2:8000';
  static const String baseUrl =
      'https://projector-captured-locate-gain.trycloudflare.com';
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static String? _accessToken;
  static bool _isForceLoggingOut = false;

  /// Khởi tạo interceptor – gọi 1 lần duy nhất
  static void _ensureInterceptor() {
    if (_dio.interceptors.whereType<_AuthInterceptor>().isNotEmpty) return;
    _dio.interceptors.add(_AuthInterceptor());
  }

  /// Force logout khi phát hiện 401 (JWT hết hạn hoặc tài khoản đăng nhập nơi khác)
  static void _forceLogout(String message) {
    if (_isForceLoggingOut) return;
    _isForceLoggingOut = true;
    logout();

    final ctx = navigatorKey.currentContext;
    if (ctx == null) { _isForceLoggingOut = false; return; }

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dCtx) {
        final isDark = Theme.of(dCtx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1D2E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 36),
          ),
          title: Text('Phiên đăng nhập hết hạn',
              style: TextStyle(fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E))),
          content: Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600], height: 1.5)),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dCtx).pop();
                navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
                _isForceLoggingOut = false;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B49EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Đăng nhập lại', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ── Auth ────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'full_name': fullName, 'email': email, 'password': password},
      );
      if (response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': 'Đăng ký thất bại'};
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['detail'] ?? 'Lỗi từ server',
        };
      }
      return {'success': false, 'message': 'Không thể kết nối tới server'};
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        _accessToken = response.data['access_token'];
        _dio.options.headers['Authorization'] = 'Bearer $_accessToken';
        _ensureInterceptor();
        return {'success': true, 'user': response.data['user']};
      }
      return {'success': false, 'message': 'Lỗi không xác định'};
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['detail'] ?? 'Lỗi từ server',
        };
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
    } catch (e) {
      print('Lỗi getMe: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateMe(
    String fullName,
    String email,
  ) async {
    try {
      final response = await _dio.put(
        '/auth/me',
        data: {'full_name': fullName, 'email': email},
      );
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi updateMe: $e');
    }
    return null;
  }

  // ── Categories (Danh mục) ───────────────────────────────────────────────
  static Future<List<dynamic>?> getCategories({bool? isIncome}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isIncome != null) queryParams['is_income'] = isIncome;
      final response = await _dio.get(
        '/categories',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi getCategories: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createCategory(
    String name,
    bool isIncome, {
    String? iconUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/categories',
        data: {
          'category_name': name,
          'category_type': isIncome,
          'icon_url': iconUrl,
        },
      );
      if (response.statusCode == 201) return response.data;
    } catch (e) {
      print('Lỗi createCategory: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getCategory(int categoryId) async {
    try {
      final response = await _dio.get('/categories/$categoryId');
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi getCategory: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateCategory(
    int categoryId,
    String name,
    bool isIncome, {
    String? iconUrl,
  }) async {
    try {
      final response = await _dio.put(
        '/categories/$categoryId',
        data: {
          'category_name': name,
          'category_type': isIncome,
          'icon_url': iconUrl,
        },
      );
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi updateCategory: $e');
    }
    return null;
  }

  static Future<bool> deleteCategory(int categoryId) async {
    try {
      final response = await _dio.delete('/categories/$categoryId');
      if (response.statusCode == 204) return true;
    } catch (e) {
      print('Lỗi deleteCategory: $e');
    }
    return false;
  }

  // ── Jars (Hũ Chi Tiêu) ──────────────────────────────────────────────────
  static Future<List<dynamic>?> getJars() async {
    try {
      final response = await _dio.get('/jars');
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi getJars: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getJar(String jarId) async {
    try {
      final response = await _dio.get('/jars/$jarId');
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi getJar: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createJar(
    String name,
    double budget,
    String jarType, {
    String description = "",
  }) async {
    try {
      final response = await _dio.post(
        '/jars',
        data: {
          'jar_name': name,
          'description': description,
          'budget': budget,
          'jar_type': jarType,
        },
      );
      if (response.statusCode == 201) return response.data;
    } catch (e) {
      print('Lỗi createJar: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateJar(
    String jarId,
    String name,
    double budget,
    int jarType,
  ) async {
    try {
      final response = await _dio.put(
        '/jars/$jarId',
        data: {'jar_name': name, 'budget': budget, 'jar_type': jarType},
      );
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi updateJar: $e');
    }
    return null;
  }

  // ── Jar Members ────────────────────────────────────────────────────────────
  static Future<List<dynamic>?> getJarMembers(String jarId) async {
    try {
      final response = await _dio.get('/jars/$jarId/members');
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi getJarMembers: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> addJarMember(
    String jarId,
    String userId, {
    String role = 'Member',
  }) async {
    try {
      final response = await _dio.post(
        '/jars/$jarId/members',
        data: {'user_id': userId, 'role': role},
      );
      if (response.statusCode == 201) return response.data;
    } catch (e) {
      print('Lỗi addJarMember: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateJarMemberRole(
    String jarId,
    String userId,
    String role,
  ) async {
    try {
      final response = await _dio.put(
        '/jars/$jarId/members/$userId',
        data: {'role': role},
      );
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi updateJarMemberRole: $e');
    }
    return null;
  }

  static Future<bool> removeJarMember(String jarId, String userId) async {
    try {
      final response = await _dio.delete('/jars/$jarId/members/$userId');
      if (response.statusCode == 204) return true;
    } catch (e) {
      print('Lỗi removeJarMember: $e');
    }
    return false;
  }

  /// Tìm user theo email để mời
  static Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final response = await _dio.get(
        '/auth/users',
        queryParameters: {'email': email},
      );
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi findUserByEmail: $e');
    }
    return null;
  }

  static Future<bool> deleteJar(String jarId) async {
    try {
      final response = await _dio.delete('/jars/$jarId');
      if (response.statusCode == 204) return true;
    } catch (e) {
      print('Lỗi deleteJar: $e');
    }
    return false;
  }

  // ── Transactions (Giao dịch) ────────────────────────────────────────────
  static Future<List<dynamic>?> getTransactions({
    String? jarId,
    int? month,
    int? year,
    int limit = 50,
  }) async {
    try {
      String path = '/transactions?limit=$limit';
      if (jarId != null) path += '&jar_id=$jarId';
      if (month != null) path += '&month=$month';
      if (year != null) path += '&year=$year';
      final response = await _dio.get(path);
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi getTransactions: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createTransaction(
    String jarId,
    int categoryId,
    double amount,
    String description,
    bool isIncome,
    String? date,
  ) async {
    try {
      final response = await _dio.post(
        '/transactions',
        data: {
          'jar_id': jarId,
          'category_id': categoryId,
          'amount': amount,
          // FIX 1: Tránh gửi chuỗi rỗng cho các trường Optional, ép về null để Backend Pydantic không báo lỗi 422
          'description': description.trim().isEmpty ? null : description.trim(),
          'transaction_type': isIncome,
          // FIX 2: Cực kỳ quan trọng. Chuỗi rỗng "" không thể parse thành datetime trong Python.
          'transaction_date': (date == null || date.trim().isEmpty)
              ? null
              : date,
        },
      );

      print("🚀 Gửi Payload sang Backend: $response");

      if (response.statusCode == 201) return response.data;
    } on DioException catch (e) {
      // FIX 3: In ra chính xác lỗi từ FastAPI để bạn biết mình đang sai ở trường dữ liệu nào
      if (e.response != null) {
        print('❌ Lỗi Backend [${e.response?.statusCode}]: ${e.response?.data}');
      } else {
        print('❌ Lỗi Mạng hoặc Server chưa chạy: ${e.message}');
      }
    } catch (e) {
      print('❌ Lỗi nội bộ Flutter: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getTransaction(
    String transactionId,
  ) async {
    try {
      final response = await _dio.get('/transactions/$transactionId');
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi getTransaction: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> updateTransaction(
    String transactionId, {
    int? categoryId,
    double? amount,
    String? description,
    bool? isIncome,
    String? date,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (categoryId != null) data['category_id'] = categoryId;
      if (amount != null) data['amount'] = amount;
      if (description != null) data['description'] = description;
      if (isIncome != null) data['transaction_type'] = isIncome;
      if (date != null) data['transaction_date'] = date;

      final response = await _dio.put(
        '/transactions/$transactionId',
        data: data,
      );
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi updateTransaction: $e');
    }
    return null;
  }

  static Future<bool> deleteTransaction(String transactionId) async {
    try {
      final response = await _dio.delete('/transactions/$transactionId');
      if (response.statusCode == 204) return true;
    } catch (e) {
      print('Lỗi deleteTransaction: $e');
    }
    return false;
  }

  static Future<Map<String, dynamic>?> uploadTransactionReceipt(
    String transactionId,
    String filePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post(
        '/transactions/$transactionId/upload',
        data: formData,
      );
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi uploadTransactionReceipt: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> getMonthlySummary(
    int year, {
    String? jarId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'year': year};
      if (jarId != null) queryParams['jar_id'] = jarId;
      final response = await _dio.get(
        '/transactions/summary/monthly',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi getMonthlySummary: $e');
    }
    return null;
  }

  // ── Dashboard ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final response = await _dio.get('/dashboard');
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      print('Lỗi getDashboard: $e');
    }
    return null;
  }
}

/// Interceptor bắt lỗi 401 (JWT hết hạn / bị đăng nhập nơi khác)
class _AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && ApiService._accessToken != null) {
      ApiService._forceLogout(
        'Tài khoản của bạn đã được đăng nhập trên thiết bị khác hoặc phiên đã hết hạn.\nVui lòng đăng nhập lại.',
      );
    }
    handler.next(err);
  }
}
