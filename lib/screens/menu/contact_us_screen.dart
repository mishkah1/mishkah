import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textSecondary = Color(0xFFA8B0AA);

  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

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
              'تم الإرسال',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                color: _ivory,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'شكرًا لتواصلك معنا، تم استلام استفسارك بنجاح.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                color: _textSecondary,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  messageController.clear();
                },
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
                'تواصل معنا',
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
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'يسعدنا تواصلك معنا',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _ivory,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'إذا كان لديك استفسار أو اقتراح أو ملاحظة، اكتبها لنا وسنسعد بالاطلاع عليها.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                  fontSize: 13,
                  height: 1.7,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'للتواصل والاستفسارات العامة',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _gold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _surfaceRaised,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: _gold,
                        size: 22,
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
                              'البريد الإلكتروني',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily:
                                    GoogleFonts.ibmPlexSansArabic().fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _ivory,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'mishkah@example.com',
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily:
                                    GoogleFonts.ibmPlexSansArabic().fontFamily,
                                fontSize: 12,
                                color: _textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'للاستفسارات والاقتراحات',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _gold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
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
                        'الاستفسار أو الرسالة',
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
                    const SizedBox(height: 10),
                    TextField(
                      controller: messageController,
                      maxLines: 6,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        color: _ivory,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب استفسارك أو رسالتك هنا...',
                        hintTextDirection: TextDirection.rtl,
                        hintStyle: TextStyle(
                          color: _textSecondary,
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: _surfaceRaised,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: _border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: _border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: _gold, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C5142),
                          foregroundColor: _ivory,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: _gold.withOpacity(0.18)),
                          ),
                        ),
                        child: Text(
                          'إرسال',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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