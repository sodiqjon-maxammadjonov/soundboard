import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:soundboard/data/bloc/similar/similar_bloc.dart';

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
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    context.read<SimilarBloc>().add(LoadSimilarSoundsEvent(currentSound: widget.sound));
    _isFavorite = widget.sound.isFavorite;

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

  @override
  void didUpdateWidget(SoundDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sound.isFavorite != widget.sound.isFavorite) {
      setState(() {
        _isFavorite = widget.sound.isFavorite;
      });
    }
  }

  Future<void> _shareSound() async {
    try {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Center(
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

      final tempDir = await getTemporaryDirectory();
      final fileName = '${widget.sound.name.replaceAll(' ', '_')}.mp3';
      final tempFilePath = '${tempDir.path}/$fileName';
      final tempFile = File(tempFilePath);

      final data = await rootBundle.load(widget.sound.assetPath);
      await tempFile.writeAsBytes(data.buffer.asUint8List());

      Navigator.of(context).pop();

      final result = await Share.shareXFiles(
        [XFile(tempFilePath)],
        text: 'Check out this sound: ${widget.sound.name}',
        subject: 'Meme Sound',
      );

      if (result.status == ShareResultStatus.success) {
        HapticFeedback.mediumImpact();
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

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      await showCupertinoDialog(
        context: context,
        builder: (context) =>
            CupertinoAlertDialog(
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
  Future<void> _downloadSound() async {
    try {
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

      // Permission tekshirish
      PermissionStatus status = PermissionStatus.denied;

      if (Platform.isAndroid) {
        if (await _getAndroidVersion() >= 33) {
          status = await Permission.audio.request();
        } else if (await _getAndroidVersion() >= 30) {
          status = await Permission.manageExternalStorage.request();
        } else {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos.request();
      }

      if (!status.isGranted && !status.isLimited) {
        Navigator.of(context).pop();
        await _showPermissionDialog(status.isPermanentlyDenied);
        return;
      }

      // Papka va fayl nomini tayyorlash
      final result = await _prepareFileLocation();
      if (result == null) {
        throw Exception("No folder found to save to");
      }

      final directory = result['directory'] as Directory;
      final displayPath = result['displayPath'] as String;

      // Noyob fayl nomini yaratish
      final baseFileName = _sanitizeFileName(widget.sound.name);
      final uniqueFile = await _getUniqueFile(directory, baseFileName);

      final fileName = path.basename(uniqueFile.path);

      // Faylni saqlash
      final data = await rootBundle.load(widget.sound.assetPath);
      await uniqueFile.writeAsBytes(data.buffer.asUint8List());

      // Android media scanner
      if (Platform.isAndroid) {
        await _scanMediaFile(uniqueFile.path);
      }

      Navigator.of(context).pop();

      // Muvaffaqiyatli dialog
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
              const Text("Saved!"),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                Text(
                  "File path:",
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
    } catch (e) {
      print("Yuklab olishda xato: $e");

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
              Text("Error!"),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "File could not be downloaded.\n${e.toString()}",
              style: const TextStyle(fontSize: 14),
            ),
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

// Fayl nomini tozalash (maxsus belgilarni olib tashlash)
  String _sanitizeFileName(String name) {
    // Faqat harflar, raqamlar, probel, tire va pastki chiziqni qoldirish
    String sanitized = name.replaceAll(RegExp(r'[^\w\s-]'), '');
    // Bir nechta probelni bitta probelga almashtirish
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    // Probel o'rniga pastki chiziq qo'yish
    sanitized = sanitized.replaceAll(' ', '_');
    // Maksimal 50 belgi
    if (sanitized.length > 50) {
      sanitized = sanitized.substring(0, 50);
    }
    return sanitized;
  }

// Noyob fayl nomini topish
  Future<File> _getUniqueFile(Directory directory, String baseName) async {
    String fileName = '$baseName.mp3';
    File file = File('${directory.path}/$fileName');
    int counter = 1;

    // Agar fayl mavjud bo'lsa, raqam qo'shib yangi nom yaratish
    while (await file.exists()) {
      fileName = '${baseName}_$counter.mp3';
      file = File('${directory.path}/$fileName');
      counter++;
    }

    return file;
  }

// Papka manzilini tayyorlash
  Future<Map<String, dynamic>?> _prepareFileLocation() async {
    Directory? directory;
    String displayPath = "";

    if (Platform.isAndroid) {
      // Android 10+ uchun
      final possiblePaths = [
        '/storage/emulated/0/Download/MemeSounds',
        '/storage/emulated/0/Downloads/MemeSounds',
        '/storage/emulated/0/Music/MemeSounds',
      ];

      for (var path in possiblePaths) {
        final dir = Directory(path);
        try {
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          if (await dir.exists()) {
            directory = dir;
            if (path.contains('Music')) {
              displayPath = "Music/MemeSounds";
            } else if (path.contains('Downloads')) {
              displayPath = "Downloads/MemeSounds";
            } else {
              displayPath = "Download/MemeSounds";
            }
            break;
          }
        } catch (e) {
          continue;
        }
      }

      // Agar yuqoridagi papkalar ishlamasa
      if (directory == null) {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          directory = Directory('${externalDir.path}/MemeSounds');
          displayPath = "Internal Storage/MemeSounds";
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        }
      }
    } else {
      // iOS uchun
      directory = await getApplicationDocumentsDirectory();
      displayPath = "Files/MemeSounds";
      final finalDir = Directory('${directory.path}/MemeSounds');
      if (!await finalDir.exists()) {
        await finalDir.create(recursive: true);
      }
      directory = finalDir;
    }

    if (directory == null) return null;

    return {
      'directory': directory,
      'displayPath': displayPath,
    };
  }

// Android versiyasini olish
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

// Media faylni skanerlash (Androidda galereya va boshqa ilovalarda ko'rinishi uchun)
  Future<void> _scanMediaFile(String filePath) async {
    if (Platform.isAndroid) {
      try {
        const platform = MethodChannel('media_scanner');
        await platform.invokeMethod('scanFile', {'path': filePath});
      } catch (e) {
        print("Media scanner xatosi: $e");
      }
    }
  }

// Permission dialog
  Future<void> _showPermissionDialog(bool isPermanentlyDenied) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Ruxsat kerak"),
        content: Text(
          isPermanentlyDenied
              ? "Permission is required to save files. Please enable it in Settings."
              : "Allow files in memory to save files.",
        ),
        actions: [
          if (!isPermanentlyDenied)
            CupertinoDialogAction(
              child: const Text("Bekor qilish"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(isPermanentlyDenied ? "Settings" : "OK"),
            onPressed: () {
              Navigator.of(context).pop();
              if (isPermanentlyDenied) {
                openAppSettings();
              }
            },
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(int id, bool isFavorite) {
    if (isFavorite) {
      context.read<SoundsBloc>().add(RemoveFavoriteEvent(id));
      context.read<FavoritesBloc>().add(LoadFavoriteSoundsEvent());

    } else {
      context.read<SoundsBloc>().add(AddFavoriteEvent(id));
      context.read<FavoritesBloc>().add(LoadFavoriteSoundsEvent());
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
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? d) {
    if (d == null) return "Unknown";
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
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
                              color: AppColors.background.withValues(
                                  alpha: 0.5),
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
                              HapticFeedback.lightImpact();
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                              widget.onFavoriteToggle();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isFavorite
                                    ? widget.color.withValues(alpha: 0.2)
                                    : AppColors.background.withValues(
                                    alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isFavorite
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                color: _isFavorite
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

                  const SizedBox(height: 60),

                  // Sound icon va details
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
                                  isPlaying: context
                                      .watch<PlayerBloc>()
                                      .state
                                  is SoundPlayerPlayingState &&
                                      (context
                                          .watch<PlayerBloc>()
                                          .state
                                      as SoundPlayerPlayingState)
                                          .currentSound
                                          .id ==
                                          widget.sound.id,
                                  size: 100,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: MyText(
                            content: widget.sound.name,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),

                        const SizedBox(height: 12),

                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: MyText(
                            content: "Duration: $durationText",
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        if (_isFavorite) ...[
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: widget.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.color.withValues(alpha: 0.3),
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

                  const SizedBox(height: 40),

                  // Play va Download buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
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
                                        final state =
                                            context
                                                .watch<PlayerBloc>()
                                                .state;
                                        final isPlayingCurrentSound = state
                                        is SoundPlayerPlayingState &&
                                            state.currentSound.id ==
                                                widget.sound.id;

                                        return Icon(
                                          isPlayingCurrentSound
                                              ? CupertinoIcons.stop_fill
                                              : CupertinoIcons.play_fill,
                                          key: ValueKey(
                                            isPlayingCurrentSound
                                                ? 'stop'
                                                : 'play',
                                          ),
                                          size: 24,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Builder(
                                    builder: (_) {
                                      final state =
                                          context
                                              .watch<PlayerBloc>()
                                              .state;
                                      final isPlayingCurrentSound = state
                                      is SoundPlayerPlayingState &&
                                          state.currentSound.id ==
                                              widget.sound.id;

                                      return Text(
                                        isPlayingCurrentSound ? "Stop" : "Play",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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

                              Expanded(
                                child: CupertinoButton(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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

                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.waveform,
                                color: widget.color,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              MyText(
                                content: "Sounds",
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          BlocBuilder<SimilarBloc, SimilarState>(
                            buildWhen: (previous, current) => true,
                            builder: (context, state) {
                              if (state is SimilarInitial) {
                                return const Center(
                                  child: MyText(
                                    content: "No similar Sounds",
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              } else if (state is SimilarSoundsLoadingProgressState) {
                                return BlocBuilder<PlayerBloc, SoundPlayerState>(
                                  builder: (context, playerState) {
                                    int? playingSoundId;
                                    if (playerState is SoundPlayerPlayingState) {
                                      playingSoundId = playerState.currentSound.id;
                                    }

                                    return SoundsGrid(
                                      searchField: const SizedBox.shrink(),
                                      sounds: state.loadedSounds,
                                      favorites: state.favoriteIds,
                                      playingSoundId: playingSoundId,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      onFavoriteToggle: (sound, isFavorite) {
                                        _toggleFavorite(sound.id, isFavorite);
                                      },
                                      onSoundTap: (sound) {
                                        _togglePlaySound(sound);
                                      },
                                    );
                                  },
                                );
                              } else if (state is SimilarSoundsErrorState) {
                                return Center(child: MyText(content: state.message));
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
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