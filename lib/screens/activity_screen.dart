import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Tất cả';
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Tiệm bánh mì Như Lan',
      'category': 'Ăn uống',
      'time': '09:12 SA',
      'date': 'Hôm nay',
      'amount': '-32.000',
      'isExpense': true,
    },
    {
      'title': 'Lương tháng 6',
      'category': 'Thu nhập',
      'time': '08:00 SA',
      'date': 'Hôm nay',
      'amount': '+8.000.000',
      'isExpense': false,
    },
    {
      'title': 'Netflix',
      'category': 'Giải trí',
      'time': '11:45 CH',
      'date': 'Hôm qua',
      'amount': '-180.000',
      'isExpense': true,
    },
    {
      'title': 'Khoá học Udemy',
      'category': 'Học tập',
      'time': '02:30 CH',
      'date': 'Hôm qua',
      'amount': '-450.000',
      'isExpense': true,
    },
    {
      'title': 'Tiền thuê phòng',
      'category': 'Tiền nhà',
      'time': '10:00 SA',
      'date': 'Hôm qua',
      'amount': '-3.500.000',
      'isExpense': true,
    },
    {
      'title': 'Siêu thị Vinmart',
      'category': 'Ăn uống',
      'time': '05:10 CH',
      'date': 'Chủ nhật',
      'amount': '-215.000',
      'isExpense': true,
    },
  ];

  final _categories = ['Tất cả', 'Ăn uống', 'Giải trí', 'Học tập', 'Tiền nhà'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
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
    final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
    final searchBg = isDark ? const Color(0xFF1E1D2E) : const Color(0xFFF2F2F7);
    const accent = Color(0xFF4B49EB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1B1A2A) : Colors.white,
        elevation: 0,
        title: Text(
          'Giao Dịch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: textPrimary,
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
        child: Column(
          children: [
            // ── Tìm kiếm ────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: TextField(
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm giao dịch...',
                  hintStyle: TextStyle(color: textSecondary),
                  prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
                  filled: true,
                  fillColor: searchBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // ── Tháng ─────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          color: accent, size: 18),
                      const SizedBox(width: 6),
                      Text('Tháng 6, 2025',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPrimary)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Thay đổi',
                        style: TextStyle(color: accent)),
                  ),
                ],
              ),
            ),

            // ── Bộ lọc danh mục ────────────────────────────────────────
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (_, i) =>
                    _buildFilterPill(_categories[i], isDark, accent),
              ),
            ),
            const SizedBox(height: 12),

            // ── Danh sách giao dịch ─────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDateHeading('Hôm nay', '10/6', textPrimary,
                      textSecondary),
                  ..._buildFilteredItems('Hôm nay', cardColor, textPrimary,
                      textSecondary, isDark),
                  _buildDateHeading('Hôm qua', '9/6', textPrimary,
                      textSecondary),
                  ..._buildFilteredItems('Hôm qua', cardColor, textPrimary,
                      textSecondary, isDark),
                  _buildDateHeading('Chủ nhật', '8/6', textPrimary,
                      textSecondary),
                  ..._buildFilteredItems('Chủ nhật', cardColor, textPrimary,
                      textSecondary, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: accent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterPill(String title, bool isDark, Color accent) {
    final bool isSelected = _selectedCategory == title;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = title),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? accent
                : (isDark
                    ? const Color(0xFF1E1D2E)
                    : const Color(0xFFF2F2F7)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white54 : Colors.black45),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeading(
      String date, String shortDate, Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textPrimary)),
          Text(shortDate,
              style: TextStyle(color: textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredItems(String date, Color cardColor,
      Color textPrimary, Color textSecondary, bool isDark) {
    return _transactions
        .where((t) =>
            t['date'] == date &&
            (_selectedCategory == 'Tất cả' ||
                t['category'] == _selectedCategory))
        .map<Widget>((t) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                              : const Color(0xFFEEEEFF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForCategory(t['category']),
                          color: const Color(0xFF4B49EB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['title'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textPrimary)),
                          const SizedBox(height: 2),
                          Text('${t['category']} • ${t['time']}',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '${t['amount']}đ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: t['isExpense']
                          ? const Color(0xFFFF5252)
                          : const Color(0xFF00C096),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant_rounded;
      case 'Giải trí':
        return Icons.celebration_rounded;
      case 'Học tập':
        return Icons.school_rounded;
      case 'Tiền nhà':
        return Icons.home_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }
}
