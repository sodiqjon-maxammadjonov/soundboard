import 'package:hive/hive.dart';

class FavoritesBox {
  static const String boxName = "favorites";

  static Future<Box<int>> openBox() async {
    return await Hive.openBox<int>(boxName);
  }

  static Future<void> addFavorite(int id) async {
    final box = await openBox();
    if (!box.values.contains(id)) {
      await box.add(id);
    }
  }

  static Future<void> removeFavorite(int id) async {
    final box = await openBox();
    final key = box.keys.firstWhere(
          (k) => box.get(k) == id,
      orElse: () => null,
    );
    if (key != null) {
      await box.delete(key);
    }
  }

  static Future<Set<int>> getFavorites() async {
    final box = await openBox();
    return box.values.toSet();
  }
}
