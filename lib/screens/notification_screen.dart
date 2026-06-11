// screens/notification_screen.dart
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  List<NotificationModel> _notifications = [];
  bool _loading = true;
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _loadNotifications();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final list = await NotificationService.instance.loadAll();
    if (mounted) {
      setState(() {
        _notifications = list;
        _loading = false;
      });
      await NotificationService.instance.markAllRead();
      _ctrl.forward();
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá tất cả'),
        content: const Text('Bạn có chắc muốn xoá toàn bộ thông báo?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xoá',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      await NotificationService.instance.deleteAll();
      setState(() => _notifications = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0E14) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E1D2E) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
    final textSecondary =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93);
    const accent = Color(0xFF4B49EB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1B1A2A) : Colors.white,
        elevation: 0,
        title: Text('Thông Báo',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: accent)),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text('Xoá tất cả',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_rounded,
                          size: 72,
                          color: textSecondary.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text('Không có thông báo nào',
                          style: TextStyle(
                              fontSize: 16,
                              color: textSecondary,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final n = _notifications[i];
                      return _buildNotifCard(
                          n, cardColor, textPrimary, textSecondary, isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotifCard(
    NotificationModel n,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final iconData = _iconFor(n.type);
    final iconColor = _colorFor(n.type);
    final iconBg = iconColor.withValues(alpha: 0.12);
    final timeStr = _formatTime(n.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: !n.isRead
            ? Border.all(
                color: const Color(0xFF4B49EB).withValues(alpha: 0.35),
                width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration:
                BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(n.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textPrimary)),
                    ),
                    if (!n.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 6, top: 3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4B49EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(n.body,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(timeStr,
                    style: TextStyle(fontSize: 11, color: textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'transaction':
        return Icons.receipt_long_rounded;
      case 'alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'transaction':
        return const Color(0xFF00C096);
      case 'alert':
        return const Color(0xFFFF7A00);
      default:
        return const Color(0xFF4B49EB);
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
