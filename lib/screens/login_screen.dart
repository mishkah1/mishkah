import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // ألوان الهوية (لا تتغيّر عن بقية التطبيق)
  static const _bg = Color(0xFF0D1713);
  static const _surface1 = Color(0xFF15221C);
  static const _surface2 = Color(0xFF1B2B24);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _goldDark = Color(0xFFA9834A);
  static const _ivory = Color(0xFFF4EFE3);
  static const _muted = Color(0xFFAEB8AF);

  final AuthService authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  late final AnimationController _entry;
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();

    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _entry.dispose();
    _ambient.dispose();
    super.dispose();
  }

  // يحاكي الـ keyframes النسبية (from -> to) على مدى المتحكم الكامل
  double _seg(double start, double end, {Curve curve = Curves.linear}) {
    final v = ((_entry.value - start) / (end - start)).clamp(0.0, 1.0);
    return curve.transform(v);
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
      await authService.signIn(email: email, password: password);

      if (!mounted) return;

      setState(() => isLoading = false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
        backgroundColor: _surface2,
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: const TextStyle(color: _ivory),
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
      hintStyle: TextStyle(color: _muted.withValues(alpha: 0.7), fontSize: 13),
      prefixIcon: Icon(icon, color: _gold.withValues(alpha: 0.8), size: 19),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.045),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: _gold.withValues(alpha: 0.18)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: _gold.withValues(alpha: 0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(color: _goldLight, width: 1.3),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
    );
  }

  Widget _reveal({
    required double start,
    required double end,
    required Widget child,
  }) {
    final v = _seg(start, end, curve: Curves.easeOutCubic);
    return Opacity(
      opacity: v,
      child: Transform.translate(
        offset: Offset(0, (1 - v) * 16),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: AnimatedBuilder(
          animation: Listenable.merge([_entry, _ambient]),
          builder: (context, _) {
            // مراحل "انفجار الضوء" السينمائي
            final flashOpacity = _seg(0.0, 0.10, curve: Curves.easeOut) *
                (1 - _seg(0.10, 0.34, curve: Curves.easeIn));
            final ringT = _seg(0.02, 0.40, curve: Curves.easeOut);
            final ringScale = lerpDouble(0.15, 3.4, ringT)!;
            final ringOpacity = (1 - ringT) * 0.9;
            final burstT = _seg(0.0, 0.34, curve: Curves.easeOut);
            final burstScale = lerpDouble(0.08, 2.6, burstT)!;
            final burstOpacity = (1 - _seg(0.10, 0.34)) *
                _seg(0.0, 0.08, curve: Curves.easeOut);

            final contentT = _seg(0.16, 0.55, curve: Curves.easeOutCubic);
            final contentBlur = lerpDouble(16, 0, contentT)!;
            final contentScale = lerpDouble(0.94, 1, contentT)!;

            final ambient = Curves.easeInOut.transform(_ambient.value);

            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.7),
                        radius: 1.1,
                        colors: [_surface2, _surface1, _bg],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // توهج ذهبي عائم خافت
                Positioned(
                  top: -60,
                  right: -70,
                  child: _glowBlob(220, 0.16 * (0.6 + 0.4 * ambient)),
                ),
                Positioned(
                  bottom: 60,
                  left: -90,
                  child: _glowBlob(260, 0.10 * (0.6 + 0.4 * (1 - ambient))),
                ),

                // محتوى الشاشة
                ImageFiltered(
                  imageFilter:
                      ImageFilter.blur(sigmaX: contentBlur, sigmaY: contentBlur),
                  child: Opacity(
                    opacity: contentT,
                    child: Transform.scale(
                      scale: contentScale,
                      child: SafeArea(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 10,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: size.height -
                                  MediaQuery.of(context).padding.top -
                                  MediaQuery.of(context).padding.bottom -
                                  20,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // القنديل + الاسم كوحدة بصرية واحدة
                                _reveal(
                                  start: 0.30,
                                  end: 0.48,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 150,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              bottom: 20,
                                              child: _glowBlob(
                                                170,
                                                0.24 * (0.7 + 0.3 * ambient),
                                              ),
                                            ),
                                            Image.asset(
                                              'assets/images/lantern.png',
                                              width: 56,
                                              fit: BoxFit.contain,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'مِشكاة',
                                        style: GoogleFonts.elMessiri(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w500,
                                          color: _ivory,
                                          shadows: [
                                            Shadow(
                                              color: _gold.withValues(
                                                alpha: 0.35,
                                              ),
                                              blurRadius: 22,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: 64,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              _gold,
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // بطاقة زجاجية
                                _reveal(
                                  start: 0.40,
                                  end: 0.58,
                                  child: Container(
                                    width: 296,
                                    padding: const EdgeInsets.fromLTRB(
                                      22,
                                      26,
                                      22,
                                      24,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(22),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withValues(alpha: 0.06),
                                          Colors.white.withValues(alpha: 0.02),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: _gold.withValues(alpha: 0.28),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _gold.withValues(alpha: 0.16),
                                          blurRadius: 40,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 48,
                                          offset: const Offset(0, 24),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'تسجيل الدخول',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _ivory,
                                            fontSize: 23,
                                            fontWeight: FontWeight.w900,
                                            height: 1.15,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          'سجّل دخولك وتابع رحلتك مع مِشكاة',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _muted,
                                            fontSize: 12.5,
                                            height: 1.6,
                                          ),
                                        ),
                                        const SizedBox(height: 22),

                                        _reveal(
                                          start: 0.50,
                                          end: 0.66,
                                          child: TextField(
                                            controller: emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textDirection: TextDirection.ltr,
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(color: _ivory),
                                            decoration: _fieldDecoration(
                                              hint: 'البريد الإلكتروني',
                                              icon: Icons.email_outlined,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        _reveal(
                                          start: 0.55,
                                          end: 0.71,
                                          child: TextField(
                                            controller: passwordController,
                                            obscureText: obscurePassword,
                                            textDirection: TextDirection.ltr,
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(color: _ivory),
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
                                                      ? Icons
                                                          .visibility_off_outlined
                                                      : Icons
                                                          .visibility_outlined,
                                                  color: _gold.withValues(
                                                    alpha: 0.85,
                                                  ),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        _reveal(
                                          start: 0.60,
                                          end: 0.75,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: TextButton(
                                              onPressed:
                                                  isLoading ? null : () {},
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                'نسيت كلمة المرور؟',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: _goldLight,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        _reveal(
                                          start: 0.65,
                                          end: 0.82,
                                          child: _GradientButton(
                                            isLoading: isLoading,
                                            onPressed: login,
                                            label: 'تسجيل الدخول',
                                            colors: const [
                                              _goldLight,
                                              _gold,
                                              _goldDark,
                                            ],
                                            textColor: _bg,
                                          ),
                                        ),

                                        const SizedBox(height: 14),

                                        _reveal(
                                          start: 0.72,
                                          end: 0.92,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'ليس لديك حساب؟',
                                                textAlign: TextAlign.center,
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
                                                child: Text(
                                                  'إنشاء حساب',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: _goldLight,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // دخول سينمائي: ومضة بيضاء ثم حلقة صدمة وانفجار ضوء ذهبي
                IgnorePointer(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: flashOpacity.clamp(0.0, 1.0),
                          child: Container(color: const Color(0xFFFFF9EC)),
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.46 - 50,
                        left: size.width / 2 - 50,
                        child: Opacity(
                          opacity: ringOpacity.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: ringScale,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _goldLight,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: size.height * 0.46 - 170,
                        left: size.width / 2 - 170,
                        child: Opacity(
                          opacity: burstOpacity.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: burstScale,
                            child: Container(
                              width: 340,
                              height: 340,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color(0xFFFFF7E4),
                                    _goldLight,
                                    _gold,
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.22, 0.42, 0.72],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _glowBlob(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _goldLight.withValues(alpha: alpha.clamp(0.0, 1.0)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.isLoading,
    required this.onPressed,
    required this.label,
    required this.colors,
    required this.textColor,
  });

  final bool isLoading;
  final VoidCallback onPressed;
  final String label;
  final List<Color> colors;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.45),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: textColor,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}