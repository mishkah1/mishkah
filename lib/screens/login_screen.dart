import 'dart:ui';
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

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  static const _background = Color(0xFF071C16);
  static const _backgroundMid = Color(0xFF0B2920);

  static const _accent = Color(0xFFC8B88A);
  static const _cream = Color(0xFFF4F1E8);
  static const _muted = Color(0xFFB5C2BB);

  final AuthService authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  late final AnimationController _entry;

  @override
  void initState() {
    super.initState();

    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _entry.dispose();
    super.dispose();
  }

  double _progress(double start, double end) {
    final value = (_entry.value - start) / (end - start);

    return Curves.easeOutCubic.transform(
      value.clamp(0.0, 1.0),
    );
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

    setState(() => isLoading = true);

    try {
      await authService.signIn(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage(_getAuthError(e.message));
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage('حدث خطأ، حاول مرة أخرى');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF183F32),
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: _cream,
          ),
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

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: _muted.withValues(alpha: 0.75),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: _accent.withValues(alpha: 0.75),
        size: 19,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.045),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(
          color: _accent.withValues(alpha: 0.65),
          width: 1.2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),
    );
  }

  Widget _reveal({
    required double start,
    required double end,
    required Widget child,
  }) {
    final value = _progress(start, end);

    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(
          0,
          (1 - value) * 18,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    final imageProgress = Curves.easeOutBack.transform(
      _entry.value.clamp(0.0, 1.0),
    );

    final imageHeight = screenH * 0.36;

    final imageTop = lerpDouble(
      -screenH * 0.38,
      0,
      imageProgress,
    )!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        body: AnimatedBuilder(
          animation: _entry,
          builder: (context, _) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _backgroundMid,
                          _background,
                        ],
                      ),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: imageHeight + 45,
                      bottom: 30,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          _reveal(
                            start: 0.35,
                            end: 0.56,
                            child: const Text(
                              'تسجيل الدخول',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _cream,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                          ),

                          const SizedBox(height: 7),

                          _reveal(
                            start: 0.40,
                            end: 0.62,
                            child: const Text(
                              'سجّل دخولك وتابع رحلتك مع مِشكاة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _muted,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 23),

                          _reveal(
                            start: 0.46,
                            end: 0.68,
                            child: TextField(
                              controller: emailController,
                              keyboardType:
                                  TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: _cream,
                              ),
                              decoration: _fieldDecoration(
                                hint: 'البريد الإلكتروني',
                                icon: Icons.email_outlined,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          _reveal(
                            start: 0.52,
                            end: 0.74,
                            child: TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: _cream,
                              ),
                              decoration: _fieldDecoration(
                                hint: 'كلمة المرور',
                                icon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword =
                                          !obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _accent.withValues(
                                      alpha: 0.80,
                                    ),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          _reveal(
                            start: 0.58,
                            end: 0.78,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: isLoading ? null : () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'نسيت كلمة المرور؟',
                                  style: TextStyle(
                                    color: _accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          _reveal(
                            start: 0.63,
                            end: 0.83,
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accent,
                                  disabledBackgroundColor:
                                      _accent.withValues(alpha: 0.45),
                                  elevation: 4,
                                  shadowColor:
                                      Colors.black.withValues(alpha: 0.20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(17),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 21,
                                        height: 21,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: _background,
                                        ),
                                      )
                                    : const Text(
                                        'تسجيل الدخول',
                                        style: TextStyle(
                                          color: _background,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          _reveal(
                            start: 0.69,
                            end: 0.91,
                            child: Row(
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
                                      color: _accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: imageTop,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: imageHeight,
                    child: ClipPath(
                      clipper: _ImageHeaderClipper(),
                      child: Image.asset(
                        'assets/images/background.png',
                        width: double.infinity,
                        height: imageHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ImageHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.60);

    path.cubicTo(
      size.width * 0.82,
      size.height * 0.74,
      size.width * 0.66,
      size.height * 0.90,
      size.width * 0.48,
      size.height * 0.76,
    );

    path.cubicTo(
      size.width * 0.30,
      size.height * 0.62,
      size.width * 0.14,
      size.height * 0.82,
      0,
      size.height * 0.68,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(
    covariant CustomClipper<Path> oldClipper,
  ) {
    return false;
  }
}