import 'package:flutter/material.dart';

class FeqScreen extends StatelessWidget {
  final VoidCallback? onBackToMenu;

  const FeqScreen({
    super.key,
    this.onBackToMenu,
  });

  static const _darkGreen = Color(0xFF24483A);
  static const _cream = Color(0xFFF7F5EF);
  static const _brown = Color(0xFF9A7955);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);

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
              if (onBackToMenu != null) {
                onBackToMenu!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text(
            'الأسئلة الشائعة',
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
            const Text(
              'كيف يمكننا مساعدتك؟',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: _darkGreen,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'إجابات عن أكثر الأسئلة شيوعًا حول مِشكاة.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: _muted,
              ),
            ),
            const SizedBox(height: 18),
            ...questions.map(
              (question) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE7E3D9),
                  ),
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
                    childrenPadding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      16,
                    ),
                    iconColor: _brown,
                    collapsedIconColor: _brown,
                    title: Text(
                      question.$1,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _text,
                      ),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          question.$2,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.7,
                            color: _muted,
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