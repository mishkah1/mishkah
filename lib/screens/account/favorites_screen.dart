import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkah/services/local_saved_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final LocalSavedService savedService = LocalSavedService.instance;

  @override
  void initState() {
    super.initState();
    savedService.addListener(_onSavedItemsChanged);
  }

  @override
  void dispose() {
    savedService.removeListener(_onSavedItemsChanged);
    super.dispose();
  }

  void _onSavedItemsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = savedService.favorites;

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
      body: favorites.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final item = favorites[index];

                return _FavoriteCard(
                  item: item,
                  onRemove: () {
                    savedService.toggleFavorite(item);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final SavedItem item;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE7E3D9),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 165,
                child: item.imageIsNetwork
                    ? Image.network(
                        item.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return _imagePlaceholder();
                        },
                      )
                    : Image.asset(
                        item.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return _imagePlaceholder();
                        },
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.28),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onRemove,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFB94A48),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF24483A),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF77736B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        item.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF9A7955),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF9A7955),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE9E2D5),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: Color(0xFF24483A),
          size: 42,
        ),
      ),
    );
  }
}