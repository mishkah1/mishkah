import 'package:flutter/material.dart';
import 'package:mishkah/services/local_saved_service.dart';
import 'package:mishkah/screens/halaqa/halaqa_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
    final notifications = savedService.notifications;

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
        title: const Text(
          'الإشعارات',
          style: TextStyle(
            color: Color(0xFFFFF8EA),
            fontSize: 16,
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
              decoration: const BoxDecoration(
                color: Color(0xFFE8EEE9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 34,
                color: Color(0xFF24483A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد إشعارات',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF24483A),
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'عند تفعيل التنبيه لأي برنامج سيظهر هنا',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF777777),
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE7E3D9),
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF24483A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777777),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_rounded,
                          size: 14,
                          color: Color(0xFF9A7955),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'التنبيه مفعّل',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9A7955),
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
                icon: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF24483A),
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
      color: const Color(0xFFE8E4D9),
      child: const Center(
        child: Icon(
          Icons.menu_book_outlined,
          color: Color(0xFF24483A),
          size: 28,
        ),
      ),
    );
  }
}