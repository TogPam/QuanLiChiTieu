import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Tất cả';
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchText = '';

  // Tháng hiện tại
  int _selectedMonth = 6;
  int _selectedYear = 2025;

  final List<Map<String, dynamic>> _transactions = [
    {'title': 'Tiệm bánh mì Như Lan', 'category': 'Ăn uống', 'time': '09:12 SA', 'date': 'Hôm nay', 'amount': '-32.000', 'isExpense': true},
    {'title': 'Lương tháng 6', 'category': 'Thu nhập', 'time': '08:00 SA', 'date': 'Hôm nay', 'amount': '+8.000.000', 'isExpense': false},
    {'title': 'Netflix', 'category': 'Giải trí', 'time': '11:45 CH', 'date': 'Hôm qua', 'amount': '-180.000', 'isExpense': true},
    {'title': 'Khoá học Udemy', 'category': 'Học tập', 'time': '02:30 CH', 'date': 'Hôm qua', 'amount': '-450.000', 'isExpense': true},
    {'title': 'Tiền thuê phòng', 'category': 'Tiền nhà', 'time': '10:00 SA', 'date': 'Hôm qua', 'amount': '-3.500.000', 'isExpense': true},
    {'title': 'Siêu thị Vinmart', 'category': 'Ăn uống', 'time': '05:10 CH', 'date': 'Chủ nhật', 'amount': '-215.000', 'isExpense': true},
  ];

  final _categories = ['Tất cả', 'Ăn uống', 'Thu nhập', 'Giải trí', 'Học tập', 'Tiền nhà'];
  final _monthNames = ['Tháng 1','Tháng 2','Tháng 3','Tháng 4','Tháng 5','Tháng 6',
                       'Tháng 7','Tháng 8','Tháng 9','Tháng 10','Tháng 11','Tháng 12'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _searchCtrl.addListener(() => setState(() => _searchText = _searchCtrl.text));
  }

  @override
  void dispose() { _ctrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  List<Map<String, dynamic>> get _filtered => _transactions.where((t) {
    final catOk = _selectedCategory == 'Tất cả' || t['category'] == _selectedCategory;
    final searchOk = _searchText.isEmpty ||
        (t['title'] as String).toLowerCase().contains(_searchText.toLowerCase());
    return catOk && searchOk;
  }).toList();

  void _showMonthPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        final cardBg = isDark ? const Color(0xFF1E1D2E) : Colors.white;
        final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
        final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
        const accent = Color(0xFF4B49EB);

        return Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(color: textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            Text('Chọn tháng & năm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
            const SizedBox(height: 20),
            // Năm
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                icon: Icon(Icons.chevron_left_rounded, color: textPrimary),
                onPressed: () => setS(() => tempYear--),
              ),
              Text('$tempYear', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded, color: textPrimary),
                onPressed: () => setS(() => tempYear++),
              ),
            ]),
            const SizedBox(height: 12),
            // Tháng grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 2.2, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: 12,
              itemBuilder: (_, i) {
                final sel = i + 1 == tempMonth;
                return GestureDetector(
                  onTap: () => setS(() => tempMonth = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: sel ? accent : (isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('T${i + 1}', style: TextStyle(fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : textSecondary, fontSize: 13)),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() { _selectedMonth = tempMonth; _selectedYear = tempYear; });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                ),
                child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ]),
        );
      }),
    );
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
        title: Text('Giao Dịch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: textPrimary)),
        actions: [IconButton(icon: Icon(Icons.notifications_none_rounded, color: textPrimary), onPressed: () {})],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(children: [
          // Tìm kiếm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giao dịch...',
                hintStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { _searchCtrl.clear(); setState(() => _searchText = ''); })
                    : null,
                filled: true, fillColor: searchBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Chọn tháng
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_month_rounded, color: accent, size: 18),
                  const SizedBox(width: 6),
                  Text('${_monthNames[_selectedMonth - 1]}, $_selectedYear',
                      style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
                ]),
                TextButton(
                  onPressed: _showMonthPicker,
                  child: const Text('Thay đổi', style: TextStyle(color: accent)),
                ),
              ],
            ),
          ),

          // Bộ lọc danh mục
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final sel = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? accent : (isDark ? const Color(0xFF1E1D2E) : const Color(0xFFF2F2F7)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(cat, style: TextStyle(
                        color: sel ? Colors.white : (isDark ? Colors.white54 : Colors.black45),
                        fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                );
              },
            ),
          ),

          // Danh sách giao dịch nhóm theo ngày
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('Không có giao dịch nào', style: TextStyle(color: textSecondary)))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final dateGroup in ['Hôm nay', 'Hôm qua', 'Chủ nhật']) ...[
                        _buildDateHeading(dateGroup, textPrimary, textSecondary),
                        ..._filtered.where((t) => t['date'] == dateGroup).map((t) =>
                          _txCard(t, cardColor, textPrimary, textSecondary, accent, isDark)),
                      ]
                    ],
                  ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: accent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildDateHeading(String date, Color textPrimary, Color textSecondary) {
    final items = _filtered.where((t) => t['date'] == date).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(date, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary)),
    );
  }

  Widget _txCard(Map t, Color cardColor, Color textPrimary, Color textSecondary, Color accent, bool isDark) =>
    Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1840) : const Color(0xFFEEEEFF),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconForCat(t['category']), color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
            const SizedBox(height: 2),
            Text('${t['category']} • ${t['time']}', style: TextStyle(color: textSecondary, fontSize: 11)),
          ])),
          Text('${t['amount']}đ', style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14,
            color: (t['isExpense'] as bool) ? const Color(0xFFFF5252) : const Color(0xFF00C096),
          )),
        ],
      ),
    );

  IconData _iconForCat(String cat) {
    switch (cat) {
      case 'Ăn uống': return Icons.restaurant_rounded;
      case 'Thu nhập': return Icons.payments_rounded;
      case 'Giải trí': return Icons.celebration_rounded;
      case 'Học tập': return Icons.school_rounded;
      case 'Tiền nhà': return Icons.home_rounded;
      default: return Icons.credit_card_rounded;
    }
  }
}
