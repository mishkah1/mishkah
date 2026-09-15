import 'package:flutter/foundation.dart';
import 'package:mishkah/models/dar_model.dart';
import 'package:mishkah/models/halaqa_model.dart';

class SavedItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String location;
  final AttendanceType attendance;
  final String image;
  final bool imageIsNetwork;
  final HalaqaModel halaqa;
  final DarModel? dar;
  final bool showDarName;

  const SavedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.attendance,
    required this.image,
    required this.imageIsNetwork,
    required this.halaqa,
    required this.dar,
    required this.showDarName,
  });
}

class LocalSavedService extends ChangeNotifier {
  LocalSavedService._();

  static final LocalSavedService instance = LocalSavedService._();

  final List<SavedItem> _favorites = [];
  final List<SavedItem> _registrations = [];
  final List<SavedItem> _notifications = [];

  List<SavedItem> get favorites => List.unmodifiable(_favorites);

  List<SavedItem> get registrations => List.unmodifiable(_registrations);

  List<SavedItem> get notifications => List.unmodifiable(_notifications);

  bool isFavorite(String id) {
    return _favorites.any((item) => item.id == id);
  }

  bool isRegistered(String id) {
    return _registrations.any((item) => item.id == id);
  }

  bool isNotificationEnabled(String id) {
    return _notifications.any((item) => item.id == id);
  }

  void toggleFavorite(SavedItem item) {
    final index = _favorites.indexWhere(
      (savedItem) => savedItem.id == item.id,
    );

    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(item);
    }

    notifyListeners();
  }

  void addRegistration(SavedItem item) {
    final alreadyRegistered = _registrations.any(
      (savedItem) => savedItem.id == item.id,
    );

    if (!alreadyRegistered) {
      _registrations.add(item);
      notifyListeners();
    }
  }

  void toggleNotification(SavedItem item) {
    final index = _notifications.indexWhere(
      (savedItem) => savedItem.id == item.id,
    );

    if (index >= 0) {
      _notifications.removeAt(index);
    } else {
      _notifications.add(item);
    }

    notifyListeners();
  }
}