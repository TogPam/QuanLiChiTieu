// services/notification_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/notification_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  String _currentUser = 'guest';

  void setUser(String username) {
    _currentUser = username.replaceAll(' ', '_').toLowerCase();
  }

  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final userDir =
        Directory('${dir.path}/$_currentUser/notification');
    if (!await userDir.exists()) {
      await userDir.create(recursive: true);
    }
    return '${userDir.path}/$_currentUser-noti.json';
  }

  Future<List<NotificationModel>> loadAll() async {
    try {
      final path = await _getFilePath();
      final file = File(path);
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      final List<dynamic> list = json.decode(raw);
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<NotificationModel> list) async {
    final path = await _getFilePath();
    final file = File(path);
    await file.writeAsString(json.encode(list.map((e) => e.toJson()).toList()));
  }

  Future<void> add(NotificationModel notif) async {
    final list = await loadAll();
    list.insert(0, notif);
    await _save(list);
  }

  Future<void> markAllRead() async {
    final list = await loadAll();
    for (final n in list) {
      n.isRead = true;
    }
    await _save(list);
  }

  Future<void> markRead(String id) async {
    final list = await loadAll();
    for (final n in list) {
      if (n.id == id) n.isRead = true;
    }
    await _save(list);
  }

  Future<void> deleteAll() async {
    await _save([]);
  }

  Future<int> unreadCount() async {
    final list = await loadAll();
    return list.where((n) => !n.isRead).length;
  }

  /// Tạo thông báo mẫu khi đăng nhập
  Future<void> addWelcome(String displayName) async {
    await add(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Chào mừng trở lại, $displayName!',
      body: 'Bạn đã đăng nhập thành công. Chúc bạn quản lý tài chính hiệu quả.',
      type: 'system',
      createdAt: DateTime.now(),
    ));
  }
}
