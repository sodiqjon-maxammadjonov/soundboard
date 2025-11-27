
import '../../../data/library/libray.dart';

class SoundDetailScreen extends StatefulWidget {
  final int soundIndex;
  final String soundName;
  final String duration;
  final Color color;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const SoundDetailScreen({
    super.key,
    required this.soundIndex,
    required this.soundName,
    required this.duration,
    required this.color,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<SoundDetailScreen> createState() => _SoundDetailScreenState();
}

class _SoundDetailScreenState extends State<SoundDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          // Main container
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.card, AppColors.cardLight],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.background.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.back,
                              color: AppColors.accent,
                              size: 24,
                            ),
                          ),
                        ),
                        const Spacer(),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              widget.onFavoriteToggle();
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.isFavorite
                                    ? widget.color.withOpacity(0.2)
                                    : AppColors.background.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.isFavorite
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                color: widget.isFavorite
                                    ? widget.color
                                    : AppColors.textSecondary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Center content
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        // Katta icon
                        Hero(
                          tag: 'sound_icon_${widget.soundIndex}',
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.color.withOpacity(0.3),
                                  widget.color.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: widget.color.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              CupertinoIcons.waveform,
                              color: widget.color,
                              size: 100,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Title
                        MyText(
                          content: widget.soundName,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: MyText(
                            content: 'Davomiyligi: ${widget.duration}',
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (widget.isFavorite) ...[
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.color.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.heart_fill,
                                    color: widget.color,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  MyText(
                                    content: 'Sevimlilar',
                                    fontSize: 14,
                                    color: widget.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Play button
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              color: widget.color,
                              borderRadius: BorderRadius.circular(16),
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                // Ovoz o'ynatish
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.play_fill, size: 24),
                                  SizedBox(width: 12),
                                  Text(
                                    'O\'ynatish',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(14),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    // Ulashish
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.share,
                                        color: widget.color,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      MyText(
                                        content: 'Ulashish',
                                        fontSize: 16,
                                        color: widget.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(14),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    // Yuklab olish
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.arrow_down_circle,
                                        color: widget.color,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      MyText(
                                        content: 'Yuklab olish',
                                        fontSize: 16,
                                        color: widget.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
