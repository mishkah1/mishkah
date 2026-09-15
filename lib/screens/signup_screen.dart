import 'package:flutter/material.dart';
import 'package:mishkah/screens/login_screen.dart';
import 'package:mishkah/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _darkGreen = Color(0xFF0F3D30);
  static const _cream = Color(0xFFF7F3EA);
  static const _gold = Color(0xFFD9A441);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);
  static const _field = Color(0xFFE5EEE8);

  final AuthService authService = AuthService();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateName(String value) {
    if (value.trim().isEmpty) {
      return 'أدخل الاسم الكامل';
    }
    return null;
  }

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'أدخل البريد الإلكتروني';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'أدخل بريدًا إلكترونيًا صحيحًا';
    }

    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'أدخل كلمة المرور';
    }

    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  Future<void> signUp() async {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    final nameError = validateName(name);
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (nameError != null || emailError != null || passwordError != null) {
      _showMessage(
        nameError ?? emailError ?? passwordError!,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await authService.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (response.user != null && response.session != null) {
        _showMessage('تم إنشاء الحساب بنجاح');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
      } else {
        _showMessage(
          'تم إنشاء الحساب، يرجى التحقق من بريدك الإلكتروني لإكمال التسجيل',
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(_getAuthError(e.message));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('حدث خطأ، حاول مرة أخرى');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  String _getAuthError(String message) {
    final text = message.toLowerCase();

    if (text.contains('already registered') ||
        text.contains('already exists')) {
      return 'البريد الإلكتروني مسجل مسبقًا';
    }

    if (text.contains('password')) {
      return 'تأكد من صحة كلمة المرور';
    }

    if (text.contains('email')) {
      return 'تأكد من صحة البريد الإلكتروني';
    }

    return 'تعذر إنشاء الحساب، حاول مرة أخرى';
  }

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: _darkGreen.withValues(alpha: 0.65),
        size: 19,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _field,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: _darkGreen.withValues(alpha: 0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: _darkGreen.withValues(alpha: 0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _darkGreen,
          width: 1.2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _cream,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(25, 18, 25, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _muted,
                      size: 19,
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  'إنشاء حساب',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'حساب جديد، وبداية جديدة مع مِشكاة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  'الاسم الكامل',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: fullNameController,
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.right,
                  decoration: fieldDecoration(
                    hint: 'أدخل الاسم الكامل',
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'البريد الإلكتروني',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  decoration: fieldDecoration(
                    hint: 'example@email.com',
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'كلمة المرور',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  decoration: fieldDecoration(
                    hint: 'أدخل كلمة المرور',
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: _darkGreen.withValues(alpha: 0.65),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  '6 أحرف أو أرقام على الأقل',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      disabledBackgroundColor:
                          _darkGreen.withValues(alpha: 0.5),
                      elevation: 2,
                      shadowColor: _darkGreen.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _gold,
                            ),
                          )
                        : const Text(
                            'إنشاء الحساب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          _showMessage(
                            'يمكنك استعادة كلمة المرور من صفحة تسجيل الدخول',
                          );
                        },
                  child: const Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(
                      color: _darkGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: _darkGreen.withValues(alpha: 0.12),
                        thickness: 0.8,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'أو',
                        style: TextStyle(
                          color: _muted.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: _darkGreen.withValues(alpha: 0.12),
                        thickness: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'لديك حساب بالفعل؟',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: _darkGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}