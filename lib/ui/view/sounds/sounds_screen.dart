import '../../../data/library/libray.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  final Set<int> _favorites = {};

  void _toggleFavorite(int index) {
    setState(() {
      if (_favorites.contains(index)) {
        _favorites.remove(index);
        HapticFeedback.lightImpact();
      } else {
        _favorites.add(index);
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _openSoundDetail(int index) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => SoundDetailScreen(
          soundIndex: index,
          soundName: 'Meme Sound ${index + 1}',
          duration: '0:${(index + 5).toString().padLeft(2, '0')}',
          color: AppColors.accent,
          isFavorite: _favorites.contains(index),
          onFavoriteToggle: () => _toggleFavorite(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SoundsGrid(
      itemCount: 100,
      favorites: _favorites,
      onFavoriteToggle: _toggleFavorite,
      onOpenDetail: _openSoundDetail,
    );
  }
}
