import 'package:flutter/material.dart';
import 'package:mishkah/models/dar_model.dart';
import 'package:mishkah/models/halaqa_model.dart';
import 'package:mishkah/repositories/dar_repository.dart';
import 'package:mishkah/screens/account/account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController registrationController = PageController(
    viewportFraction: 0.82,
  );

  final DarRepository repository = DarRepository();

  List<DarModel> dars = [];
  List<HalaqaModel> halaqas = [];
  bool isLoading = true;

  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'الترتيل',
      'icon': Icons.auto_stories_outlined,
    },
    {
      'title': 'الحفظ',
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

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        repository.fetchAllDars(),
        repository.fetchAllHalaqas(),
      ]);

      if (!mounted) return;

      setState(() {
        dars = results[0] as List<DarModel>;
        halaqas = results[1] as List<HalaqaModel>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  List<HalaqaModel> getHalaqasByFocus(
    HalaqaFocus focus,
    RegistrationStatus status,
  ) {
    return halaqas
        .where(
          (halaqa) =>
              halaqa.focus == focus &&
              halaqa.registrationStatus == status,
        )
        .toList();
  }

  HalaqaModel? getDarHalaqa(RegistrationStatus status) {
    final darHalaqas = halaqas
        .where(
          (halaqa) =>
              halaqa.darId != null &&
              halaqa.darId!.isNotEmpty &&
              halaqa.registrationStatus == status,
        )
        .toList();

    if (darHalaqas.isEmpty) {
      return null;
    }

    return darHalaqas.first;
  }

  DarModel? getDarById(String darId) {
    for (final dar in dars) {
      if (dar.id == darId) {
        return dar;
      }
    }

    return null;
  }

  String getLocation(HalaqaModel halaqa) {
    if (halaqa.attendanceType == AttendanceType.online) {
      return 'أونلاين';
    }

    if (halaqa.darId != null) {
      final dar = getDarById(halaqa.darId!);

      if (dar != null) {
        return dar.address;
      }
    }

    return 'حضوري';
  }

  String getImage(HalaqaModel halaqa) {
    if (halaqa.attendanceType == AttendanceType.online) {
      return 'assets/images/online.png';
    }

    return 'assets/images/in_person.png';
  }

  String getDescription(HalaqaModel halaqa) {
    switch (halaqa.focus) {
      case HalaqaFocus.tajweed:
        return 'برنامج يساعدك على تحسين التلاوة وإتقان أحكام التجويد';
      case HalaqaFocus.memorization:
        return 'حلقة للحفظ مع المتابعة والمراجعة المستمرة';
      case HalaqaFocus.recitation:
        return 'لقاءات لتحسين التلاوة والتدرب على القراءة الصحيحة';
      case HalaqaFocus.review:
        return 'حلقة مخصصة لمراجعة المحفوظ وتثبيته';
    }
  }

  HalaqaModel? chooseHalaqa(
    HalaqaFocus focus,
    RegistrationStatus status,
    Set<String> usedIds,
    bool preferOnline,
  ) {
    final candidates = getHalaqasByFocus(focus, status)
        .where((halaqa) => !usedIds.contains(halaqa.id))
        .toList();

    if (candidates.isEmpty) {
      return null;
    }

    if (preferOnline) {
      for (final halaqa in candidates) {
        if (halaqa.attendanceType == AttendanceType.online) {
          return halaqa;
        }
      }
    }

    for (final halaqa in candidates) {
      if (halaqa.attendanceType == AttendanceType.inPerson) {
        return halaqa;
      }
    }

    return candidates.first;
  }

  List<_HomeItem> getRegistrationItems() {
    final items = <_HomeItem>[];
    final usedIds = <String>{};

    final darHalaqa = getDarHalaqa(RegistrationStatus.open);

    if (darHalaqa != null && darHalaqa.darId != null) {
      final dar = getDarById(darHalaqa.darId!);

      if (dar != null) {
        usedIds.add(darHalaqa.id);

        items.add(
          _HomeItem(
            title: dar.name,
            subtitle: darHalaqa.name,
            description: 'دار تحفيظ تقدم حلقات وبرامج قرآنية متنوعة',
            location: darHalaqa.attendanceType == AttendanceType.online
                ? 'أونلاين'
                : dar.address,
            attendance: darHalaqa.attendanceType,
            image: dar.imageUrl != null &&
                    dar.imageUrl!.trim().isNotEmpty
                ? dar.imageUrl!
                : getImage(darHalaqa),
            imageIsNetwork: dar.imageUrl != null &&
                dar.imageUrl!.trim().isNotEmpty,
          ),
        );
      }
    }

    final tajweed = chooseHalaqa(
      HalaqaFocus.tajweed,
      RegistrationStatus.open,
      usedIds,
      true,
    );

    if (tajweed != null) {
      usedIds.add(tajweed.id);

      items.add(
        _HomeItem(
          title: tajweed.name,
          subtitle: 'حلقة تجويد',
          description: getDescription(tajweed),
          location: getLocation(tajweed),
          attendance: tajweed.attendanceType,
          image: getImage(tajweed),
        ),
      );
    }

    final memorization = chooseHalaqa(
      HalaqaFocus.memorization,
      RegistrationStatus.open,
      usedIds,
      false,
    );

    if (memorization != null) {
      usedIds.add(memorization.id);

      items.add(
        _HomeItem(
          title: memorization.name,
          subtitle: 'حلقة حفظ',
          description: getDescription(memorization),
          location: getLocation(memorization),
          attendance: memorization.attendanceType,
          image: getImage(memorization),
        ),
      );
    }

    final recitation = chooseHalaqa(
      HalaqaFocus.recitation,
      RegistrationStatus.open,
      usedIds,
      true,
    );

    if (recitation != null) {
      usedIds.add(recitation.id);

      items.add(
        _HomeItem(
          title: recitation.name,
          subtitle: 'حلقة ترتيل',
          description: getDescription(recitation),
          location: getLocation(recitation),
          attendance: recitation.attendanceType,
          image: getImage(recitation),
        ),
      );
    }

    return items.take(4).toList();
  }

  List<_HomeItem> getComingSoonItems() {
    final items = <_HomeItem>[];
    final usedIds = <String>{};

    final darHalaqa = getDarHalaqa(RegistrationStatus.comingSoon);

    if (darHalaqa != null && darHalaqa.darId != null) {
      final dar = getDarById(darHalaqa.darId!);

      if (dar != null) {
        usedIds.add(darHalaqa.id);

        items.add(
          _HomeItem(
            title: dar.name,
            subtitle: darHalaqa.name,
            description: 'دار تحفيظ تقدم حلقات وبرامج قرآنية متنوعة',
            location: darHalaqa.attendanceType == AttendanceType.online
                ? 'أونلاين'
                : dar.address,
            attendance: darHalaqa.attendanceType,
            image: dar.imageUrl != null &&
                    dar.imageUrl!.trim().isNotEmpty
                ? dar.imageUrl!
                : getImage(darHalaqa),
            imageIsNetwork: dar.imageUrl != null &&
                dar.imageUrl!.trim().isNotEmpty,
          ),
        );
      }
    }

    final tajweed = chooseHalaqa(
      HalaqaFocus.tajweed,
      RegistrationStatus.comingSoon,
      usedIds,
      true,
    );

    if (tajweed != null) {
      usedIds.add(tajweed.id);

      items.add(
        _HomeItem(
          title: tajweed.name,
          subtitle: 'حلقة تجويد',
          description: getDescription(tajweed),
          location: getLocation(tajweed),
          attendance: tajweed.attendanceType,
          image: getImage(tajweed),
        ),
      );
    }

    final memorization = chooseHalaqa(
      HalaqaFocus.memorization,
      RegistrationStatus.comingSoon,
      usedIds,
      false,
    );

    if (memorization != null) {
      usedIds.add(memorization.id);

      items.add(
        _HomeItem(
          title: memorization.name,
          subtitle: 'حلقة حفظ',
          description: getDescription(memorization),
          location: getLocation(memorization),
          attendance: memorization.attendanceType,
          image: getImage(memorization),
        ),
      );
    }

    final recitation = chooseHalaqa(
      HalaqaFocus.recitation,
      RegistrationStatus.comingSoon,
      usedIds,
      true,
    );

    if (recitation != null) {
      usedIds.add(recitation.id);

      items.add(
        _HomeItem(
          title: recitation.name,
          subtitle: 'حلقة ترتيل',
          description: getDescription(recitation),
          location: getLocation(recitation),
          attendance: recitation.attendanceType,
          image: getImage(recitation),
        ),
      );
    }

    return items;
  }

  @override
  void dispose() {
    registrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationOpen = getRegistrationItems();
    final comingSoon = getComingSoonItems();

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
                if (isLoading)
                  const SizedBox(
                    height: 185,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF24483A),
                      ),
                    ),
                  )
                else if (registrationOpen.length < 4)
                  const SizedBox(
                    height: 185,
                    child: Center(
                      child: Text(
                        'لا توجد بيانات كافية لعرض البرامج',
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 185,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: PageView.builder(
                        controller: registrationController,
                        physics: const PageScrollPhysics(),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          final item = registrationOpen[index];

                          return Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: _RegistrationCard(
                              title: item.title,
                              subtitle: item.subtitle,
                              description: item.description,
                              location: item.location,
                              attendance: item.attendance,
                              image: item.image,
                              imageIsNetwork: item.imageIsNetwork,
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
                if (isLoading)
                  const SizedBox(
                    height: 130,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF24483A),
                      ),
                    ),
                  )
                else if (comingSoon.isEmpty)
                  const SizedBox(
                    height: 130,
                    child: Center(
                      child: Text(
                        'لا توجد برامج قادمة حاليًا',
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else
                  ...comingSoon.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: _ComingSoonCard(
                        title: item.title,
                        subtitle: item.subtitle,
                        description: item.description,
                        location: item.location,
                        attendance: item.attendance,
                        date: 'يبدأ قريبًا',
                        image: item.image,
                        alignment: const Alignment(0, 0),
                        imageIsNetwork: item.imageIsNetwork,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _HomeItem {
  final String title;
  final String subtitle;
  final String description;
  final String location;
  final AttendanceType attendance;
  final String image;
  final bool imageIsNetwork;

  const _HomeItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.attendance,
    required this.image,
    this.imageIsNetwork = false,
  });
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'حسابي',
        'icon': Icons.person_outline_rounded,
      },
      {
        'title': 'الفرص',
        'icon': Icons.auto_awesome_outlined,
      },
      {
        'title': 'تبرع',
        'icon': Icons.volunteer_activism_outlined,
      },
      {
        'title': 'محاضرات',
        'icon': Icons.mic_rounded,
      },
      {
        'title': 'الرئيسية',
        'icon': Icons.home_outlined,
      },
    ];

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: 84,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE7E3D9),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: items.map((item) {
            final isHome = item['title'] == 'الرئيسية';

            return Expanded(
              child: InkWell(
                onTap: () {
                  if (item['title'] == 'حسابي') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountScreen(),
                      ),
                    );
                  }
                },
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 25,
                        color: isHome
                            ? const Color(0xFF24483A)
                            : const Color(0xFF8A8A8A),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['title'] as String,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isHome
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isHome
                              ? const Color(0xFF24483A)
                              : const Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String location;
  final AttendanceType attendance;
  final String image;
  final bool imageIsNetwork;

  const _RegistrationCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.attendance,
    required this.image,
    this.imageIsNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE7E3D9),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            flex: 12,
            child: imageIsNetwork
                ? Image.network(
                    image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE8E4D9),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Color(0xFF24483A),
                            size: 32,
                          ),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE8E4D9),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Color(0xFF24483A),
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Expanded(
            flex: 8,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 6,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF24483A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: Color(0xFF9A7955),
                            ),
                            const SizedBox(width: 2),
                            SizedBox(
                              width: 70,
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF777777),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          attendance == AttendanceType.online
                              ? 'أونلاين'
                              : 'حضوري',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String location;
  final AttendanceType attendance;
  final String date;
  final String image;
  final Alignment alignment;
  final bool imageIsNetwork;

  const _ComingSoonCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.attendance,
    required this.date,
    required this.image,
    required this.alignment,
    this.imageIsNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE7E3D9),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 105,
              height: double.infinity,
              child: imageIsNetwork
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      alignment: alignment,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE8E4D9),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF24483A),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.cover,
                      alignment: alignment,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE8E4D9),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF24483A),
                          ),
                        );
                      },
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF24483A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF777777),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          attendance == AttendanceType.online
                              ? 'أونلاين'
                              : 'حضوري',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF777777),
                          ),
                        ),
                        const Spacer(),
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
                  ],
                ),
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