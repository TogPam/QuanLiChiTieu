import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0E14) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E1D2E) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFE4E1EE) : const Color(0xFF2C2C2C);
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93);
    final iconBtnBg =
        isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4B49EB)
                                      .withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào, Trần Văn Phát 👋',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              Text(
                                'Thứ Ba, 10 Tháng 6',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _iconButton(
                          Icons.notifications_none_rounded, iconBtnBg, textPrimary),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Thẻ số dư ──────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5D5BF7), Color(0xFF3B39E0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4B49EB).withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TỔNG SỐ DƯ HIỆN TẠI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '85.450.000đ',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up_rounded,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                '+12,5% tháng này',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Thống kê nhanh ─────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickStat(
                        context,
                        icon: Icons.trending_up_rounded,
                        title: 'Thu nhập',
                        value: '+15Tr',
                        iconColor: const Color(0xFF00C096),
                        bgColor: isDark
                            ? const Color(0xFF0D3327)
                            : const Color(0xFFE6F9F3),
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                      ),
                      _buildQuickStat(
                        context,
                        icon: Icons.trending_down_rounded,
                        title: 'Chi tiêu',
                        value: '-8,2Tr',
                        iconColor: const Color(0xFFFF5252),
                        bgColor: isDark
                            ? const Color(0xFF3D1212)
                            : const Color(0xFFFFF0F0),
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                      ),
                      _buildQuickStat(
                        context,
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'Tiết kiệm',
                        value: '4,5Tr',
                        iconColor: const Color(0xFF4B49EB),
                        bgColor: isDark
                            ? const Color(0xFF1A1840)
                            : const Color(0xFFEEEDFF),
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Tiêu đề hũ ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quản lý Hũ Chi Tiêu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4B49EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Danh sách hũ ─────────────────────────────────────
                  _buildJarItem(
                    title: 'Tiền ăn',
                    remaining: 'Còn 1.200.000đ',
                    spent: 'Đã dùng 3.800.000đ',
                    limit: 'Hạn mức 5.000.000đ',
                    percent: 0.76,
                    progressColor: const Color(0xFFFF7A00),
                    icon: Icons.restaurant_rounded,
                    iconColor: const Color(0xFFFF7A00),
                    iconBg: isDark
                        ? const Color(0xFF3D2208)
                        : const Color(0xFFFFE6D5),
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildJarItem(
                    title: 'Đi chơi',
                    remaining: 'Còn 850.000đ',
                    spent: 'Đã dùng 1.150.000đ',
                    limit: 'Hạn mức 2.000.000đ',
                    percent: 0.575,
                    progressColor: const Color(0xFFB5179E),
                    icon: Icons.celebration_rounded,
                    iconColor: const Color(0xFFB5179E),
                    iconBg: isDark
                        ? const Color(0xFF35103A)
                        : const Color(0xFFF9E5F5),
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildJarItem(
                    title: 'Học tập',
                    remaining: 'Còn 3.000.000đ',
                    spent: 'Đã dùng 500.000đ',
                    limit: 'Hạn mức 3.500.000đ',
                    percent: 0.142,
                    progressColor: const Color(0xFF4361EE),
                    icon: Icons.school_rounded,
                    iconColor: const Color(0xFF4361EE),
                    iconBg: isDark
                        ? const Color(0xFF131A3E)
                        : const Color(0xFFE8ECFF),
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildJarItem(
                    title: 'Tiền nhà',
                    remaining: 'Còn 5.000.000đ',
                    spent: 'Đã dùng 0đ',
                    limit: 'Hạn mức 5.000.000đ',
                    percent: 0.0,
                    progressColor: const Color(0xFF00C096),
                    icon: Icons.home_work_rounded,
                    iconColor: const Color(0xFF00C096),
                    iconBg: isDark
                        ? const Color(0xFF0D3327)
                        : const Color(0xFFE5F9F4),
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),

                  // ── Tiêu đề giao dịch ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Giao dịch gần đây',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Xem tất cả',
                          style: TextStyle(
                            color: Color(0xFF4B49EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Giao dịch ────────────────────────────────────────
                  _buildTransactionRow(
                    title: 'Siêu thị WinMart',
                    subtitle: 'Hôm nay • 14:30',
                    amount: '-245.000đ',
                    icon: Icons.shopping_cart_rounded,
                    isExpense: true,
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionRow(
                    title: 'Starbucks Coffee',
                    subtitle: 'Hôm qua • 09:15',
                    amount: '-65.000đ',
                    icon: Icons.coffee_rounded,
                    isExpense: true,
                    cardColor: cardColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color bg, Color iconColor) {
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {},
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 24, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color bgColor,
    required Color cardColor,
    required Color textPrimary,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 11,
                  color: textPrimary.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: iconColor)),
        ],
      ),
    );
  }

  Widget _buildJarItem({
    required String title,
    required String remaining,
    required String spent,
    required String limit,
    required double percent,
    required Color progressColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(color: iconBg, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textPrimary)),
                      const SizedBox(height: 2),
                      Text(remaining,
                          style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined,
                        size: 18, color: textSecondary),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        size: 18, color: textSecondary),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              backgroundColor:
                  isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEFEFF4),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(spent, style: TextStyle(fontSize: 11, color: textSecondary)),
              Text(limit,
                  style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow({
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    required bool isExpense,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A1840)
                      : const Color(0xFFEEEDFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF4B49EB), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 11, color: textSecondary)),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isExpense
                  ? const Color(0xFFFF5252)
                  : const Color(0xFF00C096),
            ),
          ),
        ],
      ),
    );
  }
}
