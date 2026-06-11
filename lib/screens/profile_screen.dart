import 'package:flutter/material.dart';
import '../controllers/theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1D2E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF0F0E14) : const Color(0xFFF4F6FB);
    final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
    const accent = Color(0xFF4B49EB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1B1A2A) : Colors.white,
        elevation: 0,
        title: Text(
          'Tài Khoản',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: accent,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // ── Avatar ──────────────────────────────────────────────
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 52,
                        backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=250'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.edit_rounded, color: Colors.white, size: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Trần Văn Phát',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'tranvanphat@lumiere.com',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // ── Thẻ thông tin nhanh ────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        title: 'TÀI SẢN RÒNG',
                        value: '1.240.500đ',
                        subtitle: '+2,4%',
                        subtitleColor: const Color(0xFF00C096),
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildInfoCard(
                        title: 'GÓI DỊCH VỤ',
                        value: 'Premium Elite',
                        subtitle: 'Hết hạn: 24/10',
                        subtitleColor: accent,
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Tiêu đề cài đặt ────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'CÀI ĐẶT TÀI KHOẢN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Danh sách cài đặt ──────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: Icons.security_rounded,
                        title: 'Bảo mật',
                        subtitle: 'Sinh trắc học, 2FA, Mật khẩu',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      _buildDivider(isDark),
                      _buildSettingTile(
                        icon: Icons.notifications_rounded,
                        title: 'Thông báo',
                        subtitle: 'Cảnh báo, Báo cáo hàng tuần',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      _buildDivider(isDark),
                      _buildSettingTile(
                        icon: Icons.link_rounded,
                        title: 'Tài khoản liên kết',
                        subtitle: '3 Ngân hàng, 2 Sàn đầu tư',
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      _buildDivider(isDark),

                      // ── Nút chuyển sáng/tối ─────────────────────────
                      ValueListenableBuilder<bool>(
                        valueListenable: ThemeController.instance.isLightMode,
                        builder: (context, isLight, _) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: isLight
                                        ? const Color(0xFFFFF3CD)
                                        : const Color(0xFF2D2A4A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, anim) =>
                                        RotationTransition(
                                      turns: anim,
                                      child: FadeTransition(
                                          opacity: anim, child: child),
                                    ),
                                    child: Icon(
                                      isLight
                                          ? Icons.wb_sunny_rounded
                                          : Icons.nights_stay_rounded,
                                      key: ValueKey(isLight),
                                      color: isLight
                                          ? const Color(0xFFFFAB00)
                                          : const Color(0xFF7C7AFF),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Giao diện',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: textPrimary,
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        child: Text(
                                          isLight
                                              ? 'Chế độ sáng đang bật'
                                              : 'Chế độ tối đang bật',
                                          key: ValueKey(isLight),
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Custom animated toggle
                                GestureDetector(
                                  onTap: () =>
                                      ThemeController.instance.toggle(),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: 52,
                                    height: 30,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: isLight
                                          ? const Color(0xFFE5E7EB)
                                          : const Color(0xFF4B49EB),
                                    ),
                                    child: AnimatedAlign(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      alignment: isLight
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Nút đăng xuất ──────────────────────────────────────
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.redAccent.withValues(alpha: isDark ? 0.08 : 0.04),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout_rounded,
                            color: Colors.redAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Quản Lý Chi Tiêu v2.4.0',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 10,
                  color: textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: subtitleColor)),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: const BoxDecoration(
          color: Color(0xFFEEEDFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF4B49EB), size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textPrimary)),
      subtitle: Text(subtitle,
          style: TextStyle(color: textSecondary, fontSize: 11)),
      trailing:
          Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
      onTap: () {},
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      indent: 56,
      height: 1,
      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey[100],
    );
  }
}
