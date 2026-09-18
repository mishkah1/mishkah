import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeqScreen extends StatelessWidget {
  const FeqScreen({super.key});

  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textSecondary = Color(0xFFA8B0AA);

  @override
  Widget build(BuildContext context) {
    final questions = [
      (
        'ما هو تطبيق مِشكاة؟',
        'مِشكاة منصة تجمع البرامج والدور القرآنية والمبادرات التعليمية في مكان واحد، لتسهيل الوصول إليها ومعرفة تفاصيلها والتسجيل فيها.',
      ),
      (
        'كيف أستطيع التسجيل في برنامج؟',
        'يمكنك الدخول إلى تفاصيل الحلقة أو البرنامج، ثم الضغط على زر «سجل الآن» وإكمال البيانات المطلوبة.',
      ),
      (
        'هل يمكنني حفظ برنامج للرجوع إليه لاحقًا؟',
        'نعم، يمكنك الضغط على علامة القلب في بطاقة البرنامج لحفظه ضمن المفضلات الموجودة في حسابك.',
      ),
      (
        'ما فائدة علامة الجرس؟',
        'علامة الجرس مخصصة لتفعيل التنبيهات الخاصة بالبرنامج، مثل التنبيه عند فتح التسجيل أو وجود تحديثات جديدة.',
      ),
      (
        'هل يمكنني إلغاء التسجيل؟',
        'يمكنك مراجعة تسجيلاتك من خلال قسم «تسجيلاتي» في حسابك، وستتوفر خيارات الإلغاء بحسب البرنامج.',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              backgroundColor: _background,
              elevation: 0,
              automaticallyImplyLeading: false,
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _BackButton(onTap: () => Navigator.pop(context)),
              ),
              title: Text(
                'الأسئلة الشائعة',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _ivory,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'كيف يمكننا مساعدتك؟',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: _ivory,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'إجابات عن أكثر الأسئلة شيوعًا حول مِشكاة.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                fontSize: 12,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ...questions.map(
              (question) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    iconColor: _goldLight,
                    collapsedIconColor: _goldLight,
                    title: Text(
                      question.$1,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _ivory,
                      ),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          question.$2,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                            fontSize: 12,
                            height: 1.7,
                            color: _textSecondary,
                          ),
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