import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/theme_controller.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import 'notification_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  String _displayName = 'Đang tải...';
  String _email = '...';
  double _totalBalance = 0;
  double _savingRate = 0;
  File? _avatarFile;
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    final count = await NotificationService.instance.unreadCount();
    final me = await ApiService.getMe();
    final db = await ApiService.getDashboard();
    
    if (mounted) {
      setState(() {
        _unreadCount = count;
        if (me != null) {
          _displayName = me['full_name'] ?? 'Không tên';
          _email = me['email'] ?? '';
        }
        if (db != null) {
          _totalBalance = (db['total_balance'] ?? 0).toDouble();
          _savingRate = (db['saving_rate'] ?? 0).toDouble();
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() { _animController.dispose(); super.dispose(); }

  // ── Đổi ảnh đại diện ─────────────────────────────────────────────
  void _showAvatarOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bg = isDark ? const Color(0xFF1E1D2E) : Colors.white;
        final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
        final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
        const accent = Color(0xFF4B49EB);
        return Container(
          decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            Text('Thay đổi ảnh đại diện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
            const SizedBox(height: 20),
            _optionTile(Icons.camera_alt_rounded, 'Chụp ảnh mới', accent, () async {
              Navigator.pop(ctx);
              final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
              if (picked != null) setState(() => _avatarFile = File(picked.path));
            }),
            const SizedBox(height: 12),
            _optionTile(Icons.photo_library_rounded, 'Chọn từ thư viện', const Color(0xFF00C096), () async {
              Navigator.pop(ctx);
              final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
              if (picked != null) setState(() => _avatarFile = File(picked.path));
            }),
            if (_avatarFile != null) ...[
              const SizedBox(height: 12),
              _optionTile(Icons.delete_outline_rounded, 'Xoá ảnh hiện tại', Colors.redAccent, () {
                Navigator.pop(ctx);
                setState(() => _avatarFile = null);
              }),
            ],
          ]),
        );
      },
    );
  }

  Widget _optionTile(IconData icon, String label, Color color, VoidCallback onTap) =>
    InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );

  // ── Chỉnh sửa tên ────────────────────────────────────────────────
  void _showEditNameDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameCtrl = TextEditingController(text: _displayName);
    final emailCtrl = TextEditingController(text: _email);

    showDialog(
      context: context,
      builder: (ctx) {
        final bg = isDark ? const Color(0xFF1E1D2E) : Colors.white;
        final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
        final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
        const accent = Color(0xFF4B49EB);
        return AlertDialog(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Chỉnh sửa hồ sơ', style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                labelText: 'Họ và tên',
                labelStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.person_outline_rounded, color: textSecondary),
                filled: true, fillColor: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: accent, width: 1.5)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.email_outlined, color: textSecondary),
                filled: true, fillColor: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: accent, width: 1.5)),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Huỷ', style: TextStyle(color: textSecondary))),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                
                setState(() => _isLoading = true);
                final res = await ApiService.updateMe(name, email);
                if (res != null) {
                  setState(() { _displayName = name; _email = email; });
                  NotificationService.instance.setUser(name);
                }
                setState(() => _isLoading = false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0E14) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E1D2E) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
    const accent = Color(0xFF4B49EB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1B1A2A) : Colors.white,
        elevation: 0,
        title: Text('Tài Khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: accent)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: textPrimary),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                  _loadData();
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: Center(child: Text('$_unreadCount',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              // ── Avatar ─────────────────────────────────────────────
              Stack(alignment: Alignment.bottomRight, children: [
                GestureDetector(
                  onTap: _showAvatarOptions,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!) as ImageProvider
                          : const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=250'),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showAvatarOptions,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(color: accent, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 15),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // Tên & email
              GestureDetector(
                onTap: _showEditNameDialog,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_displayName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(width: 8),
                  Icon(Icons.edit_rounded, size: 16, color: textSecondary),
                ]),
              ),
              const SizedBox(height: 4),
              Text(_email, style: TextStyle(color: textSecondary, fontSize: 13)),
              const SizedBox(height: 24),

              // Thẻ thông tin
              Row(children: [
                Expanded(child: _infoCard(
                  'TÀI SẢN RÒNG', 
                  '${_totalBalance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ', 
                  '${_savingRate > 0 ? "+" : ""}${_savingRate}%', 
                  const Color(0xFF00C096), cardColor, textPrimary, textSecondary
                )),
              ]),
              const SizedBox(height: 32),

              // Tiêu đề cài đặt
              Align(alignment: Alignment.centerLeft,
                child: Text('CÀI ĐẶT TÀI KHOẢN',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 1.2))),
              const SizedBox(height: 12),

              // Danh sách cài đặt
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: cardColor, borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Column(children: [
                  _settingTile(Icons.person_rounded, 'Chỉnh sửa hồ sơ', 'Tên, email cá nhân', textPrimary, textSecondary, onTap: _showEditNameDialog),
                  _divider(isDark),

                  // Toggle sáng/tối
                  ValueListenableBuilder<bool>(
                    valueListenable: ThemeController.instance.isLightMode,
                    builder: (context, isLight, _) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: isLight ? const Color(0xFFFFF3CD) : const Color(0xFF2D2A4A),
                            shape: BoxShape.circle,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => RotationTransition(turns: anim,
                                child: FadeTransition(opacity: anim, child: child)),
                            child: Icon(
                              isLight ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                              key: ValueKey(isLight),
                              color: isLight ? const Color(0xFFFFAB00) : const Color(0xFF7C7AFF),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Giao diện', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              isLight ? 'Chế độ sáng đang bật' : 'Chế độ tối đang bật',
                              key: ValueKey(isLight),
                              style: TextStyle(color: textSecondary, fontSize: 11),
                            ),
                          ),
                        ])),
                        GestureDetector(
                          onTap: () => ThemeController.instance.toggle(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut,
                            width: 52, height: 30, padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: isLight ? const Color(0xFFE5E7EB) : accent,
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut,
                              alignment: isLight ? Alignment.centerLeft : Alignment.centerRight,
                              child: Container(width: 24, height: 24,
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // Đăng xuất
              InkWell(
                onTap: () {
                  ApiService.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.redAccent.withValues(alpha: isDark ? 0.08 : 0.04),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Text('Quản Lý Chi Tiêu v2.4.0', style: TextStyle(color: textSecondary, fontSize: 11)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, String sub, Color subColor, Color cardColor, Color textPrimary, Color textSecondary) =>
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subColor)),
      ]),
    );

  Widget _settingTile(IconData icon, String title, String subtitle, Color textPrimary, Color textSecondary, {VoidCallback? onTap}) =>
    ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: const BoxDecoration(color: Color(0xFFEEEDFF), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF4B49EB), size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
      subtitle: Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 11)),
      trailing: Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
      onTap: onTap ?? () {},
    );

  Widget _divider(bool isDark) => Divider(
    indent: 56, height: 1,
    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey[100],
  );
}