import 'package:flutter/material.dart';
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
  Future<void> _shareSound() async {
    try {
      // Loading dialog
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(radius: 15),
                const SizedBox(height: 12),
                MyText(
                  content: "Preparing to share...",
                  fontSize: 16,
                  color: AppColors.text,
                ),
              ],
            ),
          ),
        ),
      );

      // Vaqtinchalik faylni yaratish
      final tempDir = await getTemporaryDirectory();
      final fileName = '${widget.sound.name.replaceAll(' ', '_')}.mp3';
      final tempFilePath = '${tempDir.path}/$fileName';
      final tempFile = File(tempFilePath);

      // Asset'dan ma'lumot o'qish va vaqtinchalik faylga yozish
      final data = await rootBundle.load(widget.sound.assetPath);
      await tempFile.writeAsBytes(data.buffer.asUint8List());

      // Loading dialog'ni yopish
      Navigator.of(context).pop();

      // Share qilish
      final result = await Share.shareXFiles(
        [XFile(tempFilePath)],
        text: 'Check out this sound: ${widget.sound.name}',
        subject: 'Meme Sound',
      );

      // Share tugagandan keyin vaqtinchalik faylni o'chirish
      if (result.status == ShareResultStatus.success) {
        HapticFeedback.mediumImpact();
        // Biroz kutib, keyin faylni o'chirish
        Future.delayed(const Duration(seconds: 2), () async {
          try {
            if (await tempFile.exists()) {
              await tempFile.delete();
            }
          } catch (e) {
            print("Temp file delete error: $e");
          }
        });
      } else if (result.status == ShareResultStatus.dismissed) {
        // Agar bekor qilingan bo'lsa, faylni darhol o'chirish
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          print("Temp file delete error: $e");
        }
      }
    } catch (e) {
      print("Share error: $e");

      // Loading dialog'ni yopish
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                CupertinoIcons.xmark_circle_fill,
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: 8),
              Text("Share Failed"),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(e.toString()),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
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
  Future<void> _downloadSound() async {
    try {
      // Loading dialog
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(radius: 15),
                const SizedBox(height: 12),
                MyText(
                  content: "Downloading...",
                  fontSize: 16,
                  color: AppColors.text,
                ),
              ],
            ),
          ),
        ),
      );

      // Permission check - barcha Android versiyalari uchun
      PermissionStatus status = PermissionStatus.denied;

      if (Platform.isAndroid) {
        // Avval audio permission sinab ko'ramiz (Android 13+)
        status = await Permission.audio.request();

        // Agar audio ishlamasa, storage'ni sinab ko'ramiz
        if (status.isDenied) {
          status = await Permission.storage.request();
        }

        // Agar hali ham yo'q bo'lsa, manageExternalStorage'ni sinab ko'ramiz
        if (status.isDenied) {
          status = await Permission.manageExternalStorage.request();
        }
      } else {
        status = PermissionStatus.granted;
      }

      if (status.isGranted || status.isLimited) {
        // Download papkasini topish
        Directory? directory;
        String displayPath = "";

        if (Platform.isAndroid) {
          // Bir nechta yo'lni sinab ko'ramiz
          final possiblePaths = [
            '/storage/emulated/0/Download/MemeSounds',
            '/storage/emulated/0/Downloads/MemeSounds',
            '/sdcard/Download/MemeSounds',
          ];

          for (var path in possiblePaths) {
            final dir = Directory(path);
            try {
              if (!await dir.exists()) {
                await dir.create(recursive: true);
              }
              if (await dir.exists()) {
                directory = dir;
                displayPath = path.contains('Download/')
                    ? "Download/MemeSounds"
                    : "Downloads/MemeSounds";
                break;
              }
            } catch (e) {
              continue;
            }
          }

          // Agar yuqoridagilar ishlamasa, getExternalStorageDirectory'dan foydalanamiz
          if (directory == null) {
            final externalDir = await getExternalStorageDirectory();
            directory = Directory('${externalDir!.path}/MemeSounds');
            displayPath = "Music/MemeSounds";

            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
          displayPath = "Files";
        }

        // Fayl nomi
        final fileName = '${widget.sound.name.replaceAll(' ', '_')}.mp3';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        // Asset'dan ma'lumot o'qish va saqlash
        final data = await rootBundle.load(widget.sound.assetPath);
        await file.writeAsBytes(data.buffer.asUint8List());

        // Loading dialog'ni yopish
        Navigator.of(context).pop();

        // Success dialog
        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  color: widget.color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text("Downloaded!"),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Text(
                    "Saved to:",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$displayPath/\n$fileName",
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  HapticFeedback.lightImpact();
                },
              ),
            ],
          ),
        );

        HapticFeedback.mediumImpact();

      } else if (status.isPermanentlyDenied) {
        // Loading dialog'ni yopish
        Navigator.of(context).pop();

        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Permission Required"),
            content: const Text(
              "Storage permission is required to download sounds. Please enable it in Settings.",
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text("Open Settings"),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          ),
        );
      } else {
        // Loading dialog'ni yopish
        Navigator.of(context).pop();

        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Permission Denied"),
            content: const Text("Storage permission is required to download sounds."),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("Download error: $e");

      // Loading dialog'ni yopish
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                CupertinoIcons.xmark_circle_fill,
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: 8),
              Text("Download Failed"),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(e.toString()),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
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
                                onPressed: () async {
                                  HapticFeedback.lightImpact();
                                  await _shareSound();
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
                                  _downloadSound();
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
