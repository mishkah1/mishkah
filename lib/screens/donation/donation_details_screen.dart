import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/dar_model.dart';

class DonationScreen extends StatelessWidget {
  final DarModel dar;

  const DonationScreen({super.key, required this.dar});

  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceElevated = Color(0xFF1B2B24);
  static const _darkGreen = Color(0xFF2C5142);
  static const _cream = Color(0xFFF4EFE3);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _muted = Color(0xFFA8B0AA);
  static const _border = Color(0xFF293A32);

  static const _bannerImage = 'assets/images/donation_banner.jpg';

  static const _donationLink = 'https://maknon.org.sa/';

  static const _verseSource = 'سورة البقرة - آية 245';

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

  Future<void> _openDonationLink(BuildContext context) async {
    final uri = Uri.parse(_donationLink);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showLinkError(context);
      }
    } catch (e) {
      if (context.mounted) {
        _showLinkError(context);
      }
    }
  }

  void _showLinkError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _surfaceElevated,
        content: Text(
          'تعذر فتح رابط التبرع',
          textDirection: TextDirection.rtl,
          style: _bodyFont(size: 13, color: _cream),
        ),
      ),
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
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  pinned: true,
                  expandedHeight: 96,
                  automaticallyImplyLeading: false,
                  title: Text(
                    'التبرع',
                    textDirection: TextDirection.rtl,
                    style: _displayFont(
                      size: 22,
                      color: _cream,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: _gold,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBannerImage(),
                        const SizedBox(height: 18),
                        _buildVerseCard(),
                        const SizedBox(height: 18),
                        _buildDonationCard(context),
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

  Widget _buildBannerImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.asset(
        _bannerImage,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: _surface.withOpacity(0.98),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
          ),
          child: Icon(
            Icons.image_outlined,
            color: _muted,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildVerseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Text(
            'مَّن ذَا الَّذِي يُقْرِضُ اللَّهَ قَرْضًا حَسَنًا',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: _cream,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'فَيُضَاعِفَهُ لَهُ أَضْعَافًا كَثِيرَةً',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: _cream,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _verseSource,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 11.5,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDonationLink(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _darkGreen,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _gold.withOpacity(0.18),
            ),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _cream.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: _gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'تبرع الآن في جمعية مكنون',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: _bodyFont(
                        size: 14.5,
                        weight: FontWeight.w700,
                        color: _cream,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'راح ينقلك لصفحة التبرع بموقع الجمعية المحتضنة',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: _bodyFont(
                        size: 11.5,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_back_ios,
                color: _gold,
                size: 14,
              ),
            ],
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
      Offset(size.width * 0.86, size.height * 0.09),
      size.width * 0.46,
      softGreen,
    );

    canvas.drawCircle(
      Offset(size.width * 0.06, size.height * 0.58),
      size.width * 0.36,
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
      ..moveTo(size.width - archWidth - 24, size.height * 0.73)
      ..lineTo(size.width - archWidth - 24, size.height * 0.86)
      ..cubicTo(
        size.width - archWidth - 24,
        size.height * 0.60,
        size.width - 24,
        size.height * 0.60,
        size.width - 24,
        size.height * 0.86,
      )
      ..lineTo(size.width - 24, size.height * 0.73);

    canvas.drawPath(arch, archPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
