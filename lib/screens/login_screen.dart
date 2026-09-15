import 'package:flutter/material.dart';
import 'package:mishkah/screens/home/home_screen.dart';
import 'package:mishkah/screens/signup_screen.dart';
import 'package:mishkah/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _darkGreen = Color(0xFF0F3D30);
  static const _deepGreen = Color(0xFF082C24);
  static const _cream = Color(0xFFF7F3EA);
  static const _gold = Color(0xFFD9A441);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);
  static const _field = Color(0xFFE5EEE8);

  final AuthService authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      _showMessage('أدخل البريد الإلكتروني');
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showMessage('أدخل بريدًا إلكترونيًا صحيحًا');
      return;
    }

    if (password.isEmpty) {
      _showMessage('أدخل كلمة المرور');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.signIn(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
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

    if (text.contains('invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    if (text.contains('email not confirmed')) {
      return 'البريد الإلكتروني غير موثق، يرجى التحقق من بريدك أولًا';
    }

    if (text.contains('email')) {
      return 'تأكد من صحة البريد الإلكتروني';
    }

    return 'تعذر تسجيل الدخول، حاول مرة أخرى';
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 350,
                child: Stack(
                  children: [
                    ClipPath(
                      clipper: _WaveClipper(),
                      child: Container(
                        width: double.infinity,
                        height: 350,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFF174E40),
                              Color(0xFF0F3D30),
                              Color(0xFF082C24),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -70,
                              right: -35,
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      _gold.withValues(alpha: 0.20),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 115,
                              left: -45,
                              child: Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.08),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 35,
                              left: 18,
                              child: IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 110,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Text(
                                    'مِشكاة',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.20,
                                          ),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'طريقك إلى القرآن والعمل',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _gold.withValues(alpha: 0.95),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 25,
                              bottom: 75,
                              child: Icon(
                                Icons.auto_stories_rounded,
                                size: 72,
                                color: _gold.withValues(alpha: 0.16),
                              ),
                            ),
                            Positioned(
                              right: 95,
                              bottom: 60,
                              child: Icon(
                                Icons.auto_stories_rounded,
                                size: 32,
                                color: Colors.white.withValues(alpha: 0.07),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'تسجيل الدخول',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _darkGreen,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'سجّل دخولك وتابع رحلتك مع مِشكاة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.right,
                      decoration: fieldDecoration(
                        hint: 'البريد الإلكتروني',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.right,
                      decoration: fieldDecoration(
                        hint: 'كلمة المرور',
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
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: _darkGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 53,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkGreen,
                          disabledBackgroundColor:
                              _darkGreen.withValues(alpha: 0.5),
                          elevation: 2,
                          shadowColor: _darkGreen.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
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
                                'تسجيل الدخول',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ليس لديك حساب؟',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SignupScreen(),
                                    ),
                                  );
                                },
                          child: const Text(
                            'إنشاء حساب',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.70);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.60,
      size.width * 0.50,
      size.height * 0.70,
    );

    path.quadraticBezierTo(
      size.width * 0.76,
      size.height * 0.81,
      size.width,
      size.height * 0.67,
    );

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}