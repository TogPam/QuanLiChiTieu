import 'package:flutter/material.dart';
import 'all_transactions_screen.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../models/jar_model.dart';
import '../services/api_service.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  static bool _hasShownWelcome = false;
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  List<JarModel> _jars = [];
  List<dynamic> _recentTransactions = [];
  List<dynamic> _categories = [];
  double _totalBalance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _savingRate = 0;
  String _userName = 'Bạn';
  bool _isLoading = true;
  bool _isError = false;
  bool _isPrompted = false;
  Timer? _timer;

  final Map<String, int> _jarIconMap = {'1': 0, '2': 1, '3': 2, '4': 3};
  final Map<String, int> _jarColorMap = {'1': 0, '2': 1, '3': 2, '4': 3};

  static const _jarIcons = [
    Icons.restaurant_rounded, Icons.celebration_rounded,
    Icons.school_rounded, Icons.home_work_rounded,
    Icons.shopping_bag_rounded, Icons.directions_car_rounded,
    Icons.medical_services_rounded, Icons.savings_rounded,
  ];

  static const _jarColors = [
    Color(0xFFFF7A00), Color(0xFFB5179E),
    Color(0xFF4361EE), Color(0xFF00C096),
    Color(0xFFE63946), Color(0xFF457B9D),
    Color(0xFFFFAB00), Color(0xFF7B2FBE),
  ];

  static const _jarIconBgLight = [
    Color(0xFFFFE6D5), Color(0xFFF9E5F5),
    Color(0xFFE8ECFF), Color(0xFFE5F9F4),
    Color(0xFFFFECED), Color(0xFFE4EDF5),
    Color(0xFFFFF3CD), Color(0xFFF0E6FF),
  ];

  static const _jarIconBgDark = [
    Color(0xFF3D2208), Color(0xFF35103A),
    Color(0xFF131A3E), Color(0xFF0D3327),
    Color(0xFF3D1212), Color(0xFF0D1E2D),
    Color(0xFF3D2E00), Color(0xFF200D35),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchDataSilently());
  }

  Future<void> _fetchDataSilently() async {
    final dashboardData = await ApiService.getDashboard();
    if (mounted && dashboardData != null) {
      setState(() {
        _isError = false;
        _totalBalance = (dashboardData['total_balance'] ?? 0).toDouble();
        _totalIncome = (dashboardData['total_income'] ?? 0).toDouble();
        _totalExpense = (dashboardData['total_expense'] ?? 0).toDouble();
        _savingRate = (dashboardData['saving_rate'] ?? 0).toDouble();
        final jarsList = dashboardData['jars'] as List<dynamic>? ?? [];
        _jars = jarsList.map((e) => JarModel.fromJson(e)).where((j) => j.jarType != 3).toList();
        _recentTransactions = dashboardData['recent_transactions'] as List<dynamic>? ?? [];
      });

      if (_totalIncome == 0 && _totalExpense == 0 && _recentTransactions.isEmpty && _jars.isNotEmpty && !_isPrompted) {
        _isPrompted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _showInitialBalanceDialog());
      }
    }
  }

  Future<void> _fetchData() async {
    final me = await ApiService.getMe();
    if (me != null && mounted) {
      setState(() => _userName = me['full_name'] ?? 'Bạn');
      if (!_hasShownWelcome) {
        _hasShownWelcome = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _showWelcomePopup(_userName));
      }
    }

    final cats = await ApiService.getCategories(isIncome: false);

    final dashboardData = await ApiService.getDashboard();
    if (mounted && dashboardData != null) {
      setState(() {
        if (cats != null) _categories = cats;
        _totalBalance = (dashboardData['total_balance'] ?? 0).toDouble();
        _totalIncome = (dashboardData['total_income'] ?? 0).toDouble();
        _totalExpense = (dashboardData['total_expense'] ?? 0).toDouble();
        _savingRate = (dashboardData['saving_rate'] ?? 0).toDouble();
        
        final jarsList = dashboardData['jars'] as List<dynamic>? ?? [];
        _jars = jarsList.map((e) => JarModel.fromJson(e)).where((j) => j.jarType != 3).toList();

        _recentTransactions = dashboardData['recent_transactions'] as List<dynamic>? ?? [];
        _isError = false;
        _isLoading = false;
      });

      if (_totalIncome == 0 && _totalExpense == 0 && _recentTransactions.isEmpty && _jars.isNotEmpty && !_isPrompted) {
        _isPrompted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _showInitialBalanceDialog());
      }
    } else {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() { 
    _timer?.cancel();
    _ctrl.dispose(); 
    super.dispose(); 
  }

  void _showWelcomePopup(String name) {
    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF00C096).withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.waving_hand_rounded, color: Color(0xFF00C096), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chào mừng trở lại!', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(name, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2A2940) : Colors.white,
        elevation: 6,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05), width: 1),
        ),
        duration: const Duration(seconds: 4),
      )
    );
  }

  void _showInitialBalanceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountCtrl = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1D2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Số dư đầu tháng', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chào tháng mới! Hãy nhập tổng số dư hiện tại của bạn để bắt đầu theo dõi nhé.', style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 20),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Nhập số tiền (đ)',
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
                filled: true,
                fillColor: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Bỏ qua', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
              if (amount > 0) {
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                
                int catId = 1;
                if (_categories.isNotEmpty) {
                  catId = _categories.first['category_id'] ?? 1;
                }
                
                await ApiService.createTransaction(
                  _jars.first.jarId,
                  catId,
                  amount,
                  'Số dư đầu tháng',
                  true,
                  DateTime.now().toIso8601String(),
                );
                _fetchData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B49EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddJarDialog() => _showJarDialog(null);
  void _showEditJarDialog(JarModel jar) => _showJarDialog(jar);

  void _showJarDialog(JarModel? existing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final titleCtrl = TextEditingController(text: existing?.jarName ?? '');
    final limitCtrl = TextEditingController(text: existing != null ? existing.budget.toInt().toString() : '');
    final spentCtrl = TextEditingController(text: existing != null ? existing.spentAmount.toInt().toString() : '');
    
    int selectedIcon = existing != null ? (_jarIconMap[existing.jarId] ?? 0) : 0;
    int selectedColor = existing != null ? (_jarColorMap[existing.jarId] ?? 0) : 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        final cardColor = isDark ? const Color(0xFF1E1D2E) : Colors.white;
        final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
        final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
        const accent = Color(0xFF4B49EB);

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
                Text(existing == null ? 'Thêm hũ chi tiêu' : 'Chỉnh sửa hũ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                const SizedBox(height: 20),
                _sheetField(titleCtrl, 'Tên hũ (vd: Tiền ăn)', Icons.label_outline_rounded, isDark, textPrimary),
                const SizedBox(height: 14),
                _sheetField(limitCtrl, 'Hạn mức (đ)', Icons.account_balance_wallet_outlined, isDark, textPrimary, inputType: TextInputType.number),
                const SizedBox(height: 18),
                
                Text('Biểu tượng', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _jarIcons.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selectedIcon == i ? accent : (isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_jarIcons[i], color: selectedIcon == i ? Colors.white : textSecondary, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Text('Màu sắc', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _jarColors.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => setModalState(() => selectedColor = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: _jarColors[i],
                          shape: BoxShape.circle,
                          border: selectedColor == i ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: selectedColor == i ? [BoxShadow(color: _jarColors[i].withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)] : [],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      final limit = double.tryParse(limitCtrl.text.trim()) ?? 0;
                      if (title.isEmpty) return;
                      Navigator.pop(ctx);
                      
                      setState(() => _isLoading = true);
                      
                      if (existing == null) {
                        await ApiService.createJar(title, limit, '1');
                      } else {
                        await ApiService.updateJar(existing.jarId, title, limit, existing.jarType.value);
                      }
                      
                      await _fetchData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(existing == null ? 'Thêm hũ' : 'Lưu thay đổi',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showSpendDialog(JarModel jar) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    File? receiptImage;
    int? selectedCatId;
    if (_categories.isNotEmpty) selectedCatId = _categories.first['category_id'] as int;
    const accent = Color(0xFF4B49EB);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        final bg = isDark ? const Color(0xFF1E1D2E) : Colors.white;
        final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
        final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;

        Future<void> pickImage(ImageSource source) async {
          final picker = ImagePicker();
          final picked = await picker.pickImage(source: source, imageQuality: 75);
          if (picked != null) setS(() => receiptImage = File(picked.path));
        }

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 18),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: const Icon(Icons.shopping_bag_outlined, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Chi tiêu từ hũ', style: TextStyle(fontSize: 13, color: textSecondary)),
                      Text(jar.jarName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('Còn lại', style: TextStyle(fontSize: 11, color: textSecondary)),
                    Text(
                      '${jar.remaining.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                          color: jar.remaining > 0 ? const Color(0xFF00C096) : Colors.redAccent),
                    ),
                  ]),
                ]),
                const SizedBox(height: 20),

                _sheetField(descCtrl, 'Mô tả (vd: Mua bánh mì)', Icons.edit_note_rounded, isDark, textPrimary),
                const SizedBox(height: 14),

                Text('Danh mục', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final catId = cat['category_id'] as int;
                      final catName = cat['category_name'] as String;
                      final isSelected = selectedCatId == catId;
                      return GestureDetector(
                        onTap: () => setS(() => selectedCatId = catId),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? accent : (isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(catName, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : textSecondary, fontSize: 13)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                _sheetField(amountCtrl, 'Số tiền (đ)', Icons.payments_outlined, isDark, textPrimary,
                    inputType: TextInputType.number),
                const SizedBox(height: 16),


                Text('Ảnh hóa đơn (tuỳ chọn)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => pickImage(ImageSource.camera),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: accent.withValues(alpha: 0.2)),
                        ),
                        child: receiptImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(receiptImage!, fit: BoxFit.cover))
                            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.camera_alt_outlined, color: accent, size: 28),
                                const SizedBox(height: 6),
                                Text('Chụp ảnh', style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600)),
                              ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => pickImage(ImageSource.gallery),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: accent.withValues(alpha: 0.2)),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.photo_library_outlined, color: textSecondary, size: 28),
                          const SizedBox(height: 6),
                          Text('Thư viện', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Xác nhận chi tiêu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      final desc = descCtrl.text.trim();
                      final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                      if (desc.isEmpty || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hãy nhập mô tả và số tiền hợp lệ'), backgroundColor: Colors.orange));
                        return;
                      }
                      if (amount > jar.remaining) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            backgroundColor: isDark ? const Color(0xFF1E1D2E) : Colors.white,
                            title: Text('Cảnh báo vượt hạn mức', style: TextStyle(color: textPrimary)),
                            content: Text('Số tiền chi (${amount.toInt()}) vượt quá số dư còn lại của hũ (${jar.remaining.toInt()}). Bạn có chắc chắn muốn tiếp tục không?',
                                style: TextStyle(color: textPrimary)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Tiếp tục', style: TextStyle(color: Colors.redAccent))),
                            ],
                          )
                        );
                        if (confirm != true) return;
                      }
                      Navigator.pop(ctx);

                      final result = await ApiService.createTransaction(
                        jar.jarId,
                        selectedCatId ?? 1,
                        amount,
                        desc,
                        false,
                        DateTime.now().toIso8601String(),
                      );

                      if (result != null) {
                        if (receiptImage != null) {
                          await ApiService.uploadTransactionReceipt(result['transaction_id'], receiptImage!.path);
                        }
                        await _fetchData();
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã ghi chi ${amount.toInt()}đ – $desc'),
                            backgroundColor: const Color(0xFF00C096),
                          ));
                      } else {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lỗi khi tạo giao dịch'), backgroundColor: Colors.redAccent));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  void _deleteJar(JarModel jar) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá hũ'),
        content: Text('Xoá hũ "${jar.jarName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          TextButton(
            onPressed: () async { 
              Navigator.pop(ctx); 
              setState(() => _isLoading = true);
              await ApiService.deleteJar(jar.jarId);
              await _fetchData();
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showMembersDialog(JarModel jar) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final members = await ApiService.getJarMembers(jar.jarId) ?? [];
    if (!mounted) return;

    final emailCtrl = TextEditingController();
    const accent = Color(0xFF4B49EB);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        final bg = isDark ? const Color(0xFF1E1D2E) : Colors.white;
        final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
        final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 18),
              Text('Thành viên – ${jar.jarName}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 16),
              ...members.map((m) {
                final name = m['user']?['full_name'] ?? 'Không rõ';
                final email = m['user']?['email'] ?? '';
                final role = m['role'] ?? 'Member';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: accent.withValues(alpha: 0.15),
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: accent, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                  subtitle: Text(email, style: TextStyle(fontSize: 11, color: textSecondary)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: role == 'Owner' ? accent.withValues(alpha: 0.12) : (isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: role == 'Owner' ? accent : textSecondary)),
                  ),
                );
              }).toList(),
              const Divider(height: 28),
              Text('Mời thành viên mới', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textSecondary)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Nhập email người dùng...',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 13),
                      prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final email = emailCtrl.text.trim();
                    if (email.isEmpty) return;
                    final user = await ApiService.findUserByEmail(email);
                    if (user == null) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy người dùng với email này'), backgroundColor: Colors.redAccent));
                      return;
                    }
                    final result = await ApiService.addJarMember(jar.jarId, user['user_id']);
                    if (result != null) {
                      emailCtrl.clear();
                      final updated = await ApiService.getJarMembers(jar.jarId) ?? [];
                      setS(() { members.clear(); members.addAll(updated); });
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã mời ${user['full_name']} vào hũ!'), backgroundColor: const Color(0xFF00C096)));
                    } else {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Người này đã là thành viên hoặc có lỗi xảy ra'), backgroundColor: Colors.orange));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Mời', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ]),
            ]),
          ),
        );
      }),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String hint, IconData icon, bool isDark, Color textPrimary,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: inputType,
      inputFormatters: inputType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : [],
      style: TextStyle(color: textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0E14) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E1D2E) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF2C2C2C);
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93);
    final iconBtnBg = isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7);
    const accent = Color(0xFF4B49EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 80, color: textSecondary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('Mất kết nối máy chủ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Không thể lấy dữ liệu từ hệ thống.\nVui lòng kiểm tra kết nối và thử lại.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textSecondary, height: 1.5)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() { _isLoading = true; _isError = false; });
                      _fetchData();
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: const Text('Thử lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: RefreshIndicator(
              onRefresh: _fetchData,
              color: accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: const CircleAvatar(radius: 24,
                          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Xin chào, $_userName 👋',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary)),
                          Text('Thứ Ba, 10 Tháng 6',
                              style: TextStyle(fontSize: 12, color: textSecondary)),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      _iconBtn(Icons.notifications_none_rounded, iconBtnBg, textPrimary, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Thẻ số dư
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF5D5BF7), Color(0xFF3B39E0)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 12))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('TỔNG SỐ DƯ HIỆN TẠI',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1.2)),
                      const SizedBox(height: 10),
                      Text('${_totalBalance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text('${_savingRate > 0 ? "+" : ""}${_savingRate}% tiết kiệm', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Quick stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _quickStat(context, Icons.trending_up_rounded, 'Thu nhập', '+${(_totalIncome/1000000).toStringAsFixed(1)}Tr', const Color(0xFF00C096), isDark ? const Color(0xFF0D3327) : const Color(0xFFE6F9F3), cardColor, textPrimary),
                      _quickStat(context, Icons.trending_down_rounded, 'Chi tiêu', '-${(_totalExpense/1000000).toStringAsFixed(1)}Tr', const Color(0xFFFF5252), isDark ? const Color(0xFF3D1212) : const Color(0xFFFFF0F0), cardColor, textPrimary),
                      _quickStat(context, Icons.account_balance_wallet_rounded, 'Tiết kiệm', '${(_savingRate)}%', accent, isDark ? const Color(0xFF1A1840) : const Color(0xFFEEEDFF), cardColor, textPrimary),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Hũ chi tiêu header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quản lý Hũ Chi Tiêu',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                      GestureDetector(
                        onTap: _showAddJarDialog,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: accent, shape: BoxShape.circle),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Danh sách hũ
                  ..._jars.map((jar) {
                    int cIndex = _jarColorMap[jar.jarId] ?? 0;
                    int iIndex = _jarIconMap[jar.jarId] ?? 0;
                    
                    final col = _jarColors[cIndex % _jarColors.length];
                    final iconBg = isDark ? _jarIconBgDark[cIndex % _jarIconBgDark.length] : _jarIconBgLight[cIndex % _jarIconBgLight.length];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _jarCard(jar, col, iconBg, iIndex, cardColor, textPrimary, textSecondary, isDark),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Giao dịch gần đây
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Giao dịch gần đây',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AllTransactionsScreen()));
                        },
                        child: const Text('Xem tất cả', style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_recentTransactions.isEmpty)
                    Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Chưa có giao dịch", style: TextStyle(color: textSecondary)))),
                  ..._recentTransactions.map((tx) {
                    final isIncome = (tx['transaction_type'] ?? tx['TransactionType']) == true;
                    final amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0;
                    final amountStr = '${isIncome ? "+" : "-"}${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
                    final dateStr = (tx['transaction_date'] ?? tx['TransactionDate'])?.toString().split('T')[0] ?? '';
                    final desc = tx['description'] ?? tx['Description'] ?? 'Giao dịch';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _txRow(desc, dateStr, amountStr, isIncome ? Icons.trending_up_rounded : Icons.shopping_cart_rounded, !isIncome, cardColor, textPrimary, textSecondary, isDark),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _iconBtn(IconData icon, Color bg, Color col, {VoidCallback? onTap}) => Material(
    color: bg, shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap ?? () {},
      customBorder: const CircleBorder(),
      child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, size: 24, color: col)),
    ),
  );

  Widget _quickStat(BuildContext context, IconData icon, String title, String value,
      Color iconColor, Color bgColor, Color cardColor, Color textPrimary) =>
    Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 11, color: textPrimary.withValues(alpha: 0.55), fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: iconColor)),
      ]),
    );

  // 5. Cập nhật các biến getter vào hàm vẽ Card
  Widget _jarCard(JarModel jar, Color col, Color iconBg, int iconIndex, Color cardColor,
      Color textPrimary, Color textSecondary, bool isDark) {
    final remaining = jar.remaining;
    final remainStr = remaining >= 0
        ? 'Còn ${remaining.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ'
        : 'Vượt ${(-remaining).toInt()}đ';
    final spentStr = 'Đã dùng ${jar.spentAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
    final limitStr = 'Hạn mức ${jar.budget.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor, borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(_jarIcons[iconIndex % _jarIcons.length], color: col, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(jar.jarName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary)),
                const SizedBox(height: 2),
                Text(remainStr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500)),
              ]),
            ),
            Row(children: [
              // 💸 Chi tiêu
              GestureDetector(
                onTap: () => _showSpendDialog(jar),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B49EB).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.remove_circle_outline_rounded, size: 14, color: Color(0xFF4B49EB)),
                    const SizedBox(width: 4),
                    const Text('Chi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B49EB))),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showMembersDialog(jar),
                child: Icon(Icons.group_outlined, size: 18, color: textSecondary),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => _showEditJarDialog(jar),
                child: Icon(Icons.edit_outlined, size: 18, color: textSecondary),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => _deleteJar(jar),
                child: Icon(Icons.delete_outline_rounded, size: 18, color: textSecondary),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: jar.usagePercent,
            valueColor: AlwaysStoppedAnimation<Color>(col),
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEFEFF4),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(spentStr, style: TextStyle(fontSize: 11, color: textSecondary)),
            Text(limitStr, style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
      ]),
    );
  }

  Widget _txRow(String title, String sub, String amount, IconData icon, bool isExpense,
      Color cardColor, Color textPrimary, Color textSecondary, bool isDark) =>
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1840) : const Color(0xFFEEEDFF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4B49EB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 2),
              Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: textSecondary)),
            ]),
          ),
          const SizedBox(width: 8),
          Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
              color: isExpense ? const Color(0xFFFF5252) : const Color(0xFF00C096))),
        ],
      ),
    );
}