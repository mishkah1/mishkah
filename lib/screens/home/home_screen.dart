import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'التأصيل الشرعي',
      'icon': Icons.auto_stories_outlined,
    },
    {
      'title': 'التحفيظ',
      'icon': Icons.menu_book_outlined,
    },
    {
      'title': 'التجويد',
      'icon': Icons.record_voice_over_outlined,
    },
    {
      'title': 'الدور',
      'icon': Icons.mosque_outlined,
    },
  ];

  final List<Map<String, String>> registrationOpen = const [
    {
      'title': 'دار النور',
      'subtitle': 'حلقة تحفيظ القرآن الكريم',
      'location': 'حي الملقا',
    },
    {
      'title': 'دار الإتقان',
      'subtitle': 'برنامج حفظ ومراجعة',
      'location': 'حي الياسمين',
    },
    {
      'title': 'دار الهدى',
      'subtitle': 'حلقة تجويد وتأصيل',
      'location': 'حي النخيل',
    },
    {
      'title': 'دار الفرقان',
      'subtitle': 'برنامج التحفيظ المكثف',
      'location': 'حي الروضة',
    },
    {
      'title': 'دار البيان',
      'subtitle': 'حلقة القرآن والتجويد',
      'location': 'حي الصحافة',
    },
  ];

  final List<Map<String, String>> comingSoon = const [
    {
      'title': 'برنامج إتقان التلاوة',
      'subtitle': 'برنامج تدريبي في أحكام التجويد وتحسين التلاوة',
      'date': 'يبدأ قريبًا',
    },
    {
      'title': 'حلقة الحفظ والمراجعة',
      'subtitle': 'حلقة مخصصة للحفظ مع المتابعة والمراجعة المستمرة',
      'date': 'يبدأ قريبًا',
    },
    {
      'title': 'برنامج التأصيل الشرعي',
      'subtitle': 'مسار تعليمي مبسط في العلوم الشرعية الأساسية',
      'date': 'يبدأ قريبًا',
    },
    {
      'title': 'دورة تدبر القرآن',
      'subtitle': 'لقاءات تساعد على فهم الآيات والتدبر في معانيها',
      'date': 'يبدأ قريبًا',
    },
    {
      'title': 'برنامج مهارات الحافظ',
      'subtitle': 'طرق عملية لتنظيم الحفظ وتثبيت المراجعة',
      'date': 'يبدأ قريبًا',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EF),
      endDrawer: const _SideDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          backgroundColor: const Color(0xFF24483A),
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'مِشكاة',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Color(0xFFFFF8EA),
              shadows: [
                Shadow(
                  color: Color(0x55000000),
                  blurRadius: 7,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Color(0xFFFFF8EA),
                    size: 28,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFFFFF8EA),
              size: 27,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ScrollConfiguration(
          behavior: const _NoStretchBehavior(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const TextField(
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم الدار أو الحي …',
                      hintTextDirection: TextDirection.rtl,
                      hintStyle: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF24483A),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: categories.map((category) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          height: 74,
                          decoration: BoxDecoration(
                            color: const Color(0xFF24483A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category['icon'],
                                color: const Color(0xFFFFF8EA),
                                size: 22,
                              ),
                              const SizedBox(height: 7),
                              Text(
                                category['title'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFF8EA),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'مفتوح التسجيل',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF24483A),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                SizedBox(
                  height: 170,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: PageView.builder(
                      controller: PageController(
                        viewportFraction: 0.82,
                      ),
                      physics: const PageScrollPhysics(),
                      itemCount: registrationOpen.length,
                      padEnds: false,
                      itemBuilder: (context, index) {
                        final item = registrationOpen[index];

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _RegistrationCard(
                            title: item['title']!,
                            subtitle: item['subtitle']!,
                            location: item['location']!,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'قريبًا',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF24483A),
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                ...comingSoon.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: _ComingSoonCard(
                      title: item['title']!,
                      subtitle: item['subtitle']!,
                      date: item['date']!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String location;

  const _RegistrationCard({
    required this.title,
    required this.subtitle,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE7E3D9),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F0EB),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.mosque_outlined,
                    color: Color(0xFF24483A),
                    size: 23,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF24483A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
                height: 1.4,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: Color(0xFF777777),
                ),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;

  const _ComingSoonCard({
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE7E3D9),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE9F0EB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.auto_stories_outlined,
                color: Color(0xFF24483A),
                size: 24,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF24483A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9A7955),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoStretchBehavior extends ScrollBehavior {
  const _NoStretchBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _SideDrawer extends StatelessWidget {
  const _SideDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF24483A),
      width: MediaQuery.of(context).size.width * 0.78,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 45, 24, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'مِشكاة',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFF8EA),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'رفيقك نحو الخير والعلم',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFDCE8E1),
                    ),
                  ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              onTap: () {},
            ),
            _DrawerItem(
              icon: Icons.help_outline_rounded,
              title: 'الأسئلة الشائعة',
              onTap: () {},
            ),
            _DrawerItem(
              icon: Icons.info_outline_rounded,
              title: 'من نحن',
              onTap: () {},
            ),
            _DrawerItem(
              icon: Icons.mail_outline_rounded,
              title: 'تواصل معنا',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 24,
        bottom: 5,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              icon,
              color: const Color(0xFFFFF8EA),
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFF8EA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}