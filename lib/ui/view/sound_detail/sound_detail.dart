import 'package:share_plus/share_plus.dart';

import '../../../data/library/libray.dart';

class SoundDetailScreen extends StatefulWidget {
  final Sound sound;
  final Color color;
  final VoidCallback onFavoriteToggle;

  const SoundDetailScreen({
    super.key,
    required this.sound,
    required this.color,
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

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  void _togglePlaySound(Sound sound) {
    HapticFeedback.mediumImpact();
    final playerState = context.read<PlayerBloc>().state;

    if (playerState is SoundPlayerPlayingState &&
        playerState.currentSound.id == sound.id) {
      context.read<PlayerBloc>().add(StopSoundEvent());
    } else {
      context.read<PlayerBloc>().add(PlaySoundEvent(sound));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? d) {
    if (d == null) return "Noma'lum";
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final durationText = _formatDuration(widget.sound.duration);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.card, AppColors.cardLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            color: AppColors.background.withValues(alpha: 0.5),
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
                            setState(() {
                              widget.onFavoriteToggle();
                              HapticFeedback.lightImpact();});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.sound.isFavorite
                                  ? widget.color.withValues(alpha: 0.2)
                                  : AppColors.background.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.sound.isFavorite
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              color: widget.sound.isFavorite
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

                // CENTER CONTENT
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      Hero(
                        tag: "sound_icon_${widget.sound.id}",
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _togglePlaySound(widget.sound);
                          },
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.color.withValues(alpha: 0.3),
                                  widget.color.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: widget.color.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _AnimatedWaveformIcon(
                                color: widget.color,
                                isPlaying: context.watch<PlayerBloc>().state is SoundPlayerPlayingState &&
                                    (context.watch<PlayerBloc>().state as SoundPlayerPlayingState)
                                        .currentSound.id == widget.sound.id,
                                size: 100,
                              ),
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(height: 40),

                      // Sound Name
                      MyText(
                        content: widget.sound.name,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),

                      const SizedBox(height: 12),

                      // Duration
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: MyText(
                          content: "Duration: $durationText",
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      if (widget.sound.isFavorite) ...[
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: widget.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: widget.color.withValues(alpha: 0.3)),
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
                                  content: "Favorited",
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

                // BOTTOM BUTTONS
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // PLAY button
                        // PLAY button va AnimatedSwitcher
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            color: widget.color,
                            borderRadius: BorderRadius.circular(16),
                            onPressed: () => _togglePlaySound(widget.sound),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Builder(
                                    builder: (_) {
                                      final state = context.watch<PlayerBloc>().state;
                                      final isPlayingCurrentSound =
                                          state is SoundPlayerPlayingState &&
                                              state.currentSound.id == widget.sound.id;

                                      return Icon(
                                        isPlayingCurrentSound
                                            ? CupertinoIcons.stop_fill
                                            : CupertinoIcons.play_fill,
                                        key: ValueKey(isPlayingCurrentSound ? 'stop' : 'play'),
                                        size: 24,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Builder(
                                  builder: (_) {
                                    final state = context.watch<PlayerBloc>().state;
                                    final isPlayingCurrentSound =
                                        state is SoundPlayerPlayingState &&
                                            state.currentSound.id == widget.sound.id;

                                    return Text(
                                      isPlayingCurrentSound ? "Stop" : "Play",
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),


                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(14),
                                onPressed: () {
                                  final soundFilePath = widget.sound.assetPath;
                                final soundName = widget.sound.name;

                                  HapticFeedback.lightImpact();
                                  Share.share(
                                      "Sound: $soundName \nYuklab olish linki: $soundFilePath",
                                      subject: "Funny!"
                                  );
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
                                      content: "Send",
                                      fontSize: 16,
                                      color: widget.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Download
                            Expanded(
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(14),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  // TODO: download event
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
                                      content: "Download",
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedWaveformIcon extends StatefulWidget {
  final Color color;
  final bool isPlaying;
  final double size;

  const _AnimatedWaveformIcon({
    required this.color,
    required this.isPlaying,
    this.size = 30,
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
          size: Size(widget.size, widget.size),
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
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = 5.5;
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

      canvas.drawLine(Offset(x, topY), Offset(x, bottomY), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => true;
}
