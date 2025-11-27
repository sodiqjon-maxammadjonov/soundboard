import '../../../data/library/libray.dart';

class SoundsGrid extends StatelessWidget {
  final int itemCount;
  final Set<int> favorites;
  final void Function(int) onFavoriteToggle;
  final void Function(int) onOpenDetail;

  const SoundsGrid({
    super.key,
    required this.itemCount,
    required this.favorites,
    required this.onFavoriteToggle,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final color = _getAccentColor(index);
        final isFavorite = favorites.contains(index);

        return GestureDetector(
          onTap: () => onOpenDetail(index),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.card, AppColors.cardLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon box
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.3),
                              color.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.waveform,
                          color: color,
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 12),

                      MyText(
                        content: 'Meme Sound ${index + 1}',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        maxLines: 1,
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.time,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          MyText(
                            content:
                            '0:${(index + 5).toString().padLeft(2, '0')}',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Favorite icon button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => onFavoriteToggle(index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isFavorite
                            ? color.withOpacity(0.2)
                            : AppColors.card.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFavorite
                              ? color.withOpacity(0.5)
                              : AppColors.textSecondary.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isFavorite
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: isFavorite ? color : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getAccentColor(int index) {
    final colors = [
      AppColors.accent,
      AppColors.accentPurple,
      AppColors.accentPink,
      AppColors.accentOrange,
      AppColors.accentGreen,
      AppColors.accentYellow,
    ];
    return colors[index % colors.length];
  }
}
