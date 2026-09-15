import 'package:flutter/material.dart';

class SaveActions extends StatelessWidget {
  final bool isFavorite;
  final bool isRegistered;
  final bool showBell;
  final VoidCallback onFavorite;
  final VoidCallback onRegister;

  const SaveActions({
    super.key,
    required this.isFavorite,
    required this.isRegistered,
    required this.showBell,
    required this.onFavorite,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBell) {
      return Align(
        alignment: Alignment.topRight,
        child: _ActionButton(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: isFavorite
              ? const Color(0xFFB94A48)
              : Colors.white,
          onTap: onFavorite,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActionButton(
          icon: isRegistered
              ? Icons.notifications_rounded
              : Icons.notifications_none_rounded,
          color: Colors.white,
          onTap: onRegister,
        ),
        _ActionButton(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: isFavorite
              ? const Color(0xFFB94A48)
              : Colors.white,
          onTap: onFavorite,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(
            icon,
            color: color,
            size: 19,
            shadows: const [
              Shadow(
                color: Color(0x99000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}