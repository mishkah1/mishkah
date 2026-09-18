import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textSecondary = Color(0xFFA8B0AA);

  bool _darkMode = true;

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
                'الإعدادات',
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
            _buildSectionTitle('المظهر'),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.dark_mode_outlined,
              title: 'الوضع الداكن',
              subtitle: 'تغيير مظهر التطبيق إلى الوضع الداكن',
              trailing: Switch(
                value: _darkMode,
                activeThumbColor: _gold,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('التطبيق'),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.language_rounded,
              title: 'اللغة',
              subtitle: 'العربية',
              trailing: const Icon(
                Icons.chevron_left_rounded,
                color: _textSecondary,
              ),
              onTap: _showLanguageDialog,
            ),
            const SizedBox(height: 10),
            _buildSettingCard(
              icon: Icons.lock_outline_rounded,
              title: 'الخصوصية',
              subtitle: 'سياسة الخصوصية وشروط الاستخدام',
              trailing: const Icon(
                Icons.chevron_left_rounded,
                color: _textSecondary,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('حول التطبيق'),
            const SizedBox(height: 8),
            _buildSettingCard(
              icon: Icons.info_outline_rounded,
              title: 'إصدار التطبيق',
              subtitle: '1.0.0',
              trailing: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _gold,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          child: Row(
            textDirection: TextDirection.rtl,
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
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _ivory,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        subtitle,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                          fontSize: 11,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: _surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: _border),
            ),
            title: Text(
              'اللغة',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                color: _ivory,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(title: 'العربية', selected: true),
                const SizedBox(height: 8),
                _buildLanguageOption(title: 'English', selected: false),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'تم',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                    color: _gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required bool selected,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? _surfaceRaised : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
            color: _gold,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              textDirection:
                  title == 'English' ? TextDirection.ltr : TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                color: _ivory,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
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
                'الخصوصية',
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
            _privacyCard(
              title: 'سياسة الخصوصية',
              text:
                  'نحرص في مِشكاة على حماية بيانات المستخدم واستخدامها فقط لتقديم خدمات التطبيق وتحسين تجربة الاستخدام.',
            ),
            _privacyCard(
              title: 'استخدام البيانات',
              text:
                  'قد نستخدم البيانات التي تقدمها لنا عند التسجيل أو استخدام بعض خدمات التطبيق لتسهيل تجربتك وتقديم الخدمات المرتبطة بالبرامج والدور.',
            ),
            _privacyCard(
              title: 'حماية المعلومات',
              text:
                  'نسعى إلى حماية معلومات المستخدم وعدم استخدامها إلا للأغراض المرتبطة بخدمات مِشكاة وتحسين تجربة الاستخدام.',
            ),
            _privacyCard(
              title: 'شروط الاستخدام',
              text:
                  'باستخدامك لتطبيق مِشكاة، فإنك توافق على استخدام التطبيق بشكل مسؤول وللغرض المخصص له.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _privacyCard({required String title, required String text}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
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
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _gold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                fontSize: 13,
                height: 1.8,
                color: _textSecondary,
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
