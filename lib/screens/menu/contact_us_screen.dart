import 'package:flutter/material.dart';

class ContactUsScreen extends StatefulWidget {
  final VoidCallback? onBackToMenu;

  const ContactUsScreen({
    super.key,
    this.onBackToMenu,
  });

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  static const _darkGreen = Color(0xFF24483A);
  static const _cream = Color(0xFFF7F5EF);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);

  final TextEditingController messageController =
      TextEditingController();

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
            backgroundColor: _cream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'تم الإرسال',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'شكرًا لتواصلك معنا، تم استلام استفسارك بنجاح.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _muted,
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
            'تواصل معنا',
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'يسعدنا تواصلك معنا',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _darkGreen,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'إذا كان لديك استفسار أو اقتراح أو ملاحظة، اكتبها لنا وسنسعد بالاطلاع عليها.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.7,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'للتواصل والاستفسارات العامة',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _darkGreen,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE7E3D9),
                  ),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE8DC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: _darkGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
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
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _text,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'mishkah@example.com',
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                color: _muted,
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

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'للاستفسارات والاقتراحات',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _darkGreen,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE7E3D9),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'الاستفسار أو الرسالة',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: messageController,
                      maxLines: 6,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'اكتب استفسارك أو رسالتك هنا...',
                        hintTextDirection: TextDirection.rtl,
                        hintStyle: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: _cream,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1DCCE),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1DCCE),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _darkGreen,
                            width: 1.2,
                          ),
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
                          backgroundColor: _darkGreen,
                          foregroundColor: const Color(0xFFFFF8EA),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'إرسال',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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