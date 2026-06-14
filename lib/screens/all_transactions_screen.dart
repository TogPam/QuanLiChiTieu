import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Cài gói này để cache ảnh
import '../services/api_service.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ApiService.getTransactions();
    if (mounted) {
      setState(() {
<<<<<<< HEAD
        _allTransactions = data.map((t) {
           final isExpense = (t['transaction_type'] ?? t['TransactionType']) == false;
           final amt = double.parse((t['amount'] ?? t['Amount'] ?? 0).toString()).toInt();
           var timeStr = '';
           var dateStr = '';
           final rawDate = (t['transaction_date'] ?? t['TransactionDate'])?.toString() ?? '';
           if (rawDate.isNotEmpty) {
             final parts = rawDate.split('T');
             dateStr = parts[0];
             if (parts.length > 1) timeStr = parts[1].substring(0, 5);
           }
           return {
             'title': t['description'] ?? t['Description'] ?? 'Giao dịch',
             'category': t['category_name'] ?? t['CategoryName'] ?? 'Khác',
             'time': timeStr,
             'date': dateStr,
             'amount': isExpense ? -amt : amt,
             'isExpense': isExpense,
             'raw': t,
           };
        }).toList();
=======
        _transactions = data ?? [];
>>>>>>> 8641f82cec3538ed3d82f2fb93eb62547061ea6a
        _isLoading = false;
      });
    }
  }

  String _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    // Tự động thay thế 127.0.0.1 thành IP thật

    // return url.replaceAll(
    //   'http://127.0.0.1:8000',
    //   'https://grams-authorities-attempted-solaris.trycloudflare.com',
    // );
    return url.replaceAll('127.0.0.1', 'ip-may-that');
  }

<<<<<<< HEAD
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
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                  ? Center(
                      child: Text('Không có giao dịch nào',
                          style: TextStyle(color: textSecondary, fontSize: 15)),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      color: accent,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                            ...txList.map((t) => GestureDetector(
                                  onTap: () => _showTransactionDetails(t['raw'], isDark, cardColor, textPrimary, textSecondary, accent),
                                  child: Container(
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
                                ))).toList(),
                          ],
                        );
                      },
                    ),
                  ),
            ),
          ],
=======
  // Hàm mở ảnh Full-screen
  void _showFullImage(String imageUrl) {
    final fixedUrl = _fixImageUrl(imageUrl);
    print("🔍 Mở ảnh Full-screen: $fixedUrl");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: InteractiveViewer(
            // Cho phép zoom ảnh
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(child: CachedNetworkImage(imageUrl: fixedUrl)),
          ),
>>>>>>> 8641f82cec3538ed3d82f2fb93eb62547061ea6a
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'Lịch sử giao dịch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final t = _transactions[index];
                final isIncome = t['transaction_type'] == true;
                final imageUrl = t['receipt_image_url'] as String?;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    // Thumbnail ảnh
                    leading: _buildLeading(imageUrl, isIncome),
                    title: Text(
                      t['description'] ?? 'Không mô tả',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      t['transaction_date'] ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: Text(
                      '${isIncome ? '+' : '-'} ${t['amount']}',
                      style: TextStyle(
                        color: isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: imageUrl != null && imageUrl.isNotEmpty
                        ? () => _showFullImage(imageUrl)
                        : null,
                  ),
                );
              },
            ),
    );
  }

  // Widget hiển thị ảnh nhỏ hoặc icon
  Widget _buildLeading(String? imageUrl, bool isIncome) {
    final fixedUrl = _fixImageUrl(imageUrl);
    if (fixedUrl != null && fixedUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: fixedUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (ctx, url) =>
              const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    // Nếu không có ảnh, hiện icon mặc định
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isIncome
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        color: isIncome ? Colors.green : Colors.red,
      ),
    );
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
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: SingleChildScrollView(
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
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1840) : const Color(0xFFEEEDFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconForCat(catName), color: accent, size: 36),
                ),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
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
}
