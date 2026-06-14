import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({Key? key}) : super(key: key);
  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  List<dynamic> _goals = [];
  bool _isLoading = true;

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
    setState(() => _isLoading = true);
    final jars = await ApiService.getJars();
    if (jars != null && mounted) {
      setState(() {
        _goals = jars.map((j) => {
          'id': j['jar_id'] ?? j['JarId'],
          'title': j['jar_name'] ?? j['JarName'] ?? 'Mục tiêu',
          'subtitle': j['description'] ?? j['Description'] ?? 'Mục tiêu tiết kiệm',
          'saved': j['spent_amount'] ?? j['SpentAmount'] ?? 0,
          'target': j['budget'] ?? j['Budget'] ?? 0,
          'days': 30,
          'color': const Color(0xFF4B49EB),
          'icon': Icons.account_balance_wallet_rounded,
        }).toList();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _showNewGoalDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final savedCtrl = TextEditingController();
    final daysCtrl = TextEditingController();
    int selectedIcon = 0;
    int selectedColor = 0;

    const icons = [
      Icons.directions_car_rounded, Icons.flight_takeoff_rounded, Icons.security_rounded,
      Icons.home_rounded, Icons.school_rounded, Icons.shopping_bag_rounded,
      Icons.laptop_mac_rounded, Icons.favorite_rounded,
    ];
    const colors = [
      Color(0xFF4B49EB), Color(0xFF00C096), Color(0xFFE63946),
      Color(0xFFFF7A00), Color(0xFFB5179E), Color(0xFF457B9D),
    ];

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        final bg = isDark ? const Color(0xFF1E1D2E) : Colors.white;
        final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
        final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
        const accent = Color(0xFF4B49EB);

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(color: textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
              Text('Tạo mục tiêu mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 18),
              _field(titleCtrl, 'Tên mục tiêu', Icons.flag_rounded, isDark, textPrimary),
              const SizedBox(height: 12),
              _field(subtitleCtrl, 'Mô tả ngắn', Icons.info_outline_rounded, isDark, textPrimary),
              const SizedBox(height: 12),
              _field(targetCtrl, 'Số tiền cần đạt (đ)', Icons.account_balance_wallet_outlined, isDark, textPrimary,
                  inputType: TextInputType.number),
              const SizedBox(height: 12),
              _field(savedCtrl, 'Đã tích lũy (đ)', Icons.savings_outlined, isDark, textPrimary,
                  inputType: TextInputType.number),
              const SizedBox(height: 12),
              _field(daysCtrl, 'Số ngày còn lại', Icons.timer_outlined, isDark, textPrimary,
                  inputType: TextInputType.number),
              const SizedBox(height: 16),
              Text('Biểu tượng', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
              const SizedBox(height: 10),
              SizedBox(height: 48, child: ListView.builder(
                scrollDirection: Axis.horizontal, itemCount: icons.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setS(() => selectedIcon = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedIcon == i ? accent : (isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icons[i], color: selectedIcon == i ? Colors.white : textSecondary, size: 20),
                  ),
                ),
              )),
              const SizedBox(height: 14),
              Text('Màu sắc', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary)),
              const SizedBox(height: 10),
              SizedBox(height: 36, child: ListView.builder(
                scrollDirection: Axis.horizontal, itemCount: colors.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setS(() => selectedColor = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10), width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: colors[i], shape: BoxShape.circle,
                      border: selectedColor == i ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: selectedColor == i ? [BoxShadow(color: colors[i].withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)] : [],
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  final target = double.tryParse(targetCtrl.text.trim()) ?? 0;
                  Navigator.pop(ctx);
                  
                  // Gọi API tạo mục tiêu
                  await ApiService.createJar(title, target, '1'); // 1 = Personal
                  _fetchData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
                ),
                child: const Text('Tạo mục tiêu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              )),
            ])),
          ),
        );
      }),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon, bool isDark, Color textPrimary,
      {TextInputType inputType = TextInputType.text}) =>
    TextField(
      controller: ctrl, keyboardType: inputType,
      inputFormatters: inputType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : [],
      style: TextStyle(color: textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, size: 20),
        filled: true, fillColor: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0E14) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? const Color(0xFF1E1D2E) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
    const accent = Color(0xFF4B49EB);

    final totalSaved = _goals.fold<double>(0.0, (s, g) => s + double.parse(g['saved'].toString()));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1B1A2A) : Colors.white,
        elevation: 0,
        title: Text('Tiết Kiệm', style: TextStyle(fontWeight: FontWeight.bold, color: accent, fontSize: 20)),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: RefreshIndicator(
            onRefresh: _fetchData,
            color: accent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20), 
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TỔNG TIẾT KIỆM', style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 6),
            Row(children: [
              Text('${totalSaved.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF0D3327) : const Color(0xFFE5F9F4), borderRadius: BorderRadius.circular(10)),
                child: const Text('+12,5%', style: TextStyle(color: Color(0xFF00C096), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ]),
            const SizedBox(height: 24),

            // Nút tạo mục tiêu mới
            GestureDetector(
              onTap: _showNewGoalDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardColor, borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: accent.withValues(alpha: 0.25), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF1A1840) : const Color(0xFFEEEDFF), shape: BoxShape.circle),
                    child: const Icon(Icons.add_rounded, color: accent)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Tạo Mục Tiêu Mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accent)),
                    Text('Đảm bảo tương lai tài chính của bạn', style: TextStyle(color: textSecondary, fontSize: 12)),
                  ])),
                  const Icon(Icons.chevron_right_rounded, color: accent),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // Danh sách mục tiêu
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_goals.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Chưa có mục tiêu nào")))
            else
              ..._goals.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _goalCard(g, cardColor, textPrimary, textSecondary, isDark),
              )),

            // Nhận định tháng này
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1D2E) : const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.12)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Nhận Định Tháng Này', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent)),
                const SizedBox(height: 12),
                Text('Bạn sắp hoàn thành Quỹ Dự Phòng vào tuần tới! Chuyển phần dư sang có thể rút ngắn 22 ngày cho mục tiêu mua xe.',
                    style: TextStyle(color: textPrimary, height: 1.55, fontSize: 14)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), elevation: 0),
                  child: const Text('Tối Ưu Tiết Kiệm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
            ])),
            ),
          ),
        ),
      ),
    );
  }

  Widget _goalCard(dynamic g, Color cardColor, Color textPrimary, Color textSecondary, bool isDark) {
    final Color color = g['color'] as Color;
    final double target = double.parse(g['target'].toString());
    final double saved = double.parse(g['saved'].toString());
    final double percent = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
    final pctLabel = '${(percent * 100).toInt()}%';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor, borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(g['icon'] as IconData, color: color, size: 20)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textPrimary)),
              Text(g['subtitle'] as String, style: TextStyle(color: textSecondary, fontSize: 11)),
            ]),
          ]),
          Stack(alignment: Alignment.center, children: [
            SizedBox(height: 48, width: 48, child: CircularProgressIndicator(
              value: percent, strokeWidth: 4,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            )),
            Text(pctLabel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color)),
          ]),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tiến độ', style: TextStyle(color: textSecondary, fontSize: 10)),
            const SizedBox(height: 2),
            Text('${_formatMoney(saved.toInt())} / ${_formatMoneyShort(target.toInt())}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Thời gian còn lại', style: TextStyle(color: textSecondary, fontSize: 10)),
            const SizedBox(height: 2),
            Text('${g['days']} ngày', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
          ]),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: percent, minHeight: 7,
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          )),
      ]),
    );
  }

  String _formatMoney(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1).replaceAll('.0', '')}Tr';
    return v.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.') + 'đ';
  }

  String _formatMoneyShort(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)}Tr';
    return '${v}đ';
  }
}
