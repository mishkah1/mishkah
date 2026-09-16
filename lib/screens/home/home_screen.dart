import 'package:flutter/material.dart';
import 'package:mishkah/models/dar_model.dart';
import 'package:mishkah/models/halaqa_model.dart';
import 'package:mishkah/repositories/dar_repository.dart';
import 'package:mishkah/screens/menu/about_us_screen.dart' as about_us;
import 'package:mishkah/screens/menu/contact_us_screen.dart';
import 'package:mishkah/screens/menu/feq_screen.dart';
import 'package:mishkah/screens/menu/settings_screen.dart';
import 'package:mishkah/services/local_saved_service.dart';
import 'package:mishkah/widgets/save_actions.dart';
import 'package:mishkah/screens/account/account_screen.dart';
import 'package:mishkah/screens/lectures/lectures_screen.dart';
import 'package:mishkah/screens/donation/donation_details_screen.dart';
import 'package:mishkah/screens/dar/dar_details_screen.dart';
import 'package:mishkah/screens/dar/dars_screen.dart';
import 'package:mishkah/screens/halaqa/halaqa_details_screen.dart';
import 'package:mishkah/screens/notifications/notifications_screen.dart';
import 'package:mishkah/screens/opportunities/opportunities_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final PageController registrationController = PageController(
    viewportFraction: 0.82,
  );

  final DarRepository repository = DarRepository();
  final LocalSavedService savedService = LocalSavedService.instance;

  List<DarModel> dars = [];
  List<HalaqaModel> openHalaqas = [];
  List<HalaqaModel> comingSoonHalaqas = [];
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
    savedService.addListener(onSavedItemsChanged);
    loadData();
  }

  void onSavedItemsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        repository.fetchAllDars(),
        repository.fetchOpenHalaqas(),
        repository.fetchComingSoonHalaqas(),
      ]);

      if (!mounted) return;

      setState(() {
        dars = results[0] as List<DarModel>;
        openHalaqas = results[1] as List<HalaqaModel>;
        comingSoonHalaqas = results[2] as List<HalaqaModel>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  /// يرجع مصدر الحلقات المناسب لحالة التسجيل المطلوبة.
  List<HalaqaModel> halaqasByStatus(RegistrationStatus status) {
    if (status == RegistrationStatus.open) {
      return openHalaqas;
    }

    if (status == RegistrationStatus.comingSoon) {
      return comingSoonHalaqas;
    }

    return const [];
  }

  List<HalaqaModel> getHalaqasByFocus(
    HalaqaFocus focus,
    RegistrationStatus status,
  ) {
    return halaqasByStatus(status)
        .where((halaqa) => halaqa.focus == focus)
        .toList();
  }

  List<HalaqaModel> getDarHalaqas(RegistrationStatus status) {
    return halaqasByStatus(status)
        .where(
          (halaqa) =>
              halaqa.darId != null &&
              halaqa.darId!.isNotEmpty &&
              halaqa.attendanceType == AttendanceType.inPerson,
        )
        .toList();
  }

  DarModel? getDarById(String darId) {
    for (final dar in dars) {
      if (dar.id == darId) {
        return dar;
      }
    }

    return null;
  }

  HalaqaModel? chooseHalaqa(
    List<HalaqaModel> candidates,
    Set<String> usedIds,
    Set<String> usedDarIds,
    Set<AttendanceType> usedAttendance,
  ) {
    final available = candidates
        .where((halaqa) => !usedIds.contains(halaqa.id))
        .toList();

    if (available.isEmpty) {
      return null;
    }

    HalaqaModel? best;
    int bestScore = -1;

    for (final halaqa in available) {
      int score = 0;

      final darId = halaqa.darId;

      if (darId != null &&
          darId.isNotEmpty &&
          !usedDarIds.contains(darId)) {
        score += 2;
      }

      if (!usedAttendance.contains(halaqa.attendanceType)) {
        score += 1;
      }

      if (best == null || score > bestScore) {
        best = halaqa;
        bestScore = score;
      }
    }

    return best;
  }

  HalaqaModel? choosePreferredHalaqa(
    List<HalaqaModel> candidates,
    Set<String> usedIds,
    Set<String> usedDarIds,
    AttendanceType preferredAttendance,
  ) {
    final available = candidates
        .where(
          (halaqa) =>
              !usedIds.contains(halaqa.id) &&
              halaqa.attendanceType == preferredAttendance,
        )
        .toList();

    if (available.isEmpty) {
      return null;
    }

    for (final halaqa in available) {
      final darId = halaqa.darId;

      if (darId == null ||
          darId.isEmpty ||
          !usedDarIds.contains(darId)) {
        return halaqa;
      }
    }

    return available.first;
  }

  HalaqaModel? chooseComingSoonHalaqa(
    List<HalaqaModel> candidates,
    Set<String> usedIds,
    Set<String> usedDarIds,
    Set<AttendanceType> usedAttendance,
  ) {
    final available = candidates
        .where((halaqa) => !usedIds.contains(halaqa.id))
        .toList();

    if (available.isEmpty) {
      return null;
    }

    for (final halaqa in available) {
      final darId = halaqa.darId;

      if (!usedAttendance.contains(halaqa.attendanceType) &&
          (darId == null ||
              darId.isEmpty ||
              !usedDarIds.contains(darId))) {
        return halaqa;
      }
    }

    for (final halaqa in available) {
      if (!usedAttendance.contains(halaqa.attendanceType)) {
        return halaqa;
      }
    }

    for (final halaqa in available) {
      final darId = halaqa.darId;

      if (darId == null ||
          darId.isEmpty ||
          !usedDarIds.contains(darId)) {
        return halaqa;
      }
    }

    return available.first;
  }

  String getLocation(HalaqaModel halaqa) {
    if (halaqa.attendanceType == AttendanceType.online) {
      return 'أونلاين';
    }

    if (halaqa.darId != null && halaqa.darId!.isNotEmpty) {
      final dar = getDarById(halaqa.darId!);

      if (dar != null) {
        return dar.address;
      }
    }

    return '';
  }

  String getImage(HalaqaModel halaqa) {
    if (halaqa.attendanceType == AttendanceType.online) {
      return 'assets/images/online.png';
    }

    return 'assets/images/in_person.png';
  }

  String getDescription(HalaqaModel halaqa) {
    if (halaqa.darId != null && halaqa.darId!.isNotEmpty) {
      final dar = getDarById(halaqa.darId!);

      if (dar?.description != null &&
          dar!.description!.trim().isNotEmpty) {
        return dar.description!;
      }
    }

    return '${halaqa.focus.label} - ${halaqa.time.label} - ${halaqa.category.label}';
  }

  _HomeItem? createHalaqaItem(
    HalaqaModel halaqa, {
    bool showDarName = false,
  }) {
    DarModel? dar;

    if (halaqa.darId != null && halaqa.darId!.isNotEmpty) {
      dar = getDarById(halaqa.darId!);
    }

    if (showDarName && dar == null) {
      return null;
    }

    return _HomeItem(
      title: showDarName ? dar!.name : halaqa.name,
      subtitle: showDarName ? halaqa.focus.label : halaqa.name,
      description: getDescription(halaqa),
      location: getLocation(halaqa),
      attendance: halaqa.attendanceType,
      image: showDarName &&
              dar!.imageUrl != null &&
              dar.imageUrl!.trim().isNotEmpty
          ? dar.imageUrl!
          : getImage(halaqa),
      imageIsNetwork: showDarName &&
          dar!.imageUrl != null &&
          dar.imageUrl!.trim().isNotEmpty,
      halaqa: halaqa,
      dar: dar,
      showDarName: showDarName,
    );
  }

  SavedItem createSavedItem(_HomeItem item) {
    return SavedItem(
      id: item.halaqa.id,
      title: item.title,
      subtitle: item.subtitle,
      description: item.description,
      location: item.location,
      attendance: item.attendance,
      image: item.image,
      imageIsNetwork: item.imageIsNetwork,
      halaqa: item.halaqa,
      dar: item.dar,
      showDarName: item.showDarName,
    );
  }

  List<_HomeItem> getOpenItems() {
    final items = <_HomeItem>[];
    final usedIds = <String>{};
    final usedDarIds = <String>{};

    final darHalaqa = choosePreferredHalaqa(
      getDarHalaqas(RegistrationStatus.open),
      usedIds,
      usedDarIds,
      AttendanceType.inPerson,
    );

    if (darHalaqa != null) {
      final item = createHalaqaItem(
        darHalaqa,
        showDarName: true,
      );

      if (item != null) {
        items.add(item);
        usedIds.add(darHalaqa.id);

        if (darHalaqa.darId != null &&
            darHalaqa.darId!.isNotEmpty) {
          usedDarIds.add(darHalaqa.darId!);
        }
      }
    }

    final recitationHalaqa = choosePreferredHalaqa(
      getHalaqasByFocus(
        HalaqaFocus.recitation,
        RegistrationStatus.open,
      ),
      usedIds,
      usedDarIds,
      AttendanceType.online,
    );

    if (recitationHalaqa != null) {
      final item = createHalaqaItem(recitationHalaqa);

      if (item != null) {
        items.add(item);
        usedIds.add(recitationHalaqa.id);

        if (recitationHalaqa.darId != null &&
            recitationHalaqa.darId!.isNotEmpty) {
          usedDarIds.add(recitationHalaqa.darId!);
        }
      }
    }

    final tajweedHalaqa = choosePreferredHalaqa(
      getHalaqasByFocus(
        HalaqaFocus.tajweed,
        RegistrationStatus.open,
      ),
      usedIds,
      usedDarIds,
      AttendanceType.inPerson,
    );

    if (tajweedHalaqa != null) {
      final item = createHalaqaItem(tajweedHalaqa);

      if (item != null) {
        items.add(item);
        usedIds.add(tajweedHalaqa.id);

        if (tajweedHalaqa.darId != null &&
            tajweedHalaqa.darId!.isNotEmpty) {
          usedDarIds.add(tajweedHalaqa.darId!);
        }
      }
    }

    final memorizationHalaqa = choosePreferredHalaqa(
      getHalaqasByFocus(
        HalaqaFocus.memorization,
        RegistrationStatus.open,
      ),
      usedIds,
      usedDarIds,
      AttendanceType.online,
    );

    if (memorizationHalaqa != null) {
      final item = createHalaqaItem(memorizationHalaqa);

      if (item != null) {
        items.add(item);
        usedIds.add(memorizationHalaqa.id);

        if (memorizationHalaqa.darId != null &&
            memorizationHalaqa.darId!.isNotEmpty) {
          usedDarIds.add(memorizationHalaqa.darId!);
        }
      }
    }

    // تعبئة أي نقص من بقية الحلقات المفتوحة بقاعدة البيانات.
    if (items.length < 4) {
      final usedAttendance = <AttendanceType>{};

      for (final item in items) {
        usedAttendance.add(item.attendance);
      }

      while (items.length < 4) {
        final fallback = chooseHalaqa(
          halaqasByStatus(RegistrationStatus.open),
          usedIds,
          usedDarIds,
          usedAttendance,
        );

        if (fallback == null) {
          break;
        }

        usedIds.add(fallback.id);

        final item = createHalaqaItem(fallback);

        if (item == null) {
          continue;
        }

        items.add(item);
        usedAttendance.add(fallback.attendanceType);

        if (fallback.darId != null && fallback.darId!.isNotEmpty) {
          usedDarIds.add(fallback.darId!);
        }
      }
    }

    return items;
  }

  List<_HomeItem> getComingSoonItems() {
    final items = <_HomeItem>[];
    final usedIds = <String>{};
    final usedDarIds = <String>{};
    final usedAttendance = <AttendanceType>{};

    final darCandidates = getDarHalaqas(
      RegistrationStatus.comingSoon,
    );

    final darHalaqa = chooseComingSoonHalaqa(
      darCandidates,
      usedIds,
      usedDarIds,
      usedAttendance,
    );

    if (darHalaqa != null) {
      final item = createHalaqaItem(
        darHalaqa,
        showDarName: true,
      );

      if (item != null) {
        items.add(item);
        usedIds.add(darHalaqa.id);
        usedAttendance.add(darHalaqa.attendanceType);

        if (darHalaqa.darId != null &&
            darHalaqa.darId!.isNotEmpty) {
          usedDarIds.add(darHalaqa.darId!);
        }
      }
    }

    final focusList = [
      HalaqaFocus.tajweed,
      HalaqaFocus.memorization,
      HalaqaFocus.recitation,
    ];

    for (final focus in focusList) {
      final halaqa = chooseComingSoonHalaqa(
        getHalaqasByFocus(
          focus,
          RegistrationStatus.comingSoon,
        ),
        usedIds,
        usedDarIds,
        usedAttendance,
      );

      if (halaqa == null) {
        continue;
      }

      final item = createHalaqaItem(halaqa);

      if (item == null) {
        continue;
      }

      items.add(item);
      usedIds.add(halaqa.id);
      usedAttendance.add(halaqa.attendanceType);

      if (halaqa.darId != null &&
          halaqa.darId!.isNotEmpty) {
        usedDarIds.add(halaqa.darId!);
      }

      if (items.length == 4) {
        break;
      }
    }

    // تعبئة أي نقص من بقية حلقات "قريبًا" بقاعدة البيانات.
    while (items.length < 4) {
      final fallback = chooseComingSoonHalaqa(
        halaqasByStatus(RegistrationStatus.comingSoon),
        usedIds,
        usedDarIds,
        usedAttendance,
      );

      if (fallback == null) {
        break;
      }

      usedIds.add(fallback.id);

      final item = createHalaqaItem(fallback);

      if (item == null) {
        continue;
      }

      items.add(item);
      usedAttendance.add(fallback.attendanceType);

      if (fallback.darId != null && fallback.darId!.isNotEmpty) {
        usedDarIds.add(fallback.darId!);
      }
    }

    return items;
  }

  Future<void> openHomeItem(
    BuildContext context,
    _HomeItem item,
  ) async {
    if (item.showDarName && item.dar != null) {
      List<HalaqaModel> darHalaqas;

      try {
        darHalaqas = await repository.fetchHalaqasForDar(item.dar!.id);
      } catch (e) {
        darHalaqas = [
          ...openHalaqas,
          ...comingSoonHalaqas,
        ]
            .where(
              (halaqa) =>
                  halaqa.darId != null &&
                  halaqa.darId == item.dar!.id,
            )
            .toList();
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DarDetailsScreen(
            dar: item.dar!,
            halaqas: darHalaqas,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HalaqaDetailsScreen(
          halaqa: item.halaqa,
          dar: item.dar,
        ),
      ),
    );
  }

  @override
  void dispose() {
    savedService.removeListener(onSavedItemsChanged);
    registrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationOpen = getOpenItems();
    final comingSoon = getComingSoonItems();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF7F5EF),
      endDrawer: _SideDrawer(
        homeContext: context,
        scaffoldKey: scaffoldKey,
      ),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
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
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DarsScreen(
                                  category: category['title'] as String,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
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
                else if (registrationOpen.isEmpty)
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
                        itemCount: registrationOpen.length,
                        itemBuilder: (context, index) {
                          final item = registrationOpen[index];
                          final savedItem = createSavedItem(item);

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
                              savedItem: savedItem,
                              isFavorite:
                                  savedService.isFavorite(savedItem.id),
                              isNotificationEnabled: savedService
                                  .isNotificationEnabled(savedItem.id),
                              onFavorite: () {
                                savedService.toggleFavorite(savedItem);
                              },
                              onNotification: () {
                                savedService.toggleNotification(savedItem);
                              },
                              onTap: () => openHomeItem(context, item),
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
                    (item) {
                      final savedItem = createSavedItem(item);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: _ComingSoonCard(
                          title: item.title,
                          subtitle: item.subtitle,
                          description: item.description,
                          location: item.location,
                          attendance: item.attendance,
                          date: 'قريبًا',
                          image: item.image,
                          alignment: const Alignment(0, 0),
                          imageIsNetwork: item.imageIsNetwork,
                          isFavorite:
                              savedService.isFavorite(savedItem.id),
                          isNotificationEnabled:
                              savedService.isNotificationEnabled(
                            savedItem.id,
                          ),
                          onFavorite: () {
                            savedService.toggleFavorite(savedItem);
                          },
                          onNotification: () {
                            savedService.toggleNotification(savedItem);
                          },
                          onTap: () => openHomeItem(context, item),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(dars: dars),
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
  final HalaqaModel halaqa;
  final DarModel? dar;
  final bool showDarName;

  const _HomeItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.attendance,
    required this.image,
    required this.halaqa,
    required this.dar,
    required this.showDarName,
    this.imageIsNetwork = false,
  });
}

class _BottomNavBar extends StatelessWidget {
  final List<DarModel> dars;

  const _BottomNavBar({
    required this.dars,
  });

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

                  if (item['title'] == 'الفرص') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OpportunitiesScreen(),
                      ),
                    );
                  }

                  if (item['title'] == 'محاضرات') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LecturesScreen(),
                      ),
                    );
                  }

                  if (item['title'] == 'تبرع') {
                    if (dars.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لم يتم تحميل بيانات الدور بعد'),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DonationScreen(
                          dar: dars.first,
                        ),
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
  final SavedItem savedItem;
  final bool isFavorite;
  final bool isNotificationEnabled;
  final VoidCallback onFavorite;
  final VoidCallback onNotification;
  final VoidCallback onTap;

  const _RegistrationCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.attendance,
    required this.image,
    required this.savedItem,
    required this.isFavorite,
    required this.isNotificationEnabled,
    required this.onFavorite,
    required this.onNotification,
    required this.onTap,
    this.imageIsNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
              child: Stack(
                children: [
                  Positioned.fill(
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
                  Positioned(
                    top: 7,
                    left: 8,
                    right: 8,
                    child: SaveActions(
                      isFavorite: isFavorite,
                      isRegistered: isNotificationEnabled,
                      showBell: true,
                      onFavorite: onFavorite,
                      onRegister: onNotification,
                    ),
                  ),
                ],
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
  final bool isFavorite;
  final bool isNotificationEnabled;
  final VoidCallback onFavorite;
  final VoidCallback onNotification;
  final VoidCallback onTap;

  const _ComingSoonCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.attendance,
    required this.date,
    required this.image,
    required this.alignment,
    required this.isFavorite,
    required this.isNotificationEnabled,
    required this.onFavorite,
    required this.onNotification,
    required this.onTap,
    this.imageIsNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
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
                child: Stack(
                  children: [
                    Positioned.fill(
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
                    Positioned(
                      top: 7,
                      left: 7,
                      right: 7,
                      child: SaveActions(
                        isFavorite: isFavorite,
                        isRegistered: isNotificationEnabled,
                        showBell: true,
                        onFavorite: onFavorite,
                        onRegister: onNotification,
                      ),
                    ),
                  ],
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
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF777777),
                              ),
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
                          const SizedBox(width: 8),
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
  final BuildContext homeContext;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _SideDrawer({
    required this.homeContext,
    required this.scaffoldKey,
  });

  void openMenuPage(
    BuildContext drawerContext,
    Widget page,
  ) {
    Navigator.pop(drawerContext);

    Future.delayed(const Duration(milliseconds: 120), () {
      if (!homeContext.mounted) return;

      Navigator.push(
        homeContext,
        MaterialPageRoute(
          builder: (_) => page,
        ),
      );
    });
  }

  void returnToMenu() {
    Navigator.pop(homeContext);

    Future.delayed(const Duration(milliseconds: 120), () {
      scaffoldKey.currentState?.openEndDrawer();
    });
  }

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
              onTap: () {
                openMenuPage(
                  context,
                  SettingsScreen(
                    onBackToMenu: returnToMenu,
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.help_outline_rounded,
              title: 'الأسئلة الشائعة',
              onTap: () {
                openMenuPage(
                  context,
                  FeqScreen(
                    onBackToMenu: returnToMenu,
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.info_outline_rounded,
              title: 'من نحن',
              onTap: () {
                openMenuPage(
                  context,
                  about_us.AboutUsScreen(
                    onBackToMenu: returnToMenu,
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.mail_outline_rounded,
              title: 'تواصل معنا',
              onTap: () {
                openMenuPage(
                  context,
                  ContactUsScreen(
                    onBackToMenu: returnToMenu,
                  ),
                );
              },
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