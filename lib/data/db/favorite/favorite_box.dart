import 'package:hive/hive.dart';

class FavoritesBox {
  static const String boxName = "favorites";
  static const String timestampsBoxName = "favorites_timestamps";

  static Future<Box<int>> openBox() async {
    return await Hive.openBox<int>(boxName);
  }

  static Future<Box<int>> openTimestampsBox() async {
    return await Hive.openBox<int>(timestampsBoxName);
  }

  static Future<void> addFavorite(int id) async {
    final box = await openBox();
    final timestampsBox = await openTimestampsBox();

    if (!box.values.contains(id)) {
      await box.add(id);
      // Hozirgi vaqtni milliseconds da saqlaymiz
      await timestampsBox.put(id, DateTime.now().millisecondsSinceEpoch);
    }
  }

  static Future<void> removeFavorite(int id) async {
    final box = await openBox();
    final timestampsBox = await openTimestampsBox();

    final key = box.keys.firstWhere(
          (k) => box.get(k) == id,
      orElse: () => null,
    );
    if (key != null) {
      await box.delete(key);
      await timestampsBox.delete(id);
    }
  }

  static Future<List<int>> getFavorites() async {
    final box = await openBox();
    final timestampsBox = await openTimestampsBox();

    // Barcha favorite IDlarni olamiz
    final favoriteIds = box.values.toList();

    // Timestamp bo'yicha tartiblash (eng yangi birinchi)
    favoriteIds.sort((a, b) {
      final timeA = timestampsBox.get(a, defaultValue: 0)!;
      final timeB = timestampsBox.get(b, defaultValue: 0)!;
      return timeB.compareTo(timeA); // Kamayuvchi tartib
    });

    return favoriteIds;
  }

  // Set qaytaruvchi eski versiya (agar kerak bo'lsa)
  static Future<Set<int>> getFavoritesSet() async {
    final list = await getFavorites();
    return list.toSet();
  }
}