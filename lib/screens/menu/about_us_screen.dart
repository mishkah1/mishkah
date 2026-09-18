import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textSecondary = Color(0xFFA8B0AA);

  @override
  Widget build(BuildContext context) {
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
                'من نحن',
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: _surfaceRaised,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _gold.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: _gold,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'مِشكاة',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: _ivory,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'طريقك إلى القرآن والعمل',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                  fontSize: 12,
                  color: _goldLight,
                ),
              ),
              const SizedBox(height: 28),
              _buildCard(
                icon: Icons.lightbulb_outline_rounded,
                title: 'فكرة مِشكاة',
                text:
                    'مِشكاة منصة تجمع لك البرامج والدور القرآنية والمبادرات التعليمية في مكان واحد، لتسهّل عليك الوصول إلى ما يناسبك من فرص الخير والتعلّم.',
              ),
              const SizedBox(height: 12),
              _buildCard(
                icon: Icons.explore_outlined,
                title: 'هدفنا',
                text:
                    'نسعى إلى جعل الوصول إلى البرامج القرآنية والعلمية أكثر سهولة ووضوحًا، ومساعدة المستخدم على اكتشاف الفرص المناسبة له والتسجيل فيها.',
              ),
              const SizedBox(height: 12),
              _buildCard(
                icon: Icons.handshake_outlined,
                title: 'ما الذي نقدمه؟',
                text:
                    'استعراض الدور والحلقات، معرفة تفاصيل البرامج ومواعيدها، متابعة الفرص القادمة، التسجيل في البرامج، وحفظ ما يهمك للرجوع إليه لاحقًا.',
              ),
              const SizedBox(height: 24),
              Text(
                'مِشكاة',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'رفيقك نحو الخير والعلم',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                  fontSize: 11,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _surfaceRaised,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _gold,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    title,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _ivory,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    text,
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
        ],
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
