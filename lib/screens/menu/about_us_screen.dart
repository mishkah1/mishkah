import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  final VoidCallback? onBackToMenu;

  const AboutUsScreen({
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
            'من نحن',
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
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: _darkGreen,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Color(0xFFFFF8EA),
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'مِشكاة',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: _darkGreen,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'طريقك إلى القرآن والعمل',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: _brown,
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
              const Text(
                'مِشكاة',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'رفيقك نحو الخير والعلم',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: _muted,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _text,
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
        ],
      ),
    );
  }
}