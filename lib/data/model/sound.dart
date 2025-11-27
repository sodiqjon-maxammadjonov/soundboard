class Sound {
  final int id;
  final String name;
  final String assetPath;
  final Duration? duration;
  final bool isFavorite;

  const Sound({
    required this.id,
    required this.name,
    required this.assetPath,
    this.duration,
    this.isFavorite = false,
  });

  Sound copyWith({bool? isFavorite}) {
    return Sound(
      id: id,
      name: name,
      assetPath: assetPath,
      duration: duration,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
