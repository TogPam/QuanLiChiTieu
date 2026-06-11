import 'package:flutter/material.dart';
import 'package:quan_li_chi_tieu/login_screens/navigation_screen.dart';
import 'register_screen.dart';
import '../services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email == 'admin@gmail.com' && password == '123456') {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      // Lưu thông báo chào mừng
      NotificationService.instance.setUser('admin');
      await NotificationService.instance.addWelcome('Admin');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email hoặc mật khẩu không đúng'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF13121B), const Color(0xFF1B1A2A), const Color(0xFF0F0E14)]
                : [const Color(0xFFF4F6FB), const Color(0xFFE9EDF5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16.0),
                // Logo
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Center(child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 36.0)),
                ),
                const SizedBox(height: 16.0),

                // Tên thương hiệu
                Text('Quản Lý Chi Tiêu',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFE4E1EE) : const Color(0xFF13121B),
                    )),
                const SizedBox(height: 6.0),

                Text('Kiểm soát tài chính, sống trọn vẹn hơn',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600], height: 1.4)),
                const SizedBox(height: 32.0),

                // Form card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 440),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x991E1E2E) : Colors.white,
                    borderRadius: BorderRadius.circular(32.0),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[200]!,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 30, offset: const Offset(0, 15)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Text('Chào mừng bạn quay lại',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 18,
                            color: isDark ? const Color(0xFFE4E1EE) : const Color(0xFF13121B),
                          )),
                      const SizedBox(height: 24.0),

                      // Đăng nhập Google
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                          backgroundColor: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white,
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Image.network('https://lh3.googleusercontent.com/COxitS2mcbB9862J1Alq3Xg8N7WXgCAt6-9mAt1mReU7V62e1KEm47as9Ma35g4N0GQ',
                            width: 20, height: 20,
                            errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 24),
                          ),
                          const SizedBox(width: 12.0),
                          Text('Tiếp tục với Google',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFE4E1EE) : const Color(0xFF13121B),
                              )),
                        ]),
                      ),
                      const SizedBox(height: 24.0),

                      // Phân cách
                      Row(children: [
                        Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('HOẶC ĐĂNG NHẬP BẰNG EMAIL',
                              style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, letterSpacing: 1.0,
                                  color: isDark ? Colors.white38 : Colors.grey[500])),
                        ),
                        Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.grey[300])),
                      ]),
                      const SizedBox(height: 24.0),

                      // Email
                      Text('Địa chỉ Email',
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFC7C4D8) : const Color(0xFF464555))),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: _inputDec('name@example.com', Icons.email_outlined, isDark),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Hãy điền địa chỉ email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),

                      // Mật khẩu
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Mật khẩu',
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFC7C4D8) : const Color(0xFF464555))),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('Quên mật khẩu?', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
                        ),
                      ]),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: _inputDec('••••••••', Icons.lock_outline_rounded, isDark,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Hãy điền mật khẩu';
                          if (value.length < 6) return 'Mật khẩu phải dài ít nhất 6 ký tự';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28.0),

                      // Nút đăng nhập
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF4F46E5).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
                          elevation: 4, shadowColor: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Text('Đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 32.0),

                // Đăng ký
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Chưa có tài khoản? ', style: TextStyle(fontSize: 14.0, color: isDark ? Colors.white54 : Colors.grey[600])),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Đăng ký ngay',
                        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  ),
                ]),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint, IconData icon, bool isDark, {Widget? suffixIcon}) =>
    InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0),
          borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
    );
}
