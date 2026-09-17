import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkah/services/local_saved_service.dart';

class MyRegistrationsScreen extends StatefulWidget {
  const MyRegistrationsScreen({super.key});

  @override
  State<MyRegistrationsScreen> createState() =>
      _MyRegistrationsScreenState();
}

class _MyRegistrationsScreenState extends State<MyRegistrationsScreen> {
  final LocalSavedService savedService = LocalSavedService.instance;

  // ── هوية مِشكاة ──
  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _gold = Color(0xFFC6A15B);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textSecondary = Color(0xFFA8B0AA);

  @override
  void initState() {
    super.initState();
    savedService.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    savedService.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrations = savedService.registrations;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_forward,
            color: _ivory,
          ),
        ),
        title: Text(
          'تسجيلاتي',
          style: GoogleFonts.amiri(
            color: _ivory,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: registrations.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _surfaceRaised,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        size: 32,
                        color: _gold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد تسجيلات',
                      style: GoogleFonts.amiri(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _ivory,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'عند التسجيل في إحدى الحلقات ستظهر هنا',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: registrations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _RegistrationCard(
                  item: registrations[index],
                );
              },
            ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final SavedItem item;

  const _RegistrationCard({
    required this.item,
  });

  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textSecondary = Color(0xFFA8B0AA);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 125,
            width: double.infinity,
            child: item.imageIsNetwork
                ? Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _imagePlaceholder();
                    },
                  )
                : Image.asset(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _imagePlaceholder();
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _ivory,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                      fontSize: 11,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: _gold,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                            fontSize: 10.5,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(.14),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _gold.withOpacity(.30),
                          ),
                        ),
                        child: Text(
                          'تم التسجيل',
                          style: TextStyle(
                            fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD8BC7A),
                          ),
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
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: _surfaceRaised,
      child: Center(
        child: Icon(
          Icons.menu_book_outlined,
          color: _gold,
          size: 34,
        ),
      ),
    );
  }
}