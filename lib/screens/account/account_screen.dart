import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'favorites_screen.dart';
import 'my_registrations_screen.dart';
import 'package:mishkah/screens/menu/about_us_screen.dart';
import 'package:mishkah/screens/menu/contact_us_screen.dart';
import 'package:mishkah/screens/menu/feq_screen.dart';
import 'package:mishkah/screens/menu/settings_screen.dart';
import 'package:mishkah/screens/account/dar_submission_screen.dart';
import 'package:mishkah/screens/account/halaqa_submission_screen.dart';
import 'package:mishkah/screens/account/my_submissions_screen.dart';
import 'package:mishkah/screens/account/admin_review_screen.dart';
import 'package:mishkah/repositories/submission_repository.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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

  final _submissionRepo = SubmissionRepository();
  late Future<String> _roleFuture;
  bool _upgrading = false;

  @override
  void initState() {
    super.initState();
    _roleFuture = _submissionRepo.fetchCurrentUserRole();
  }

  Future<void> _requestSubmitterRole() async {
    setState(() => _upgrading = true);
    try {
      await _submissionRepo.becomeSubmitter();
      setState(() {
        _roleFuture = _submissionRepo.fetchCurrentUserRole();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _surfaceRaised,
          content: Text('تم تفعيل حسابك كصاحب دار/حلقة',
              style: GoogleFonts.ibmPlexSansArabic(color: _ivory)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _surfaceRaised,
          content: Text('تعذر التسجيل كصاحب دار/حلقة، حاول مرة أخرى',
              style: GoogleFonts.ibmPlexSansArabic(color: _ivory)),
        ),
      );
    } finally {
      if (mounted) setState(() => _upgrading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['full_name'] as String?;
    final displayName =
        (name != null && name.trim().isNotEmpty) ? name.trim() : 'بك';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              backgroundColor: _surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _gold,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'حسابي',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    color: _ivory,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              centerTitle: true,
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
                  height: MediaQuery.of(context).size.height * 0.22,
                  decoration: BoxDecoration(
                    color: _surfaceRaised,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _border),
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
                  'أهلاً وسهلاً بك',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: _textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  displayName,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    color: _ivory,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),

                _SectionTitle(title: 'نشاطي'),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
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

                // ── قسم صاحب الدار/الحلقة: يظهر فقط لمن يحتاجه ──
                // مستخدم عادي (باحث عن حلقة): يشوف خيار تفعيل بسيط فقط.
                // صاحب دار/حلقة (submitter) أو إدارة (admin): يشوف قسم
                // "تسجيل بيانات" و"طلباتي" كامل. الإدارة تشوف زيادة
                // "مراجعة الطلبات".
                FutureBuilder<String>(
                  future: _roleFuture,
                  builder: (context, snap) {
                    final role = snap.data;
                    if (role == null) return const SizedBox.shrink();

                    if (role == 'user') {
                      return Column(
                        children: [
                          const SizedBox(height: 26),
                          Container(height: 1, color: _border),
                          const SizedBox(height: 22),
                          _AccountOption(
                            icon: Icons.storefront_outlined,
                            title: _upgrading
                                ? 'جارٍ التسجيل...'
                                : 'أنا صاحب دار أو حلقة',
                            onTap: _upgrading ? () {} : _requestSubmitterRole,
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 26),
                        _SectionTitle(title: 'تسجيل بيانات دار أو حلقة'),
                        const SizedBox(height: 12),
                        _AccountOption(
                          icon: Icons.home_work_outlined,
                          title: 'تسجيل بيانات دار',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DarSubmissionScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _AccountOption(
                          icon: Icons.menu_book_outlined,
                          title: 'تسجيل بيانات حلقة',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HalaqaSubmissionScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _AccountOption(
                          icon: Icons.pending_actions_outlined,
                          title: 'طلباتي',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MySubmissionsScreen(),
                              ),
                            );
                          },
                        ),
                        if (role == 'admin') ...[
                          const SizedBox(height: 12),
                          _AccountOption(
                            icon: Icons.fact_check_outlined,
                            title: 'مراجعة الطلبات',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminReviewScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 26),
                _SectionTitle(title: 'الدعم والمعلومات'),
                const SizedBox(height: 12),
                _AccountOption(
                  icon: Icons.help_outline_rounded,
                  title: 'الأسئلة الشائعة',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FeqScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _AccountOption(
                  icon: Icons.info_outline_rounded,
                  title: 'من نحن',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _AccountOption(
                  icon: Icons.mail_outline_rounded,
                  title: 'تواصل معنا',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 26),
                Container(
                  height: 1,
                  color: _border,
                ),
                const SizedBox(height: 22),
                _AccountOption(
                  icon: Icons.settings_outlined,
                  title: 'الإعدادات',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  static const _gold = Color(0xFFC6A15B);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
          color: _gold,
          fontSize: 13,
          fontWeight: FontWeight.w700,
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

  static const _surface = _AccountScreenState._surface;
  static const _surfaceRaised = _AccountScreenState._surfaceRaised;
  static const _border = _AccountScreenState._border;
  static const _gold = _AccountScreenState._gold;
  static const _ivory = _AccountScreenState._ivory;
  static const _sand = _AccountScreenState._sand;

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
            border: Border.all(color: _border),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
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
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                    color: _ivory,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: _sand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}