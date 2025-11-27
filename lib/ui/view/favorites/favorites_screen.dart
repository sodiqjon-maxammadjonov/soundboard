import '../../../data/library/libray.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withOpacity(0.2),
                  AppColors.accentPink.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.heart,
              size: 45,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 20),
          MyText(
            content: 'No Favorites Yet',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          MyText(
            content: 'Sounds you favorite will appear here',
            fontSize: 15,
            color: AppColors.textSecondary,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
