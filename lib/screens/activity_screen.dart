import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';


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

  final List<Map<String, dynamic>> _jars = [
    {'id': '1', 'name': 'Tiền ăn', 'icon': Icons.restaurant_rounded, 'color': const Color(0xFFFF7A00)},
    {'id': '2', 'name': 'Đi chơi', 'icon': Icons.celebration_rounded, 'color': const Color(0xFFB5179E)},
    {'id': '3', 'name': 'Học tập', 'icon': Icons.school_rounded, 'color': const Color(0xFF4361EE)},
    {'id': '4', 'name': 'Tiền nhà', 'icon': Icons.home_work_rounded, 'color': const Color(0xFF00C096)},
  ];

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

  void _showAddTransactionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String? selectedJarId;
    File? selectedImage;
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        final cardColor = isDark ? const Color(0xFF1E1D2E) : Colors.white;
        final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
        final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
        const accent = Color(0xFF4B49EB);

        Future<void> pickImage() async {
          try {
            final pickedFile = await picker.pickImage(source: ImageSource.camera);
            if (pickedFile != null) {
              setModalState(() {
                selectedImage = File(pickedFile.path);
              });
            }
          } catch (e) {
            debugPrint("Image picker error: $e");
          }
        }

        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Thêm giao dịch mới',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                const SizedBox(height: 20),
                
                // Nhập số tiền
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Số tiền (đ)',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400]),
                    prefixIcon: const Icon(Icons.monetization_on_outlined, size: 22),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Chọn Hũ
                Text('Chọn hũ chi tiêu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textSecondary)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _jars.length,
                    itemBuilder: (_, i) {
                      final jar = _jars[i];
                      final isSelected = selectedJarId == jar['id'];
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedJarId = jar['id'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? jar['color'] : (isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? (jar['color'] as Color) : Colors.transparent, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(jar['icon'] as IconData, 
                                color: isSelected ? Colors.white : (jar['color'] as Color), size: 18),
                              const SizedBox(width: 8),
                              Text(jar['name'] as String, style: TextStyle(
                                color: isSelected ? Colors.white : textPrimary, 
                                fontWeight: FontWeight.w600, fontSize: 13,
                              )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Nhập mô tả
                TextField(
                  controller: descCtrl,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Mô tả chi tiết...',
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(Icons.description_outlined, size: 20),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Chụp ảnh
                Text('Ảnh hoá đơn / sản phẩm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textSecondary)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white24 : Colors.grey[300]!, style: BorderStyle.solid),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(selectedImage!, fit: BoxFit.cover, width: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: textSecondary, size: 32),
                              const SizedBox(height: 8),
                              Text('Chạm để chụp ảnh', style: TextStyle(color: textSecondary, fontSize: 13)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final amountStr = amountCtrl.text.trim();
                      final desc = descCtrl.text.trim();
                      
                      if (amountStr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số tiền')));
                        return;
                      }
                      if (selectedJarId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn hũ chi tiêu')));
                        return;
                      }

                      // Tạo mock data cho transaction mới
                      final selectedJar = _jars.firstWhere((j) => j['id'] == selectedJarId);
                      
                      setState(() {
                        _transactions.insert(0, {
                          'title': desc.isNotEmpty ? desc : 'Giao dịch mới',
                          'category': selectedJar['name'],
                          'time': 'Vừa xong',
                          'date': 'Hôm nay',
                          'amount': '-$amountStr',
                          'isExpense': true,
                        });
                      });

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thêm giao dịch thành công!')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Thêm giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
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
        onPressed: _showAddTransactionSheet,
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
