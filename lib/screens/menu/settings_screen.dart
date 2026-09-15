import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBackToMenu;

  const SettingsScreen({
    super.key,
    this.onBackToMenu,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _darkGreen = Color(0xFF24483A);
  static const _cream = Color(0xFFF7F5EF);
  static const _brown = Color(0xFF9A7955);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);

  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: _darkGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Color(0xFFFFF8EA),
            ),
            onPressed: () {
              if (widget.onBackToMenu != null) {
                widget.onBackToMenu!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text(
            'الإعدادات',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xFFFFF8EA),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
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
                activeThumbColor: _darkGreen,
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
                color: _muted,
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
                color: _muted,
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
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _brown,
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
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
                  color: const Color(0xFFEDE8DC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: _darkGreen,
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
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: _text,
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
                        style: const TextStyle(
                          fontSize: 11,
                          color: _muted,
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
            backgroundColor: _cream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'اللغة',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(
                  title: 'العربية',
                  selected: true,
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  title: 'English',
                  selected: false,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'تم',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 13,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFEDE8DC)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
            color: _darkGreen,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              textDirection: title == 'English'
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _text,
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

  static const _darkGreen = Color(0xFF24483A);
  static const _cream = Color(0xFFF7F5EF);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: _darkGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Color(0xFFFFF8EA),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'الخصوصية',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Color(0xFFFFF8EA),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
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

  Widget _privacyCard({
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE7E3D9),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                title,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _darkGreen,
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
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.8,
                  color: _muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}