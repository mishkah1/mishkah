import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkah/screens/login_screen.dart';

/// ألوان الأونبوردنق — نفس لوحة الألوان المعتمدة في الهوم سكرين
/// (زمردي داكن قريب من الأسود + ذهبي دافئ + نص عاجي)، للتناسق الكامل بين الشاشتين.
class _Ob {
  _Ob._();
  static const Color bg = Color(0xFF0D1713);
  static const Color surface1 = Color(0xFF15221C);
  static const Color surface2 = Color(0xFF1B2B24);
  static const Color gold = Color(0xFFC6A15B);
  static const Color goldLight = Color(0xFFD8BC7A);
  static const Color goldDeep = Color(0xFFA9834A);
  static const Color ivory = Color(0xFFF4EFE3);
  static const Color muted = Color(0xFF9AA098);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDeep],
  );

  static List<BoxShadow> goldShadow = [
    BoxShadow(
      color: gold.withOpacity(0.38),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlideData {
  final String image;
  final String title;
  final String description;
  const _OnboardingSlideData({
    required this.image,
    required this.title,
    required this.description,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _index = 0;
  bool _descVisible = false;

  final List<_OnboardingSlideData> _slides = const [
    _OnboardingSlideData(
      image: 'assets/images/onboarding_1.png',
      title: 'كل ما تحتاجه في مكان واحد',
      description:
          'اكتشف دور التحفيظ وحلقات القرآن والبرامج التعليمية القريبة منك، واختر الأنسب لك بكل سهولة.',
    ),
    _OnboardingSlideData(
      image: 'assets/images/onboarding_2.png',
      title: 'تعلم بما يناسبك',
      description:
          'اختر الحلقة أو البرنامج الذي يناسب احتياجك وطموحك، وابدأ رحلتك في الوقت المناسب لك.',
    ),
    _OnboardingSlideData(
      image: 'assets/images/onboarding_3.png',
      title: 'فرص تصنع أثراً',
      description:
          'اكتشف الفرص والمبادرات التطوعية التي تساعدك على التعلم والعطاء وترك أثر حقيقي.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() {
      _index = i;
      _descVisible = false;
    });
  }

  void _goTo(int i) {
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _goTo(_index + 1);
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];

    return Scaffold(
      backgroundColor: _Ob.bg,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_Ob.bg, _Ob.surface1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // شريط علوي: زر "تخطي" فقط، أقصى اليمين دائماً (تطبيق عربي)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(
                      foregroundColor: _Ob.muted,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                    ),
                    child: const Text(
                      'تخطي',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              // الجسم: فراغ مرن يدفع الصور لمنتصف الشاشة، ثم النص ملاصقاً أسفلها، ثم فراغ مرن قبل الزر
              Expanded(
                child: Column(
                  children: [
                    // فراغ مرن أعلى الصور (أكبر من الأسفل) لدفعها لمنتصف الشاشة تماماً
                    const Expanded(flex: 2, child: SizedBox.shrink()),

                    // 1. الشريط الدوّار: بطاقة مركزية كبيرة جداً وبطاقتان جانبيتان بارزتان جزئياً
                    SizedBox(
                      height: 430,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemCount: _slides.length,
                        itemBuilder: (context, i) {
                          return RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double page = _index.toDouble();
                                if (_pageController.position.haveDimensions) {
                                  page =
                                      _pageController.page ?? _index.toDouble();
                                }
                                // إشارة الفرق: موجب = البطاقة على يمين المركز، سالب = على يساره
                                final signedDelta =
                                    (page - i).clamp(-1.0, 1.0);
                                final absD = signedDelta.abs();
                                final scale = 1 - absD * 0.28;
                                final opacity = 1 - absD * 0.45;
                                // نسحب البطاقات الجانبية نحو المركز وندوّرها كأنها تُطوى للخلف (شكل مروحة/دائرة)
                                final pull = -signedDelta * 58;
                                final rotY = -signedDelta * 0.46; // راديان
                                final matrix = Matrix4.identity()
                                  ..setEntry(3, 2, 0.0012)
                                  ..rotateY(rotY)
                                  ..scale(scale);
                                return Opacity(
                                  opacity: opacity.clamp(0.0, 1.0),
                                  child: Transform.translate(
                                    offset: Offset(pull, 0),
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: matrix,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  if (i != _index) _goTo(i);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 30,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.12),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: _SlideVisual(
                                          image: _slides[i].image,
                                          isActive: i == _index,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // نقاط المؤشر أسفل الصور مباشرة
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          final active = i == _index;
                          return GestureDetector(
                            onTap: () => _goTo(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 320),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: active ? 26 : 8,
                              height: 7,
                              decoration: BoxDecoration(
                                color: active
                                    ? _Ob.gold
                                    : _Ob.ivory.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // 2. النص يلتصق أسفل النقاط مباشرة
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: _TypewriterTitle(
                              key: ValueKey<int>(_index),
                              text: slide.title,
                              style: GoogleFonts.tajawal(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: _Ob.ivory,
                              ),
                              onDone: () {
                                if (mounted) {
                                  setState(() => _descVisible = true);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 480),
                            curve: Curves.easeOutCubic,
                            offset: _descVisible
                                ? Offset.zero
                                : const Offset(0, 0.2),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 480),
                              opacity: _descVisible ? 1 : 0,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 290),
                                child: Text(
                                  slide.description,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: _Ob.ivory.withOpacity(0.72),
                                    height: 1.7,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // فراغ مرن أصغر قبل الزر
                    const Expanded(flex: 1, child: SizedBox.shrink()),

                    // 3. زر الإجراء في الأسفل
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _Ob.goldGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _Ob.goldShadow,
                          ),
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: _Ob.bg,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              _index == _slides.length - 1
                                  ? 'ابدأ الآن'
                                  : 'التالي',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }
}

/// صورة الشريحة: تكبير مستمر بأسلوب Ken Burns + شعاع ضوء متحرك.
/// الأداء: الـcontrollers تعمل فقط عندما تكون البطاقة نشطة (في المنتصف)
/// لتقليل عدد الـanimations التي تعمل في نفس الوقت وتخفيف الحمل على الجهاز.
class _SlideVisual extends StatefulWidget {
  final String image;
  final bool isActive;
  const _SlideVisual({required this.image, required this.isActive});

  @override
  State<_SlideVisual> createState() => _SlideVisualState();
}

class _SlideVisualState extends State<_SlideVisual>
    with TickerProviderStateMixin {
  late final AnimationController _zoomController;
  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    );
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    if (widget.isActive) {
      _zoomController.repeat(reverse: true);
      _sweepController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _SlideVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    if (widget.isActive) {
      // استئناف الحركة عندما تصبح البطاقة نشطة (في المنتصف)
      _zoomController.repeat(reverse: true);
      _sweepController.repeat();
    } else {
      // إيقاف الحركة للبطاقات الجانبية غير النشطة لتوفير الأداء
      _zoomController.stop();
      _sweepController.stop();
    }
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _zoomController,
            builder: (context, child) {
              final scale = 1.0 + 0.1 * _zoomController.value;
              final dx = -5.0 * _zoomController.value;
              final dy = -7.0 * _zoomController.value;
              return Transform.translate(
                offset: Offset(dx, dy),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: Image.asset(widget.image, fit: BoxFit.cover),
          ),
          AnimatedBuilder(
            animation: _sweepController,
            builder: (context, _) {
              final t = _sweepController.value;
              return IgnorePointer(
                child: Opacity(
                  opacity: 0.7,
                  child: Transform.translate(
                    offset: Offset(-420 + t * 950, 0),
                    child: Transform.rotate(
                      angle: 0.16,
                      child: Container(
                        width: 170,
                        height: 900,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              _Ob.goldLight.withOpacity(0.24),
                              _Ob.goldLight.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.3, 0.48, 0.58, 0.7],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // ظل خفيف جداً أسفل الصورة فقط للفصل البصري عن حوافها
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.22),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// عنوان يظهر بتأثير الكتابة التدريجية (Typewriter) حرفاً بحرف
class _TypewriterTitle extends StatefulWidget {
  final String text;
  final TextStyle style;
  final VoidCallback? onDone;
  const _TypewriterTitle({
    required this.text,
    required this.style,
    this.onDone,
    super.key,
  });

  @override
  State<_TypewriterTitle> createState() => _TypewriterTitleState();
}

class _TypewriterTitleState extends State<_TypewriterTitle> {
  Timer? _timer;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onDone?.call();
      });
      return;
    }
    _timer = Timer.periodic(const Duration(milliseconds: 42), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charCount >= widget.text.length) {
        timer.cancel();
        return;
      }
      setState(() => _charCount++);
      if (_charCount >= widget.text.length) {
        timer.cancel();
        widget.onDone?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = _charCount >= widget.text.length;
    final shown = widget.text.substring(0, _charCount.clamp(0, widget.text.length));
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: shown),
          if (!done)
            TextSpan(
              text: ' ◆',
              style: widget.style.copyWith(
                color: _Ob.gold,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }
}