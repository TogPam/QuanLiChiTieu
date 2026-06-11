// screens/register_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đăng ký thành công! Vui lòng đăng nhập.'),
        backgroundColor: const Color(0xFF00C096),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF4F46E5);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF13121B), const Color(0xFF1B1A2A)]
                : [const Color(0xFFF4F6FB), const Color(0xFFE9EDF5)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_add_rounded,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? const Color(0xFFE4E1EE)
                          : const Color(0xFF13121B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bắt đầu hành trình quản lý tài chính',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey[600],
                        fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0x991E1E2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey[200]!,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.3 : 0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLabel('Họ và tên', isDark),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _nameCtrl,
                            hint: 'Nguyễn Văn A',
                            icon: Icons.person_outline_rounded,
                            isDark: isDark,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Vui lòng nhập họ tên'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          _buildLabel('Địa chỉ Email', isDark),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _emailCtrl,
                            hint: 'name@example.com',
                            icon: Icons.email_outlined,
                            isDark: isDark,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(v)) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildLabel('Mật khẩu', isDark),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _passCtrl,
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                            obscure: _obscurePass,
                            onToggleObscure: () =>
                                setState(() => _obscurePass = !_obscurePass),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (v.length < 6) {
                                return 'Mật khẩu tối thiểu 6 ký tự';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildLabel('Xác nhận mật khẩu', isDark),
                          const SizedBox(height: 8),
                          _buildField(
                            controller: _confirmCtrl,
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                            obscure: _obscureConfirm,
                            onToggleObscure: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            validator: (v) {
                              if (v != _passCtrl.text) {
                                return 'Mật khẩu không khớp';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              elevation: 4,
                              shadowColor: accent.withValues(alpha: 0.3),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Đăng ký',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Đã có tài khoản? ',
                          style: TextStyle(
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey[600])),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Đăng nhập ngay',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: isDark ? const Color(0xFFC7C4D8) : const Color(0xFF464555),
        ),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    bool? obscure,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure ?? false,
      style:
          TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: isDark ? Colors.white38 : Colors.grey[400]),
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  (obscure ?? false)
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
              color: isDark ? Colors.white10 : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide:
              const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}
