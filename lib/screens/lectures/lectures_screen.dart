import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/lecture_model.dart';
import '../../repositories/dar_repository.dart';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  // هوية Mishkah الموحدة
  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceElevated = Color(0xFF1B2B24);
  static const _darkGreen = Color(0xFF2C5142);
  static const _cream = Color(0xFFF4EFE3);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _muted = Color(0xFFA8B0AA);
  static const _border = Color(0xFF293A32);

  final DarRepository _repository = DarRepository();

  late Future<List<LectureModel>> _lecturesFuture;

  @override
  void initState() {
    super.initState();
    _lecturesFuture = _repository.fetchLectures();
  }

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

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
                    'المحاضرات',
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
                SliverFillRemaining(
                  child: FutureBuilder<List<LectureModel>>(
                    future: _lecturesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: _gold),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'حدث خطأ أثناء تحميل المحاضرات',
                            textDirection: TextDirection.rtl,
                            style: _bodyFont(size: 13, color: _muted),
                          ),
                        );
                      }

                      final lectures = snapshot.data ?? [];

                      if (lectures.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد محاضرات حاليًا',
                            textDirection: TextDirection.rtl,
                            style: _bodyFont(size: 13, color: _muted),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: _gold,
                        backgroundColor: _surfaceElevated,
                        onRefresh: () async {
                          setState(() {
                            _lecturesFuture = _repository.fetchLectures();
                          });
                          await _lecturesFuture;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                          itemCount: lectures.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            return _buildLectureCard(lectures[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureCard(LectureModel lecture) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.98),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الصف العلوي: اليوم والفترة يمين، الوقت يسار
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lecture.timeRangeLabel,
                textDirection: TextDirection.rtl,
                style: _bodyFont(size: 11.5, color: _muted),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  lecture.scheduleLabel,
                  textDirection: TextDirection.rtl,
                  style: _bodyFont(
                    size: 11.5,
                    color: _goldLight,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // اسم المحاضرة
          Text(
            lecture.title,
            textDirection: TextDirection.rtl,
            style: _bodyFont(
              size: 15,
              weight: FontWeight.w700,
              color: _cream,
            ),
          ),
          const SizedBox(height: 4),

          // اسم المحاضر
          Text(
            lecture.speakerName,
            textDirection: TextDirection.rtl,
            style: _bodyFont(size: 12.5, color: _muted),
          ),
          const SizedBox(height: 14),

          // الزر السفلي
          SizedBox(
            width: double.infinity,
            child: lecture.hasLink
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: _gold.withOpacity(0.18),
                        ),
                      ),
                    ),
                    onPressed: () => _openLink(lecture.link!),
                    icon: const Icon(Icons.open_in_new,
                        color: _gold, size: 16),
                    label: Text(
                      'دخول المحاضرة',
                      style: _bodyFont(size: 13.5, color: _cream),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'سيتوفر قريبًا',
                      style: _bodyFont(size: 13.5, color: _muted),
                    ),
                  ),
          ),
        ],
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