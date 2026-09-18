import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkah/screens/home/home_screen.dart';
import 'package:mishkah/screens/reset_password_screen.dart';
import 'package:mishkah/screens/signup_screen.dart';
import 'package:mishkah/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  final bool skipIntro;

  const LoginScreen({super.key, this.skipIntro = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _EmberSpec {
  final double left;
  final double size;
  final int durationMs;
  final int delayMs;
  final double driftX;
  const _EmberSpec({
    required this.left,
    required this.size,
    required this.durationMs,
    required this.delayMs,
    required this.driftX,
  });
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
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

  late final AnimationController _introCtrl;
  late final AnimationController _entry;
  late final AnimationController _ambient;

  static const List<_EmberSpec> _emberSpecs = [
    _EmberSpec(left: 0.12, size: 4, durationMs: 6500, delayMs: 200, driftX: 14),
    _EmberSpec(left: 0.24, size: 3, durationMs: 8000, delayMs: 2000, driftX: -10),
    _EmberSpec(left: 0.70, size: 5, durationMs: 7200, delayMs: 1000, driftX: -16),
    _EmberSpec(left: 0.82, size: 3, durationMs: 9500, delayMs: 3200, driftX: 10),
    _EmberSpec(left: 0.50, size: 4, durationMs: 7800, delayMs: 800, driftX: 6),
    _EmberSpec(left: 0.34, size: 3, durationMs: 8600, delayMs: 4000, driftX: -8),
    _EmberSpec(left: 0.90, size: 4, durationMs: 6800, delayMs: 2600, driftX: -12),
  ];

  late final List<AnimationController> _emberCtrls;
  final List<Timer> _emberTimers = [];

  @override
  void initState() {
    super.initState();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    _emberCtrls = _emberSpecs
        .map(
          (spec) => AnimationController(
            vsync: this,
            duration: Duration(milliseconds: spec.durationMs),
          ),
        )
        .toList();

    for (var i = 0; i < _emberCtrls.length; i++) {
      final spec = _emberSpecs[i];
      final timer = Timer(Duration(milliseconds: spec.delayMs), () {
        if (mounted) _emberCtrls[i].repeat();
      });
      _emberTimers.add(timer);
    }

    if (widget.skipIntro) {
      // قادم من شاشة أخرى (مثل إنشاء حساب) — نتخطى نص الآية وأنيميشن الفانوس
      // ونعرض نموذج تسجيل الدخول مباشرة.
      _introCtrl.value = 1.0;
      _entry.value = 1.0;
    } else {
      _introCtrl.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _entry.forward();
        }
      });

      _introCtrl.forward();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _introCtrl.dispose();
    _entry.dispose();
    _ambient.dispose();
    for (final c in _emberCtrls) {
      c.dispose();
    }
    for (final t in _emberTimers) {
      t.cancel();
    }
    super.dispose();
  }

  double _seg(double start, double end, {Curve curve = Curves.linear}) {
    final v = ((_entry.value - start) / (end - start)).clamp(0.0, 1.0);
    return curve.transform(v);
  }

  double _introSeg(double start, double end, {Curve curve = Curves.linear}) {
    final v = ((_introCtrl.value - start) / (end - start)).clamp(0.0, 1.0);
    return curve.transform(v);
  }

  double _emberOpacity(double t) {
    if (t < 0.12) return (t / 0.12) * 0.95;
    if (t < 0.75) {
      return 0.95 - ((t - 0.12) / (0.75 - 0.12)) * (0.95 - 0.45);
    }
    return (0.45 * (1 - (t - 0.75) / 0.25)).clamp(0.0, 1.0);
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

  TextSpan _ayahWordSpan(String word, double glowT, {double fontSize = 17}) {
    return TextSpan(
      text: word,
      style: TextStyle(
        fontFamily: GoogleFonts.elMessiri().fontFamily,
        fontWeight: FontWeight.w600,
        color: _goldLight,
        fontSize: fontSize,
        shadows: [
          Shadow(
            color: _goldLight.withValues(alpha: 0.35 + glowT * 0.5),
            blurRadius: 10 + glowT * 14,
          ),
        ],
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

  Widget _buildAmbientGlow() {
    return AnimatedBuilder(
      animation: _ambient,
      builder: (context, _) {
        final ambient = Curves.easeInOut.transform(_ambient.value);
        return Stack(
          children: [
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
          ],
        );
      },
    );
  }

  Widget _buildEmbers(Size size) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(_emberSpecs.length, (i) {
          final spec = _emberSpecs[i];
          return AnimatedBuilder(
            animation: _emberCtrls[i],
            builder: (context, _) {
              final t = _emberCtrls[i].value;
              final opacity = _emberOpacity(t);
              final dy = -560.0 * t;
              final dx = spec.driftX * t;
              final scale = 1 - 0.65 * t;
              return Positioned(
                left: size.width * spec.left,
                bottom: 60,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(dx, dy),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: spec.size,
                        height: spec.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [_goldLight, _gold],
                            stops: [0.0, 0.75],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _goldLight.withValues(alpha: 0.55),
                              blurRadius: 7,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildMainContent(Size size) {
    return AnimatedBuilder(
      animation: _entry,
      builder: (context, _) {
        final contentT = _seg(0.16, 0.55, curve: Curves.easeOutCubic);
        final contentScale = lerpDouble(0.97, 1, contentT)!;

        return Opacity(
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
                                    child: _glowBlob(170, 0.30),
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
                                    color: _gold.withValues(alpha: 0.35),
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
                                borderRadius: BorderRadius.circular(2),
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

                      _reveal(
                        start: 0.40,
                        end: 0.58,
                        child: Container(
                          width: 296,
                          padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
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
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 48,
                                offset: const Offset(0, 24),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  keyboardType: TextInputType.emailAddress,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(color: _ivory),
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
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(color: _ivory),
                                  decoration: _fieldDecoration(
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
                                        color: _gold.withValues(alpha: 0.85),
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
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const ResetPasswordScreen(),
                                              ),
                                            );
                                          },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'نسيت كلمة المرور؟',
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
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
                                      child: Text(
                                        'إنشاء حساب',
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
        );
      },
    );
  }

  Widget _buildIntroOverlay() {
    return AnimatedBuilder(
      animation: Listenable.merge([_introCtrl, _ambient]),
      builder: (context, _) {
        final overlayOpacity = 1 - _introSeg(0.82, 1.0, curve: Curves.easeIn);
        final lampT = _introSeg(0.0, 0.35, curve: Curves.easeOut);
        final lampScale = lerpDouble(0.7, 1, lampT)!;
        final textT = _introSeg(0.30, 0.6, curve: Curves.easeOut);
        final textY = (1 - textT) * 14;
        final glowT = Curves.easeInOut.transform(_ambient.value);

        return IgnorePointer(
          child: Opacity(
            opacity: overlayOpacity.clamp(0.0, 1.0),
            child: Container(
              color: _bg,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: lampT,
                      child: Transform.scale(
                        scale: lampScale,
                        child: SizedBox(
                          width: 64,
                          height: 100,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                bottom: 14,
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        _goldLight.withValues(
                                          alpha: 0.32 * (0.7 + 0.3 * glowT),
                                        ),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.68],
                                    ),
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/lantern.png',
                                width: 64,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Opacity(
                      opacity: textT,
                      child: Transform.translate(
                        offset: Offset(0, textY),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              Text.rich(
                                TextSpan(
                                  style: GoogleFonts.elMessiri(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: _goldLight,
                                    height: 1.9,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          '﴿ اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ\nمَثَلُ نُورِهِ كَ',
                                    ),
                                    _ayahWordSpan('مِشْكَاةٍ', glowT),
                                    const TextSpan(text: ' فِيهَا مِصْبَاحٌ ﴾'),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'سورة النور . ٣٥',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _muted,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
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

            Positioned.fill(child: _buildAmbientGlow()),

            Positioned.fill(child: _buildEmbers(size)),

            Positioned.fill(child: _buildMainContent(size)),

            Positioned.fill(child: _buildIntroOverlay()),
          ],
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
