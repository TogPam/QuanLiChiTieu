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
        _transactions = data ?? [];
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
}
