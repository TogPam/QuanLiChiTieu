import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/api_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  double _savingRate = 0;
  double _totalExpense = 0;
  int _totalJarsCount = 0;
  bool _isLoading = true;

  List<dynamic> _jars = [];
  List<dynamic> _monthlySummaries = [];
  List<dynamic> _categoriesData = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final db = await ApiService.getDashboard();
    final summaries = await ApiService.getMonthlySummary(DateTime.now().year);
    final txs = await ApiService.getTransactions(month: DateTime.now().month, year: DateTime.now().year, limit: 500);

    if (mounted) {
      setState(() {
         if (db != null) {
           _savingRate = (db['saving_rate'] ?? 0).toDouble();
           _totalExpense = (db['total_expense'] ?? 0).toDouble();
           _jars = db['jars'] as List<dynamic>? ?? [];
           _totalJarsCount = _jars.length;
         }
         _monthlySummaries = summaries ?? [];

         // Group transactions by category
         if (txs != null) {
           final Map<String, Map<String, dynamic>> catMap = {};
           for (var t in txs) {
             final isIncome = t['transaction_type'] == true || t['TransactionType'] == true;
             if (isIncome) continue; // Only expense
             final catName = t['category_name'] ?? t['CategoryName'] ?? 'Khác';
             final amount = double.tryParse(t['amount']?.toString() ?? '0') ?? 0;
             if (!catMap.containsKey(catName)) {
               catMap[catName] = {'name': catName, 'amount': 0.0, 'count': 0};
             }
             catMap[catName]!['amount'] += amount;
             catMap[catName]!['count'] += 1;
           }
           _categoriesData = catMap.values.toList();
           _categoriesData.sort((a, b) => b['amount'].compareTo(a['amount']));
         }

         _isLoading = false;
      });
    }
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
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93);
    const accent = Color(0xFF4B49EB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1B1A2A) : Colors.white,
        elevation: 0,
        title: Text(
          'Phân Tích',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: accent,
            fontSize: 20,
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phân Tích Tài Chính',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đánh giá chi tiêu của bạn – Tháng ${DateTime.now().month}/${DateTime.now().year}',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 20),

                // ── Biểu đồ Donut – Phân bổ hũ ───────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân Bổ Hũ Chi Tiêu',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 160,
                            width: 160,
                            child: CustomPaint(
                              painter: DonutChartPainter(isDark: isDark, jars: _jars),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$_totalJarsCount',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary),
                                    ),
                                    Text(
                                      'TỔNG HŨ',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: textSecondary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 3.5,
                        children: _jars.isEmpty ? [
                          _buildLegendItem(color: const Color(0xFF4B49EB), label: 'Chưa có dữ liệu', textSecondary: textSecondary)
                        ] : _jars.take(4).toList().asMap().entries.map((e) {
                          final idx = e.key;
                          final j = e.value;
                          final total = _jars.fold(0.0, (s, x) => s + (x['budget'] ?? x['TargetAmount'] ?? 0));
                          final budget = (j['budget'] ?? j['TargetAmount'] ?? 0).toDouble();
                          final pct = total > 0 ? (budget / total * 100).toInt() : 0;
                          final name = j['jar_name'] ?? j['JarName'] ?? '';
                          final colors = [const Color(0xFF4B49EB), const Color(0xFF00C096), const Color(0xFFE63946), const Color(0xFF457B9D)];
                          return _buildLegendItem(color: colors[idx % colors.length], label: '$name ($pct%)', textSecondary: textSecondary);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Banner tỉ lệ tiết kiệm ────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C49F), Color(0xFF00A381)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C49F).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TỈ LỆ TIẾT KIỆM THÁNG NÀY',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_savingRate}%',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Text('+2,1% ↑',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                          Icon(Icons.auto_graph_outlined,
                              color: Colors.white70, size: 30),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Thẻ chỉ số nhỏ ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStatCard(
                        title: 'Chi tiêu TB/ngày',
                        value: '${(_totalExpense / 30).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                        icon: Icons.payments_outlined,
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMiniStatCard(
                        title: 'Điểm sức khoẻ hũ',
                        value: '92/100',
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: const Color(0xFF00C096),
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Biểu đồ cột – Tiến độ tháng ─────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến Độ Hàng Tháng',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A2940)
                                  : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('6 Tháng gần đây',
                                style: TextStyle(
                                    fontSize: 11, color: textSecondary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _monthlySummaries.isEmpty ? [
                            _buildBarGroup('T6', 0.8, 0.4, isDark),
                            _buildBarGroup('T5', 0.5, 0.6, isDark),
                            _buildBarGroup('T4', 0.7, 0.3, isDark),
                            _buildBarGroup('T3', 0.6, 0.5, isDark),
                            _buildBarGroup('T2', 0.9, 0.2, isDark),
                          ] : _monthlySummaries.take(6).toList().reversed.map((s) {
                             final inc = (s['total_income'] ?? 0).toDouble();
                             final exp = (s['total_expense'] ?? 0).toDouble();
                             final m = s['month'];
                             final maxVal = math.max(1.0, math.max(inc, exp) * 1.2);
                             return _buildBarGroup('T$m', inc / maxVal, exp / maxVal, isDark);
                           }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(
                              color: const Color(0xFF4B49EB),
                              label: 'Phân bổ',
                              textSecondary: textSecondary),
                          const SizedBox(width: 20),
                          _buildLegendItem(
                              color: const Color(0xFF00C096),
                              label: 'Thực chi',
                              textSecondary: textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Danh mục chi tiêu ─────────────────────────────────
                Text('Danh Mục Chi Tiêu',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary)),
                const SizedBox(height: 12),
                if (_categoriesData.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text('Không có dữ liệu chi tiêu tháng này', style: TextStyle(color: textSecondary)),
                  )
                else
                  ..._categoriesData.map((c) {
                    final idx = _categoriesData.indexOf(c);
                    final name = c['name'];
                    final count = c['count'];
                    final amount = c['amount'];
                    final colors = [const Color(0xFF4B49EB), const Color(0xFFFF5252), const Color(0xFF00C096), const Color(0xFFFFAB00), const Color(0xFFB5179E)];
                    final col = colors[idx % colors.length];
                    final totalExp = math.max(1.0, _totalExpense);
                    return _buildCategoryRow(name, '$count giao dịch', '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                      col, amount / totalExp, cardColor, textPrimary, textSecondary, isDark);
                  }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required Color textSecondary,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    Color iconColor = const Color(0xFF4B49EB),
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 11, color: textSecondary)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textPrimary)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBarGroup(
      String label, double val1, double val2, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 10,
              height: 140 * val1,
              decoration: BoxDecoration(
                color: const Color(0xFF4B49EB),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: 140 * val2,
              decoration: BoxDecoration(
                color: const Color(0xFF00C096),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF8E8E93))),
      ],
    );
  }

  Widget _buildCategoryRow(
    String title,
    String trans,
    String amount,
    Color color,
    double percent,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.restaurant_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textPrimary)),
                    Text(amount,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textPrimary)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(trans,
                        style:
                            TextStyle(fontSize: 11, color: textSecondary)),
                    SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFEEEEFF),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(color),
                          minHeight: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter – Biểu đồ Donut ───────────────────────────────────────
class DonutChartPainter extends CustomPainter {
  final bool isDark;
  final List<dynamic> jars;
  const DonutChartPainter({required this.isDark, required this.jars});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 18.0;

    final paintBg = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.07)
          : const Color(0xFFF2F2F7)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - strokeWidth / 2, paintBg);

    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    final total = jars.fold(0.0, (s, x) => s + (x['budget'] ?? x['TargetAmount'] ?? 0));
    final values = jars.isEmpty ? [1.0] : jars.map((j) => total > 0 ? (j['budget'] ?? j['TargetAmount'] ?? 0) / total : 0.0).toList();
    final colors = [
      const Color(0xFF4B49EB),
      const Color(0xFF00C096),
      const Color(0xFFE63946),
      const Color(0xFF457B9D),
    ];

    double startAngle = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = values[i] * 2 * math.pi;
      final paintArc = Paint()
        ..color = colors[i % colors.length]
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paintArc);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter old) =>
      old.isDark != isDark;
}
