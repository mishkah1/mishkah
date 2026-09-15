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
      backgroundColor: const Color(0xFFF7F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF24483A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_forward,
            color: Color(0xFFFFF8EA),
          ),
        ),
        title: Text(
          'تسجيلاتي',
          style: GoogleFonts.cairo(
            color: const Color(0xFFFFF8EA),
            fontSize: 16,
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8EEE9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        size: 32,
                        color: Color(0xFF24483A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد تسجيلات',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF24483A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'عند التسجيل في إحدى الحلقات ستظهر هنا',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF777777),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE7E3D9),
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
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF24483A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF777777),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Color(0xFF9A7955),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            color: const Color(0xFF777777),
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
                          color: const Color(0xFFE8EEE9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'تم التسجيل',
                          style: GoogleFonts.cairo(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF24483A),
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
      color: const Color(0xFFE8E4D9),
      child: const Center(
        child: Icon(
          Icons.menu_book_outlined,
          color: Color(0xFF24483A),
          size: 34,
        ),
      ),
    );
  }
}