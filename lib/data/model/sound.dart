class Sound {
  final int id;
  final String name;
  final String assetPath;
  final Duration? duration;
  final bool isFavorite;
  final List<String> tags; // ✅ YANGI: Bir nechta tag/category

  const Sound({
    required this.id,
    required this.name,
    required this.assetPath,
    this.duration,
    this.isFavorite = false,
    this.tags = const [], // ✅ Default bo'sh list
  });

  Sound copyWith({
    int? id,
    String? name,
    String? assetPath,
    Duration? duration,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return Sound(
      id: id ?? this.id,
      name: name ?? this.name,
      assetPath: assetPath ?? this.assetPath,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags, // ✅ YANGI
    );
  }
}