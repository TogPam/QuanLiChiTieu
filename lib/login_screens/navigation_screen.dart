import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../screens/home_screen.dart';
import '../screens/analysis_screen.dart';
import '../screens/activity_screen.dart';
import '../screens/vault_screen.dart';
import '../screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = const [
    HomeScreen(),
    ActivityScreen(),
    AnalysisScreen(),
    VaultScreen(),
    ProfileScreen(),
  ];

  bool _isPopupShowing = false;

  final List<Map<String, dynamic>> _jars = [
    {'id': '1', 'name': 'Tiền ăn', 'icon': Icons.restaurant_rounded, 'color': const Color(0xFFFF7A00)},
    {'id': '2', 'name': 'Đi chơi', 'icon': Icons.celebration_rounded, 'color': const Color(0xFFB5179E)},
    {'id': '3', 'name': 'Học tập', 'icon': Icons.school_rounded, 'color': const Color(0xFF4361EE)},
    {'id': '4', 'name': 'Tiền nhà', 'icon': Icons.home_work_rounded, 'color': const Color(0xFF00C096)},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;
    _fadeController.reverse().then((_) {
      setState(() => _selectedIndex = index);
      _fadeController.forward();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_isPopupShowing) {
        _showResumeCameraPopup();
      }
    }
  }

  void _showResumeCameraPopup() {
    _isPopupShowing = true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cardColor = isDark ? const Color(0xFF1E1D2E) : Colors.white;
        final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
        final textSecondary = isDark ? const Color(0xFF9CA3AF) : Colors.grey;
        
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 18),
              Text('Chào mừng trở lại! 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 8),
              Text('Bạn vừa chi tiêu gì đó? Chọn hũ để lưu lại ngay!', style: TextStyle(fontSize: 14, color: textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.5, mainAxisSpacing: 12, crossAxisSpacing: 12),
                itemCount: _jars.length,
                itemBuilder: (_, i) {
                  final jar = _jars[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _openCameraForJar(jar);
                    },
                    child: Container(
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2940) : const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(jar['icon'] as IconData, color: jar['color'] as Color, size: 20),
                          const SizedBox(width: 8),
                          Text(jar['name'] as String, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _isPopupShowing = false;
                },
                child: Text('Để sau', style: TextStyle(color: textSecondary, fontSize: 15)),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Allow it to be shown again if dismissed without picking
      if (!_isPopupShowing) return; 
    });
  }

  Future<void> _openCameraForJar(Map<String, dynamic> jar) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        _showDescriptionDialog(jar, File(pickedFile.path));
      } else {
        _isPopupShowing = false;
      }
    } catch (e) {
      debugPrint("Camera error: $e");
      _isPopupShowing = false;
    }
  }

  void _showDescriptionDialog(Map<String, dynamic> jar, File image) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE4E1EE) : const Color(0xFF1C1C1E);
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1D2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Chi tiết giao dịch', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(image, height: 120, width: double.infinity, fit: BoxFit.cover)),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(hintText: 'Số tiền (đ)', filled: true, fillColor: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(hintText: 'Mô tả (tuỳ chọn)', filled: true, fillColor: isDark ? const Color(0xFF2A2940) : const Color(0xFFF5F5F9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _isPopupShowing = false;
            },
            child: const Text('Bỏ qua', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _isPopupShowing = false;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu giao dịch thành công!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B49EB), foregroundColor: Colors.white),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF1B1A2A) : Colors.white;
    final selectedColor = isDark ? const Color(0xFF7C7AFF) : const Color(0xFF4B49EB);
    final unselectedColor = isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Trang chủ', selectedColor, unselectedColor),
                _buildNavItem(1, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Giao dịch', selectedColor, unselectedColor),
                _buildNavItem(2, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Phân tích', selectedColor, unselectedColor),
                _buildNavItem(3, Icons.savings_outlined, Icons.savings_rounded, 'Tiết kiệm', selectedColor, unselectedColor),
                _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Cá nhân', selectedColor, unselectedColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? selectedColor : unselectedColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}