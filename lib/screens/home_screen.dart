import 'package:flutter/material.dart';
import 'all_transactions_screen.dart';
import 'package:flutter/services.dart';
import '../models/jar_model.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // 1. Danh sách Hũ và Dữ liệu sẽ được load từ API
  List<JarModel> _jars = [];
  List<dynamic> _recentTransactions = [];
  double _totalBalance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _savingRate = 0;
  String _userName = 'Bạn';
  bool _isLoading = true;

  // 2. Tách Icon và Color ra quản lý riêng ở UI (Vì Database chưa có 2 cột này)
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
  }

  Future<void> _fetchData() async {
    final me = await ApiService.getMe();
    if (me != null && mounted) {
      setState(() => _userName = me['full_name'] ?? 'Bạn');
    }

    final dashboardData = await ApiService.getDashboard();
    if (mounted && dashboardData != null) {
      setState(() {
        _totalBalance = (dashboardData['total_balance'] ?? 0).toDouble();
        _totalIncome = (dashboardData['total_income'] ?? 0).toDouble();
        _totalExpense = (dashboardData['total_expense'] ?? 0).toDouble();
        _savingRate = (dashboardData['saving_rate'] ?? 0).toDouble();
        
        final jarsList = dashboardData['jars'] as List<dynamic>? ?? [];
        _jars = jarsList.map((e) => JarModel.fromJson(e)).toList();

        _recentTransactions = dashboardData['recent_transactions'] as List<dynamic>? ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // ─── Jar CRUD ──────────────────────────────────────────────────────────
  void _showAddJarDialog() => _showJarDialog(null);
  void _showEditJarDialog(JarModel jar) => _showJarDialog(jar);

  void _showJarDialog(JarModel? existing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 3. Cập nhật ánh xạ tên biến mới từ Model
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
                const SizedBox(height: 14),
                _sheetField(spentCtrl, 'Đã chi tiêu (đ)', Icons.payments_outlined, isDark, textPrimary, inputType: TextInputType.number),
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
                      final spent = double.tryParse(spentCtrl.text.trim()) ?? 0;
                      if (title.isEmpty) return;
                      Navigator.pop(ctx);
                      
                      setState(() => _isLoading = true);
                      
                      if (existing == null) {
                        // Thêm mới qua API
                        await ApiService.createJar(title, limit, '1'); // 1 = Personal
                      } else {
                        // Cập nhật qua API
                        await ApiService.updateJar(existing.jarId, title, limit, existing.jarType.value.toString());
                      }
                      
                      // Load lại dữ liệu
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
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
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
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Xin chào, $_userName 👋',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary)),
                          Text('Thứ Ba, 10 Tháng 6',
                              style: TextStyle(fontSize: 12, color: textSecondary)),
                        ]),
                      ]),
                      _iconBtn(Icons.notifications_none_rounded, iconBtnBg, textPrimary),
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
    );
  }

  Widget _iconBtn(IconData icon, Color bg, Color col) => Material(
    color: bg, shape: const CircleBorder(),
    child: InkWell(
      onTap: () {},
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(_jarIcons[iconIndex % _jarIcons.length], color: col, size: 20),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(jar.jarName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPrimary)),
                const SizedBox(height: 2),
                Text(remainStr, style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500)),
              ]),
            ]),
            Row(children: [
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 18, color: textSecondary),
                onPressed: () => _showEditJarDialog(jar),
                constraints: const BoxConstraints(), padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 18, color: textSecondary),
                onPressed: () => _deleteJar(jar),
                constraints: const BoxConstraints(), padding: EdgeInsets.zero,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1840) : const Color(0xFFEEEDFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4B49EB), size: 20),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(fontSize: 11, color: textSecondary)),
            ]),
          ]),
          Text(amount, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
              color: isExpense ? const Color(0xFFFF5252) : const Color(0xFF00C096))),
        ],
      ),
    );
}