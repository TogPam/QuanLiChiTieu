// screens/all_transactions_screen.dart
import 'package:flutter/material.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  String _selectedCategory = 'Tất cả';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchText = '';

  final List<Map<String, dynamic>> _allTransactions = [
    {'title': 'Tiệm bánh mì Như Lan', 'category': 'Ăn uống', 'time': '09:12 SA', 'date': '11/06/2025', 'amount': -32000, 'isExpense': true},
    {'title': 'Lương tháng 6', 'category': 'Thu nhập', 'time': '08:00 SA', 'date': '11/06/2025', 'amount': 8000000, 'isExpense': false},
    {'title': 'Netflix', 'category': 'Giải trí', 'time': '11:45 CH', 'date': '10/06/2025', 'amount': -180000, 'isExpense': true},
    {'title': 'Khoá học Udemy', 'category': 'Học tập', 'time': '02:30 CH', 'date': '10/06/2025', 'amount': -450000, 'isExpense': true},
    {'title': 'Tiền thuê phòng', 'category': 'Tiền nhà', 'time': '10:00 SA', 'date': '09/06/2025', 'amount': -3500000, 'isExpense': true},
    {'title': 'Siêu thị Vinmart', 'category': 'Ăn uống', 'time': '05:10 CH', 'date': '08/06/2025', 'amount': -215000, 'isExpense': true},
    {'title': 'Thưởng dự án', 'category': 'Thu nhập', 'time': '03:00 CH', 'date': '07/06/2025', 'amount': 2000000, 'isExpense': false},
    {'title': 'Cà phê Highlands', 'category': 'Ăn uống', 'time': '08:30 SA', 'date': '07/06/2025', 'amount': -65000, 'isExpense': true},
    {'title': 'Đổ xăng', 'category': 'Di chuyển', 'time': '07:00 SA', 'date': '06/06/2025', 'amount': -120000, 'isExpense': true},
    {'title': 'Mua sách lập trình', 'category': 'Học tập', 'time': '04:00 CH', 'date': '05/06/2025', 'amount': -250000, 'isExpense': true},
    {'title': 'Điện tháng 6', 'category': 'Tiện ích', 'time': '09:00 SA', 'date': '04/06/2025', 'amount': -380000, 'isExpense': true},
    {'title': 'Internet FPT', 'category': 'Tiện ích', 'time': '09:00 SA', 'date': '04/06/2025', 'amount': -250000, 'isExpense': true},
    {'title': 'Xem phim rạp', 'category': 'Giải trí', 'time': '07:30 CH', 'date': '03/06/2025', 'amount': -170000, 'isExpense': true},
    {'title': 'Grab đi làm', 'category': 'Di chuyển', 'time': '08:00 SA', 'date': '02/06/2025', 'amount': -45000, 'isExpense': true},
  ];

  final _categories = ['Tất cả', 'Ăn uống', 'Thu nhập', 'Giải trí', 'Học tập', 'Tiền nhà', 'Di chuyển', 'Tiện ích'];

  List<Map<String, dynamic>> get _filtered {
    return _allTransactions.where((t) {
      final catOk = _selectedCategory == 'Tất cả' || t['category'] == _selectedCategory;
      final searchOk = _searchText.isEmpty ||
          (t['title'] as String).toLowerCase().contains(_searchText.toLowerCase());
      return catOk && searchOk;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _grouped {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final t in _filtered) {
      (map[t['date']] ??= []).add(t);
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _searchCtrl.addListener(() => setState(() => _searchText = _searchCtrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatAmount(int amount) {
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '+';
    if (abs >= 1000000) {
      return '$sign${(abs / 1000000).toStringAsFixed(1).replaceAll('.0', '')}Tr';
    }
    if (abs >= 1000) {
      final s = abs.toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
        buf.write(s[i]);
      }
      return '$sign${buf}đ';
    }
    return '$sign${abs}đ';
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

    final grouped = _grouped;
    final dates = grouped.keys.toList();

    // totals
    final totalIncome = _filtered
        .where((t) => !t['isExpense'])
        .fold<int>(0, (s, t) => s + (t['amount'] as int));
    final totalExpense = _filtered
        .where((t) => t['isExpense'])
        .fold<int>(0, (s, t) => s + (t['amount'] as int).abs());

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1B1A2A) : Colors.white,
        elevation: 0,
        title: Text('Tất Cả Giao Dịch',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: textPrimary)),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // Tóm tắt
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _summaryChip('Thu nhập', '+${_formatAmount(totalIncome)}', const Color(0xFF00C096)),
                  Container(width: 1, height: 32, color: textSecondary.withValues(alpha: 0.2)),
                  _summaryChip('Chi tiêu', '-${_formatAmount(totalExpense)}', const Color(0xFFFF5252)),
                  Container(width: 1, height: 32, color: textSecondary.withValues(alpha: 0.2)),
                  _summaryChip('Giao dịch', '${_filtered.length}', accent, textSecondary: textSecondary),
                ],
              ),
            ),

            // Tìm kiếm
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm giao dịch...',
                  hintStyle: TextStyle(color: textSecondary),
                  prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchText = '');
                          },
                        )
                      : null,
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

            // Bộ lọc
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final sel = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? accent : (isDark ? const Color(0xFF1E1D2E) : const Color(0xFFF2F2F7)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(cat,
                          style: TextStyle(
                            color: sel ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          )),
                    ),
                  );
                },
              ),
            ),

            // Danh sách giao dịch
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text('Không có giao dịch nào',
                          style: TextStyle(color: textSecondary, fontSize: 15)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: dates.length,
                      itemBuilder: (ctx, di) {
                        final date = dates[di];
                        final txList = grouped[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(date,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: textPrimary)),
                            ),
                            ...txList.map((t) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1A1840) : const Color(0xFFEEEDFF),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(_iconForCat(t['category']),
                                            color: accent, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(t['title'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: textPrimary)),
                                            const SizedBox(height: 2),
                                            Text('${t['category']} • ${t['time']}',
                                                style: TextStyle(fontSize: 11, color: textSecondary)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        _formatAmount(t['amount'] as int),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: (t['isExpense'] as bool)
                                              ? const Color(0xFFFF5252)
                                              : const Color(0xFF00C096),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color valueColor, {Color? textSecondary}) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: valueColor)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: textSecondary ?? const Color(0xFF9CA3AF))),
      ],
    );
  }

  IconData _iconForCat(String cat) {
    switch (cat) {
      case 'Ăn uống': return Icons.restaurant_rounded;
      case 'Thu nhập': return Icons.payments_rounded;
      case 'Giải trí': return Icons.celebration_rounded;
      case 'Học tập': return Icons.school_rounded;
      case 'Tiền nhà': return Icons.home_rounded;
      case 'Di chuyển': return Icons.directions_car_rounded;
      case 'Tiện ích': return Icons.bolt_rounded;
      default: return Icons.credit_card_rounded;
    }
  }
}
