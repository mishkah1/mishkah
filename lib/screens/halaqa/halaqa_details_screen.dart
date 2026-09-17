import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkah/screens/halaqa/halaqa_registration_screen.dart';

import '../../models/dar_model.dart';
import '../../models/halaqa_model.dart';

class HalaqaDetailsScreen extends StatelessWidget {
  final HalaqaModel halaqa;
  final DarModel? dar;

  const HalaqaDetailsScreen({
    super.key,
    required this.halaqa,
    this.dar,
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
                    'تفاصيل الحلقة',
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
                        _buildHeaderCard(),
                        const SizedBox(height: 16),
                        _buildInfoGrid(),
                        const SizedBox(height: 16),
                        _buildContactCard(),
                        const SizedBox(height: 22),
                        _buildRegisterButton(context),
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

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _surfaceElevated,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: _gold.withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: _gold,
              size: 28,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            halaqa.name,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: _displayFont(
              size: 24,
              weight: FontWeight.w700,
              color: _cream,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dar != null ? dar!.name : 'حلقة أونلاين',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: _bodyFont(
              size: 12,
              color: _muted,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 48,
            height: 1,
            color: _gold.withOpacity(0.50),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    final items = <(String, String)>[
      (
        'الموقع',
        halaqa.attendanceType == AttendanceType.online
            ? 'أونلاين'
            : (dar?.address ?? 'غير محدد'),
      ),
      (
        'الحضور',
        halaqa.attendanceType == AttendanceType.online
            ? 'أونلاين'
            : 'حضوري',
      ),
      (
        'الوقت',
        halaqa.attendanceType == AttendanceType.online
            ? _onlineTimes
            : halaqa.time.label,
      ),
      ('الفئة', halaqa.category.label),
      if (halaqa.attendanceType == AttendanceType.inPerson)
        (
          'الحضانة',
          halaqa.hasDaycare == null
              ? 'غير محدد'
              : (halaqa.hasDaycare! ? 'متوفرة' : 'غير متوفرة'),
        ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      childAspectRatio: 2.35,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _surface.withOpacity(0.97),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 3,
                    height: 35,
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            item.$1,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _bodyFont(
                              size: 9.5,
                              weight: FontWeight.w500,
                              color: _muted,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            item.$2,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _bodyFont(
                              size: 11.5,
                              weight: FontWeight.w700,
                              color: _cream,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  String get _onlineTimes {
    final times = <String>[
      halaqa.time.label,
      if (halaqa.time2 != null && halaqa.time2!.trim().isNotEmpty)
        halaqa.time2!.trim(),
      if (halaqa.time3 != null && halaqa.time3!.trim().isNotEmpty)
        halaqa.time3!.trim(),
    ];

    return times.join(' - ');
  }

  Widget _buildContactCard() {
    if (halaqa.attendanceType == AttendanceType.online) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface.withOpacity(0.97),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _border),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.videocam_outlined,
                size: 18,
                color: _gold,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'رابط الاجتماع سيتوفر بعد التسجيل',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: _bodyFont(
                  size: 12,
                  color: _muted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.97),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (dar != null)
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: _gold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dar!.address,
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
          if (halaqa.contactPhone != null) ...[
            const SizedBox(height: 9),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: _gold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    halaqa.contactPhone!,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: _bodyFont(
                      size: 12,
                      color: _muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkGreen,
          foregroundColor: _cream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: _gold.withOpacity(0.18),
            ),
          ),
        ),
        onPressed: () => _handleRegister(context),
        icon: const Icon(
          Icons.open_in_new,
          color: _goldLight,
          size: 17,
        ),
        label: Text(
          'سجل الآن',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: _bodyFont(
            size: 13,
            weight: FontWeight.w800,
            color: _cream,
          ),
        ),
      ),
    );
  }

  void _handleRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HalaqaRegistrationScreen(
          halaqa: halaqa,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

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
      ..lineTo(size.width - archWidth - 24, size.height * 0.86)
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
