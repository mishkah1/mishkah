import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF24483A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFFFF8EA),
            size: 20,
          ),
        ),
        title: Text(
          'مفضلاتي',
          style: GoogleFonts.cairo(
            color: const Color(0xFFFFF8EA),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E2D5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Color(0xFF24483A),
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'لا توجد مفضلات بعد',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF24483A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'أضف البرامج التي تهمك إلى مفضلاتك لتجدها هنا',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF77736B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}