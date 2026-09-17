import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/dar_model.dart';
import '../../models/halaqa_model.dart';
import '../halaqa/halaqa_details_screen.dart';

class DarDetailsScreen extends StatelessWidget {
  final DarModel dar;
  final List<HalaqaModel> halaqas;

  const DarDetailsScreen({
    super.key,
    required this.dar,
    required this.halaqas,
  });

  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceElevated = Color(0xFF1B2B24);
  static const _darkGreen = Color(0xFF2C5142);
  static const _cream = Color(0xFFF4EFE3);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _muted = Color(0xFFA8B0AA);
  static const _border = Color(0xFF293A32);

  TextStyle _bodyFont({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = _cream,
    double height = 1.35,
  }) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  TextStyle _displayFont({
    double size = 23,
    FontWeight weight = FontWeight.w700,
    Color color = _cream,
  }) {
    return GoogleFonts.amiri(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        body: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: _MishkahBackground(),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: _background.withOpacity(0.96),
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: 96,
                  pinned: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  automaticallyImplyLeading: false,
                  title: Text(
                    'صفحة الدار',
                    textDirection: TextDirection.rtl,
                    style: _displayFont(
                      size: 22,
                      color: _cream,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _BackButton(
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildDarCard(),
                        const SizedBox(height: 22),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 24,
                                height: 1,
                                color: _gold.withOpacity(0.48),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${halaqas.length} حلقات متوفرة في هذا الدار',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: _bodyFont(
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: _muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...halaqas.map(
                          (h) => _buildHalaqaTile(context, h),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.98),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _surfaceElevated,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _gold.withOpacity(0.17),
                  ),
                ),
                child: const Icon(
                  Icons.mosque_outlined,
                  color: _gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dar.name,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: _displayFont(
                    size: 20,
                    weight: FontWeight.w700,
                    color: _cream,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: _surfaceElevated.withOpacity(0.74),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: _gold,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    dar.address,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: _bodyFont(
                      size: 12,
                      color: _muted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalaqaTile(
    BuildContext context,
    HalaqaModel halaqa,
  ) {
    final isOpen =
        halaqa.registrationStatus == RegistrationStatus.open;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HalaqaDetailsScreen(
                halaqa: halaqa,
                dar: dar,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.97),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 17,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 58,
                decoration: BoxDecoration(
                  color: isOpen ? _gold : _muted.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            halaqa.name,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _displayFont(
                              size: 18,
                              weight: FontWeight.w700,
                              color: _cream,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        _buildStatusBadge(isOpen),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${halaqa.focus.label} - ${halaqa.time.label} - ${halaqa.category.label}',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _bodyFont(
                          size: 10.5,
                          color: _muted,
                          height: 1.45,
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

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isOpen
            ? _gold.withOpacity(0.11)
            : _muted.withOpacity(0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOpen
              ? _gold.withOpacity(0.28)
              : _muted.withOpacity(0.18),
        ),
      ),
      child: Text(
        isOpen ? 'التسجيل مفتوح' : 'قريبًا',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: _bodyFont(
          size: 9.5,
          weight: FontWeight.w700,
          color: isOpen ? _goldLight : _muted,
          height: 1.1,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF15221C),
            border: Border.all(
              color: const Color(0xFFC6A15B).withOpacity(0.24),
              width: 0.8,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFF4EFE3),
            size: 16,
          ),
        ),
      ),
    );
  }
}

class _MishkahBackground extends StatelessWidget {
  const _MishkahBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MishkahBackgroundPainter(),
    );
  }
}

class _MishkahBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final softGold = Paint()
      ..color = const Color(0xFFC6A15B).withOpacity(0.032)
      ..style = PaintingStyle.fill;

    final softGreen = Paint()
      ..color = const Color(0xFF2C5142).withOpacity(0.075)
      ..style = PaintingStyle.fill;

    final line = Paint()
      ..color = const Color(0xFFC6A15B).withOpacity(0.031)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(
      Offset(size.width * 0.87, size.height * 0.08),
      size.width * 0.48,
      softGreen,
    );

    canvas.drawCircle(
      Offset(size.width * 0.05, size.height * 0.54),
      size.width * 0.37,
      softGold,
    );

    const spacing = 64.0;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final center = Offset(x, y);

        final outer = Path()
          ..moveTo(center.dx, center.dy - 12)
          ..lineTo(center.dx + 12, center.dy)
          ..lineTo(center.dx, center.dy + 12)
          ..lineTo(center.dx - 12, center.dy)
          ..close();

        canvas.drawPath(outer, line);

        final inner = Path()
          ..moveTo(center.dx, center.dy - 5)
          ..lineTo(center.dx + 5, center.dy)
          ..lineTo(center.dx, center.dy + 5)
          ..lineTo(center.dx - 5, center.dy)
          ..close();

        canvas.drawPath(inner, line);
      }
    }

    final archPaint = Paint()
      ..color = const Color(0xFFF4EFE3).withOpacity(0.018)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final archWidth = size.width * 0.34;

    final arch = Path()
      ..moveTo(size.width - archWidth - 24, size.height * 0.72)
      ..lineTo(
        size.width - archWidth - 24,
        size.height * 0.86,
      )
      ..cubicTo(
        size.width - archWidth - 24,
        size.height * 0.59,
        size.width - 24,
        size.height * 0.59,
        size.width - 24,
        size.height * 0.86,
      )
      ..lineTo(size.width - 24, size.height * 0.72);

    canvas.drawPath(arch, archPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
