import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'favorites_screen.dart';
import 'my_registrations_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  // ── هوية مِشكاة ──
  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _sand = Color(0xFFC0A06A);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textSecondary = Color(0xFFA8B0AA);

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'حسابي',
          style: GoogleFonts.amiri(
            color: _ivory,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  color: _surfaceRaised,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _border,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/account.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 70,
                        color: _gold,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'أهلاً بك',
                style: GoogleFonts.amiri(
                  color: _ivory,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                email,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                  color: _textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              _AccountOption(
                icon: Icons.assignment_outlined,
                title: 'تسجيلاتي',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyRegistrationsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _AccountOption(
                icon: Icons.favorite_border_rounded,
                title: 'مفضلاتي',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavoritesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AccountOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  static const _surface = AccountScreen._surface;
  static const _surfaceRaised = AccountScreen._surfaceRaised;
  static const _border = AccountScreen._border;
  static const _gold = AccountScreen._gold;
  static const _ivory = AccountScreen._ivory;
  static const _sand = AccountScreen._sand;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: _sand,
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                  color: _ivory,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _surfaceRaised,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: _gold,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}