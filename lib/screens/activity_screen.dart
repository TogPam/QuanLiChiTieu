import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'notification_screen.dart';

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
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<dynamic> _transactions = [];
  List<dynamic> _jars = [];
  List<dynamic> _categoriesList = [];
  bool _isLoading = true;
  bool _isError = false;
  Timer? _timer;

  List<String> _categories = ['Tất cả'];
  final _monthNames = ['Tháng 1','Tháng 2','Tháng 3','Tháng 4','Tháng 5','Tháng 6',
                       'Tháng 7','Tháng 8','Tháng 9','Tháng 10','Tháng 11','Tháng 12'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _searchCtrl.addListener(() => setState(() => _searchText = _searchCtrl.text));
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchDataSilently());
  }

  Future<void> _fetchDataSilently() async {
    final txs = await ApiService.getTransactions(month: _selectedMonth, year: _selectedYear);
    final jarsData = await ApiService.getJars();
    final cats = await ApiService.getCategories(isIncome: false);
    
    if (mounted && txs != null) {
      setState(() {
        _isError = false;
        _transactions = txs;
        _jars = jarsData ?? [];
        _categoriesList = cats ?? [];
        if (cats != null && cats.isNotEmpty) {
          final names = cats.map((c) => (c['category_name'] ?? c['CategoryName'] ?? '').toString()).where((n) => n.isNotEmpty).toList();
          _categories = ['Tất cả', ...names];
        }
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final txs = await ApiService.getTransactions(month: _selectedMonth, year: _selectedYear);
    final jarsData = await ApiService.getJars();
    final cats = await ApiService.getCategories(isIncome: false);
    
    if (mounted) {
      if (txs != null) {
        setState(() {
          _isError = false;
          _transactions = txs;
          _jars = jarsData ?? [];
          _categoriesList = cats ?? [];
          if (cats != null && cats.isNotEmpty) {
            final names = cats.map((c) => (c['category_name'] ?? c['CategoryName'] ?? '').toString()).where((n) => n.isNotEmpty).toList();
            _categories = ['Tất cả', ...names];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() { 
    _timer?.cancel();
    _ctrl.dispose(); 
    _searchCtrl.dispose(); 
    super.dispose(); 
  }

  List<dynamic> get _filtered => _transactions.where((t) {
    final title = (t['description'] ?? t['Description'] ?? 'Giao dịch').toString().toLowerCase();
    final searchOk = _searchText.isEmpty || title.contains(_searchText.toLowerCase());
    
    final catName = (t['category_name'] ?? t['CategoryName'] ?? 'Khác').toString();
    final categoryOk = _selectedCategory == 'Tất cả' || catName.toLowerCase() == _selectedCategory.toLowerCase();
    
    return searchOk && categoryOk;
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
                  _fetchData();
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
    int? selectedCatId;
    if (_categoriesList.isNotEmpty) {
      selectedCatId = _categoriesList.first['category_id'] as int;
    }
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
                      final isSelected = selectedJarId == (jar['JarId'] ?? jar['jar_id']);
                      final jarName = jar['JarName'] ?? jar['jar_name'] ?? '';
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedJarId = (jar['JarId'] ?? jar['jar_id']) as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? accent : (isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? accent : Colors.transparent, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.account_balance_wallet_rounded, 
                                color: isSelected ? Colors.white : accent, size: 18),
                              const SizedBox(width: 8),
                              Text(jarName, style: TextStyle(
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

                // Chọn Danh mục
                Text('Danh mục chi tiêu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textSecondary)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoriesList.length,
                    itemBuilder: (_, i) {
                      final cat = _categoriesList[i];
                      final catId = cat['category_id'] as int;
                      final catName = cat['category_name'] as String;
                      final isSelected = selectedCatId == catId;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedCatId = catId),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? accent : (isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? accent : Colors.transparent, width: 2),
                          ),
                          child: Center(
                            child: Text(catName, style: TextStyle(
                              color: isSelected ? Colors.white : textPrimary, 
                              fontWeight: FontWeight.w600, fontSize: 13,
                            )),
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
                    onPressed: () async {
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

                      Navigator.pop(ctx);
                      
                      await ApiService.createTransaction(
                        selectedJarId!, 
                        selectedCatId ?? 1, // Sử dụng category đã chọn
                        double.parse(amountStr), 
                        desc, 
                        false, // isIncome
                        null
                      ).then((res) async {
                        if (res != null && selectedImage != null) {
                          await ApiService.uploadTransactionReceipt(res['transaction_id'], selectedImage!.path);
                        }
                      });
                      
                      _fetchData();
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

    if (_isError) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 80, color: textSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('Mất kết nối máy chủ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 8),
              Text('Không thể lấy dữ liệu từ hệ thống', style: TextStyle(color: textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() { _isLoading = true; _isError = false; });
                  _fetchData();
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text('Thử lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1B1A2A) : Colors.white,
        elevation: 0,
        title: Text('Giao Dịch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: textPrimary)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: textPrimary), 
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            }
          )
        ],
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
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(child: Text('Không có giao dịch nào', style: TextStyle(color: textSecondary)))
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: _filtered.map((t) => _txCard(t, cardColor, textPrimary, textSecondary, accent, isDark)).toList(),
                      ),
          ),
        ]),
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

  Widget _txCard(dynamic t, Color cardColor, Color textPrimary, Color textSecondary, Color accent, bool isDark) {
    final isIncome = (t['transaction_type'] ?? t['TransactionType']) == true;
    final amount = double.tryParse(t['amount']?.toString() ?? '0') ?? 0;
    final amountStr = '${isIncome ? "+" : "-"}${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
    final dateStr = (t['transaction_date'] ?? t['TransactionDate'])?.toString().split('T')[0] ?? '';
    final desc = t['description'] ?? t['Description'] ?? 'Giao dịch';
    final catName = t['category_name'] ?? t['CategoryName'] ?? 'Danh mục';

    return GestureDetector(
      onTap: () => _showTransactionDetails(t, isDark, cardColor, textPrimary, textSecondary, accent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            _buildLeading(
              t['receipt_image_url'] ?? t['ReceiptImageUrl'],
              catName,
              isIncome,
              isDark,
              accent,
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(desc, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textPrimary)),
              const SizedBox(height: 2),
              Text('$catName • $dateStr', style: TextStyle(color: textSecondary, fontSize: 11)),
            ])),
            Text(amountStr, style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14,
              color: !isIncome ? const Color(0xFFFF5252) : const Color(0xFF00C096),
            )),
          ],
        ),
      ),
    );
  }

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

  void _showTransactionDetails(dynamic t, bool isDark, Color cardBg, Color textPrimary, Color textSecondary, Color accent) {
    final isIncome = (t['transaction_type'] ?? t['TransactionType']) == true;
    final amount = double.tryParse(t['amount']?.toString() ?? '0') ?? 0;
    final amountStr = '${isIncome ? "+" : "-"}${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
    
    final rawDate = (t['transaction_date'] ?? t['TransactionDate'])?.toString() ?? '';
    var dateStr = '';
    var timeStr = '';
    if (rawDate.isNotEmpty) {
      final parts = rawDate.split('T');
      dateStr = parts[0];
      if (parts.length > 1) {
        timeStr = parts[1].split('.')[0];
      }
    }
    
    final desc = t['description'] ?? t['Description'] ?? 'Giao dịch';
    final catName = t['category_name'] ?? t['CategoryName'] ?? 'Danh mục';
    final jarName = t['jar_name'] ?? t['JarName'] ?? 'Hũ chi tiêu';
    final imageUrl = t['receipt_image_url'] ?? t['ReceiptImageUrl'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(desc, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary)),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(amountStr, style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold,
                  color: isIncome ? const Color(0xFF00C096) : const Color(0xFFFF5252),
                )),
              ),
              const SizedBox(height: 32),
              
              _detailRow('Danh mục', catName, Icons.category_outlined, textPrimary, textSecondary),
              const Divider(height: 24),
              _detailRow('Hũ chi tiêu', jarName, Icons.account_balance_wallet_outlined, textPrimary, textSecondary),
              const Divider(height: 24),
              _detailRow('Ngày giao dịch', dateStr, Icons.calendar_today_outlined, textPrimary, textSecondary),
              const Divider(height: 24),
              _detailRow('Giờ giao dịch', timeStr, Icons.access_time_rounded, textPrimary, textSecondary),
              
              if (imageUrl != null && imageUrl.toString().isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Ảnh hoá đơn', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textSecondary)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showFullImage(imageUrl.toString()),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _fixImageUrl(imageUrl.toString()),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        alignment: Alignment.center,
                        child: Text('Không tải được ảnh', style: TextStyle(color: textSecondary)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon, Color textPrimary, Color textSecondary) {
    return Row(
      children: [
        Icon(icon, size: 20, color: textSecondary),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 15, color: textSecondary)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary)),
      ],
    );
  }

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    return url.replaceAll(
      'http://127.0.0.1:8000',
      'https://projector-captured-locate-gain.trycloudflare.com',
    ).replaceAll('127.0.0.1', '10.0.2.2');
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              _fixImageUrl(imageUrl),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Text('Không tải được ảnh', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(String? imageUrl, String category, bool isIncome, bool isDark, Color accent) {
    final fixedUrl = _fixImageUrl(imageUrl);
    if (fixedUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: fixedUrl,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          placeholder: (ctx, url) =>
              Container(width: 46, height: 46, color: isDark ? Colors.white10 : Colors.grey[200], child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))),
          errorWidget: (ctx, url, err) => _buildFallbackIcon(category, isDark, accent),
        ),
      );
    }
    return _buildFallbackIcon(category, isDark, accent);
  }

  Widget _buildFallbackIcon(String category, bool isDark, Color accent) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1840) : const Color(0xFFEEEDFF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(_iconForCat(category), color: accent, size: 22),
      ),
    );
  }
}
