import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/halaqa_model.dart';
import '../../services/local_saved_service.dart';

class HalaqaRegistrationScreen extends StatefulWidget {
  final HalaqaModel halaqa;

  const HalaqaRegistrationScreen({
    super.key,
    required this.halaqa,
  });

  @override
  State<HalaqaRegistrationScreen> createState() =>
      _HalaqaRegistrationScreenState();
}

class _HalaqaRegistrationScreenState
    extends State<HalaqaRegistrationScreen> {

  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceElevated = Color(0xFF1B2B24);
  static const _darkGreen = Color(0xFF2C5142);
  static const _cream = Color(0xFFF4EFE3);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _muted = Color(0xFFA8B0AA);
  static const _border = Color(0xFF293A32);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;

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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
                    'التسجيل بالحلقة',
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
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildIntroCard(),
                          const SizedBox(height: 18),
                          _buildLabel('الاسم الكامل'),
                          _buildTextField(
                            controller: _nameController,
                            hint: 'مثال: سارة عبدالله',
                            keyboardType: TextInputType.name,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'الاسم مطلوب'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('تاريخ الميلاد'),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildDayDropdown(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: _buildMonthDropdown(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: _buildYearDropdown(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('رقم الجوال'),
                          _buildTextField(
                            controller: _phoneController,
                            hint: '05xxxxxxxx',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'رقم الجوال مطلوب';
                              }
                              if (value.trim().length < 9) {
                                return 'رقم الجوال غير صحيح';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildRegisterButton(),
                        ],
                      ),
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

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.98),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
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
              size: 27,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            widget.halaqa.name,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: _displayFont(
              size: 23,
              color: _cream,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'عبّي بياناتك عشان نكمّل تسجيلك بالحلقة',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: _bodyFont(
              size: 11.5,
              color: _muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 13),
          Container(
            width: 46,
            height: 1,
            color: _gold.withOpacity(0.45),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: _bodyFont(
          size: 12,
          color: _cream,
          weight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: _border,
      ),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      cursorColor: _gold,
      validator: validator,
      style: _bodyFont(
        size: 12.5,
        color: _cream,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        hintStyle: _bodyFont(
          size: 12,
          color: _muted.withOpacity(0.82),
        ),
        filled: true,
        fillColor: _surface.withOpacity(0.97),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: _gold.withOpacity(0.65),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFB97A6A),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFB97A6A),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(
        color: _border,
      ),
    );

    return InputDecoration(
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      hintStyle: _bodyFont(
        size: 11.5,
        color: _muted,
      ),
      filled: true,
      fillColor: _surface.withOpacity(0.97),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 12,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: _gold.withOpacity(0.65),
          width: 1.2,
        ),
      ),
    );
  }

  Widget _buildDayDropdown() {
    final days = List.generate(31, (i) => i + 1);

    return DropdownButtonFormField<int>(
      value: _selectedDay,
      isExpanded: true,
      dropdownColor: _surfaceElevated,
      iconEnabledColor: _gold,
      style: _bodyFont(
        size: 12,
        color: _cream,
      ),
      decoration: _dropdownDecoration('اليوم'),

      selectedItemBuilder: (context) {
        return days
            .map(
              (day) => Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$day',
                  textDirection: TextDirection.rtl,
                  style: _bodyFont(
                    size: 12.5,
                    color: _cream,
                  ),
                ),
              ),
            )
            .toList();
      },
      items: days
          .map(
            (day) => DropdownMenuItem(
              value: day,
              child: Text(
                '$day',
                textDirection: TextDirection.rtl,
                style: _bodyFont(
                  size: 12.5,
                  color: _cream,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedDay = value),
      validator: (value) => value == null ? 'مطلوب' : null,
    );
  }

  Widget _buildMonthDropdown() {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return DropdownButtonFormField<int>(
      value: _selectedMonth,
      isExpanded: true,
      dropdownColor: _surfaceElevated,
      iconEnabledColor: _gold,
      style: _bodyFont(
        size: 12,
        color: _cream,
      ),
      decoration: _dropdownDecoration('الشهر'),
      selectedItemBuilder: (context) {
        return List.generate(12, (i) => i + 1).map((month) {
          return Align(
            alignment: Alignment.centerRight,
            child: Text(
              months[month - 1],
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
              style: _bodyFont(
                size: 12,
                color: _cream,
              ),
            ),
          );
        }).toList();
      },
      items: List.generate(12, (i) => i + 1)
          .map(
            (month) => DropdownMenuItem(
              value: month,
              child: Text(
                months[month - 1],
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                style: _bodyFont(
                  size: 12,
                  color: _cream,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedMonth = value),
      validator: (value) => value == null ? 'مطلوب' : null,
    );
  }

  Widget _buildYearDropdown() {
    final currentYear = DateTime.now().year;
    final years = List.generate(80, (i) => currentYear - i);

    return DropdownButtonFormField<int>(
      value: _selectedYear,
      isExpanded: true,
      dropdownColor: _surfaceElevated,
      iconEnabledColor: _gold,
      style: _bodyFont(
        size: 12,
        color: _cream,
      ),
      decoration: _dropdownDecoration('السنة'),
      selectedItemBuilder: (context) {
        return years
            .map(
              (year) => Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$year',
                  textDirection: TextDirection.rtl,
                  style: _bodyFont(
                    size: 12.5,
                    color: _cream,
                  ),
                ),
              ),
            )
            .toList();
      },
      items: years
          .map(
            (year) => DropdownMenuItem(
              value: year,
              child: Text(
                '$year',
                textDirection: TextDirection.rtl,
                style: _bodyFont(
                  size: 12.5,
                  color: _cream,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedYear = value),
      validator: (value) => value == null ? 'مطلوب' : null,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submit,
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
        child: Text(
          'تسجيل',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: _bodyFont(
            size: 13.5,
            weight: FontWeight.w800,
            color: _cream,
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final savedItem = SavedItem(
      id: widget.halaqa.id,
      title: widget.halaqa.name,
      subtitle: widget.halaqa.focus.label,
      description: 'تم التسجيل في هذه الحلقة',
      location: widget.halaqa.attendanceType == AttendanceType.online
          ? 'أونلاين'
          : 'حضوري',
      attendance: widget.halaqa.attendanceType,
      image: 'assets/images/onboarding_1.png',
      imageIsNetwork: false,
      halaqa: widget.halaqa,
      dar: null,
      showDarName: false,
    );

    LocalSavedService.instance.addRegistration(savedItem);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 28,
              horizontal: 24,
            ),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _gold.withOpacity(0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gold.withOpacity(0.10),
                    border: Border.all(
                      color: _gold.withOpacity(0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: _goldLight,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'تم التسجيل بنجاح',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: _displayFont(
                    size: 20,
                    color: _cream,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'راح يتواصلون معك قريبًا لتأكيد الموعد',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: _bodyFont(
                    size: 12,
                    color: _muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      foregroundColor: _cream,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: _gold.withOpacity(0.18),
                        ),
                      ),
                    ),
                    child: Text(
                      'العودة',
                      textDirection: TextDirection.rtl,
                      style: _bodyFont(
                        size: 13,
                        weight: FontWeight.w700,
                        color: _cream,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
