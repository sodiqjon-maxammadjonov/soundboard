import '../../../data/library/libray.dart';

class SoundsGrid extends StatelessWidget {
  final List<Sound> sounds;
  final Set<int> favorites;
  final int? playingSoundId;
  final void Function(Sound) onSoundTap;
  final void Function(Sound, bool) onFavoriteToggle;
  final Widget searchField;

  const SoundsGrid({
    super.key,
    required this.sounds,
    required this.favorites,
    this.playingSoundId,
    required this.onSoundTap,
    required this.onFavoriteToggle,
    required this.searchField,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [

        SliverToBoxAdapter(
          child: searchField,
        ),

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final sound = sounds[index];
                final color = _getAccentColor(index);
                final isFavorite = favorites.contains(sound.id);
                final isPlaying = playingSoundId == sound.id;

                return _SoundCard(
                  sound: sound,
                  color: color,
                  isFavorite: isFavorite,
                  isPlaying: isPlaying,
                  onTap: () => onSoundTap(sound),
                  onFavoriteToggle: () => onFavoriteToggle(sound, isFavorite),
                );
              },
              childCount: sounds.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.2,
            ),
          ),
        ),
      ],
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

class _SoundCard extends StatelessWidget {
  final Sound sound;
  final Color color;
  final bool isFavorite;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _SoundCard({
    required this.sound,
    required this.color,
    required this.isFavorite,
    required this.isPlaying,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Navigator.push(context, CupertinoPageRoute(builder: (context) =>
            SoundDetailScreen(sound: sound,
                color: color,
                onFavoriteToggle: onFavoriteToggle)
        )
        );
      },
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.card, AppColors.cardLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: isPlaying
              ? Border.all(
            color: color.withValues(alpha: 0.6),
            width: 2,
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: isPlaying
                  ? color.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.15),
              blurRadius: isPlaying ? 20 : 15,
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
                  Container(
                    width: double.infinity,
                    height: 57,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: _AnimatedWaveformIcon(
                      color: color,
                      isPlaying: isPlaying,
                    ),
                  ),
                  const SizedBox(height: 12),
                  MyText(
                    content: sound.name,
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
                        content: sound.duration != null
                            ? '${sound.duration!.inMinutes}:${(sound.duration!
                            .inSeconds % 60).toString().padLeft(2, '0')}'
                            : '0:00',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onFavoriteToggle,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isFavorite
                        ? color.withValues(alpha: 0.2)
                        : AppColors.card.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFavorite
                          ? color.withValues(alpha: 0.5)
                          : AppColors.textSecondary.withValues(alpha: 0.2),
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
  }
}

class _AnimatedWaveformIcon extends StatefulWidget {
  final Color color;
  final bool isPlaying;

  const _AnimatedWaveformIcon({
    required this.color,
    required this.isPlaying,
  });

  @override
  State<_AnimatedWaveformIcon> createState() => _AnimatedWaveformIconState();
}

class _AnimatedWaveformIconState extends State<_AnimatedWaveformIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AnimatedWaveformIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(30, 30),
          painter: _WaveformPainter(
            color: widget.color,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _WaveformPainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = 2.5;
    final spacing = 3.5;
    final barCount = 7;
    final totalWidth = (barCount * barWidth) + ((barCount - 1) * spacing);
    final startX = (size.width - totalWidth) / 2;

    final baseHeights = [0.06, 0.4, 0.3, 0.5, 0.3, 0.6, 0.2];

    final heights = List.generate(barCount, (i) {
      final base = baseHeights[i];
      if (animationValue == 0) {
        return base;
      } else {
        return base + (animationValue * 0.2 * (1 - base));
      }
    });

    for (int i = 0; i < barCount; i++) {
      final x = startX + (i * (barWidth + spacing));
      final barHeight = size.height * heights[i];
      final topY = centerY - (barHeight / 2);
      final bottomY = centerY + (barHeight / 2);

      canvas.drawLine(
        Offset(x, topY),
        Offset(x, bottomY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => true;
}