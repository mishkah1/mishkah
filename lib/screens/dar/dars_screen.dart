import 'package:flutter/material.dart';
import 'package:mishkah/models/dar_model.dart';
import 'package:mishkah/models/halaqa_model.dart';
import 'package:mishkah/repositories/dar_repository.dart';
import 'package:mishkah/screens/dar/dar_details_screen.dart';
import 'package:mishkah/screens/halaqa/halaqa_details_screen.dart';
import 'package:mishkah/screens/filter/filter_screen.dart';

class DarsScreen extends StatefulWidget {
  final String category;

  const DarsScreen({
    super.key,
    required this.category,
  });

  @override
  State<DarsScreen> createState() => _DarsScreenState();
}

class _DarsScreenState extends State<DarsScreen> {
  static const _darkGreen = Color(0xFF24483A);
  static const _cream = Color(0xFFF7F5EF);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);
  static const _brown = Color(0xFF9A7955);

  final DarRepository repository = DarRepository();
  final TextEditingController searchController = TextEditingController();

  List<DarModel> dars = [];
  List<HalaqaModel> halaqas = [];

  List<DarModel>? filteredDarsFromFilter;
  String? filterName;
  String? filterAddress;

  bool isLoading = true;

  bool get isDarCategory => widget.category == 'الدور';

  HalaqaFocus? get selectedFocus {
    switch (widget.category) {
      case 'التجويد':
        return HalaqaFocus.tajweed;
      case 'الحفظ':
        return HalaqaFocus.memorization;
      case 'الترتيل':
        return HalaqaFocus.recitation;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(applySearch);
    loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      if (isDarCategory) {
        final result = await repository.fetchAllDars();

        if (!mounted) return;

        setState(() {
          dars = result;
          isLoading = false;
        });
      } else {
        final result = await repository.fetchAllHalaqas();

        if (!mounted) return;

        setState(() {
          halaqas = result
              .where(
                (halaqa) => halaqa.focus == selectedFocus,
              )
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void applySearch() {
    setState(() {});
  }

  List<DarModel> get filteredDars {
    final query = searchController.text.trim();

    final baseList = filteredDarsFromFilter ?? dars;

    if (query.isEmpty) {
      return baseList;
    }

    return baseList.where((dar) {
      return dar.name.contains(query) ||
          dar.address.contains(query);
    }).toList();
  }

  List<HalaqaModel> get filteredHalaqas {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      return halaqas;
    }

    return halaqas.where((halaqa) {
      return halaqa.name.contains(query) ||
          halaqa.focus.label.contains(query) ||
          halaqa.category.label.contains(query);
    }).toList();
  }

  String get pageDescription {
    switch (widget.category) {
      case 'الدور':
        return 'اكتشفي الدور والبرامج المتاحة لك';
      case 'التجويد':
        return 'حلقات التجويد المتاحة للتسجيل';
      case 'الحفظ':
        return 'حلقات حفظ القرآن المتاحة للتسجيل';
      case 'الترتيل':
        return 'حلقات الترتيل المتاحة للتسجيل';
      default:
        return 'اكتشفي البرامج المتاحة لك';
    }
  }

  Future<void> openFilter() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          dars: dars,
          initialName: filterName,
          initialAddress: filterAddress,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      filteredDarsFromFilter = result['dars'] as List<DarModel>;
      filterName = result['name'] as String?;
      filterAddress = result['address'] as String?;
    });
  }

  Future<void> openDarDetails(DarModel dar) async {
    try {
      final darHalaqas = await repository.fetchHalaqasForDar(dar.id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DarDetailsScreen(
            dar: dar,
            halaqas: darHalaqas,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر تحميل حلقات الدار',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ),
      );
    }
  }

  DarModel? getDarById(String? darId) {
    if (darId == null || darId.isEmpty) {
      return null;
    }

    for (final dar in dars) {
      if (dar.id == darId) {
        return dar;
      }
    }

    return null;
  }

  void openHalaqaDetails(HalaqaModel halaqa) {
    final dar = getDarById(halaqa.darId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HalaqaDetailsScreen(
          halaqa: halaqa,
          dar: dar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darResults = filteredDars;
    final halaqaResults = filteredHalaqas;
    final resultCount =
        isDarCategory ? darResults.length : halaqaResults.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: _darkGreen,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_forward,
              color: Color(0xFFFFF8EA),
            ),
          ),
          title: Text(
            widget.category,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFFFFF8EA),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: _darkGreen,
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
                children: [
                  Text(
                    widget.category,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: _text,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    pageDescription,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFE4DED2),
                            ),
                          ),
                          child: TextField(
                            controller: searchController,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _text,
                            ),
                            decoration: InputDecoration(
                              hintText: isDarCategory
                                  ? 'ابحثي عن دار أو حي...'
                                  : 'ابحثي عن حلقة...',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: const TextStyle(
                                fontSize: 12,
                                color: _muted,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: _darkGreen,
                                size: 21,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: _darkGreen,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          onPressed: isDarCategory ? openFilter : null,
                          icon: const Icon(
                            Icons.tune_rounded,
                            color: Color(0xFFFFF8EA),
                            size: 21,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        '$resultCount ${isDarCategory ? 'دار' : 'حلقة'}',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _muted,
                        ),
                      ),
                      const Spacer(),
                      if (widget.category != 'الدور')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9EFEA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.category,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _darkGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  if (isDarCategory)
                    _buildDars(darResults)
                  else
                    _buildHalaqas(halaqaResults),
                ],
              ),
      ),
    );
  }

  Widget _buildDars(List<DarModel> items) {
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.mosque_outlined,
        title: 'لا توجد دور مطابقة',
        subtitle: 'جربي البحث باسم آخر أو موقع مختلف',
      );
    }

    return Column(
      children: items.map(
        (dar) {
          return _DarCard(
            dar: dar,
            onTap: () => openDarDetails(dar),
          );
        },
      ).toList(),
    );
  }

  Widget _buildHalaqas(List<HalaqaModel> items) {
    if (items.isEmpty) {
      return const _EmptyState(
        icon: Icons.menu_book_outlined,
        title: 'لا توجد حلقات مطابقة',
        subtitle: 'جربي البحث باسم حلقة أخرى',
      );
    }

    return Column(
      children: items.map(
        (halaqa) {
          return _HalaqaCard(
            halaqa: halaqa,
            dar: getDarById(halaqa.darId),
            onTap: () => openHalaqaDetails(halaqa),
          );
        },
      ).toList(),
    );
  }
}

class _DarCard extends StatelessWidget {
  final DarModel dar;
  final VoidCallback onTap;

  const _DarCard({
    required this.dar,
    required this.onTap,
  });

  static const _darkGreen = Color(0xFF24483A);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);
  static const _brown = Color(0xFF9A7955);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE7E3D9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECE3),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.mosque_outlined,
                  color: _darkGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  dar.name,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _text,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: _brown,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dar.address,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _muted,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 43,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreen,
                foregroundColor: const Color(0xFFFFF8EA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'عرض التفاصيل',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HalaqaCard extends StatelessWidget {
  final HalaqaModel halaqa;
  final DarModel? dar;
  final VoidCallback onTap;

  const _HalaqaCard({
    required this.halaqa,
    required this.dar,
    required this.onTap,
  });

  static const _darkGreen = Color(0xFF24483A);
  static const _text = Color(0xFF25231E);
  static const _muted = Color(0xFF817B70);
  static const _brown = Color(0xFF9A7955);

  @override
  Widget build(BuildContext context) {
    final location = halaqa.attendanceType == AttendanceType.online
        ? 'أونلاين'
        : dar?.address ?? 'حضوري';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE7E3D9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECE3),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: _darkGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  halaqa.name,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _text,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              halaqa.focus.label,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _brown,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: _brown,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _muted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.access_time_rounded,
                size: 15,
                color: _brown,
              ),
              const SizedBox(width: 5),
              Text(
                halaqa.time.label,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 11,
                  color: _muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 43,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreen,
                foregroundColor: const Color(0xFFFFF8EA),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'عرض التفاصيل',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE7E3D9),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: const Color(0xFF9A7955),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF25231E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF817B70),
            ),
          ),
        ],
      ),
    );
  }
}