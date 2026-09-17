import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkah/services/local_saved_service.dart';
import 'package:mishkah/screens/halaqa/halaqa_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final LocalSavedService savedService = LocalSavedService.instance;

  // ── هوية مِشكاة ──
  static const _background = Color(0xFF0D1713);
  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _gold = Color(0xFFC6A15B);
  static const _ivory = Color(0xFFF4EFE3);

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
    final notifications = savedService.notifications;

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
          'الإشعارات',
          style: GoogleFonts.amiri(
            color: _ivory,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? _EmptyNotifications()
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];

                return _NotificationCard(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HalaqaDetailsScreen(
                          halaqa: item.halaqa,
                          dar: item.dar,
                        ),
                      ),
                    );
                  },
                  onRemove: () {
                    savedService.toggleNotification(item);
                  },
                );
              },
            ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _gold = Color(0xFFC6A15B);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textSecondary = Color(0xFFA8B0AA);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _surfaceRaised,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 34,
                color: _gold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد إشعارات',
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _ivory,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'عند تفعيل التنبيه لأي برنامج سيظهر هنا',
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
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final SavedItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  static const _surface = Color(0xFF15221C);
  static const _surfaceRaised = Color(0xFF1B2B24);
  static const _border = Color(0xFF2A3A32);
  static const _gold = Color(0xFFC6A15B);
  static const _goldLight = Color(0xFFD8BC7A);
  static const _ivory = Color(0xFFF4EFE3);
  static const _textSecondary = Color(0xFFA8B0AA);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _border,
          ),
        ),
        padding: const EdgeInsets.all(13),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: SizedBox(
                  width: 82,
                  height: 82,
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
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                        fontSize: 14,
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
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          size: 14,
                          color: _gold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'التنبيه مفعّل',
                          style: TextStyle(
                            fontFamily: GoogleFonts.ibmPlexSansArabic().fontFamily,
                            fontSize: 10,
                            color: _gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.notifications_active_rounded,
                  color: _goldLight,
                  size: 21,
                ),
                tooltip: 'إلغاء التنبيه',
              ),
            ],
          ),
        ),
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
          size: 28,
        ),
      ),
    );
  }
}