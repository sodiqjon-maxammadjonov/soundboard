import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundboard/ui/widget/field/search_field.dart';
import '../../../data/library/libray.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showTutorial = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    context.read<SoundsBloc>().add(LoadSoundsEvent());
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('has_seen_tutorial') ?? false;

    if (!hasSeenTutorial && mounted) {
      // Biroz kutamiz, ma'lumotlar yuklangan bo'lishi uchun
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _showTutorial = true;
        });
        _showTutorialOverlay();
      }
    }
  }

  void _showTutorialOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => TutorialOverlay(
        onDismiss: () async {
          _overlayEntry?.remove();
          _overlayEntry = null;
          setState(() {
            _showTutorial = false;
          });

          // Tutorial ko'rilganligini saqlash
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_seen_tutorial', true);
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onSearchChanged(String query) {
    context.read<FavoritesBloc>().add(
      LoadFavoriteSoundsEvent(searchQuery: query),
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
    _overlayEntry?.remove();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SoundsBloc, SoundsState>(
      buildWhen: (previous, current) => true,
      builder: (context, state) {
        if (state is SoundsInitial) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state is SoundsLoadingProgressState) {
          return BlocBuilder<PlayerBloc, SoundPlayerState>(
            builder: (context, playerState) {
              int? playingSoundId;
              if (playerState is SoundPlayerPlayingState) {
                playingSoundId = playerState.currentSound.id;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SoundsGrid(
                  searchField: MySearchField(
                    controller: _searchController,
                    placeholder: 'Search sound...',
                    onChanged: _onSearchChanged,
                  ),
                  sounds: state.loadedSounds,
                  favorites: state.favoriteIds,
                  playingSoundId: playingSoundId,
                  onFavoriteToggle: (sound, isFavorite) {
                    _toggleFavorite(sound.id, isFavorite);
                  },
                  onSoundTap: (sound) {
                    _togglePlaySound(sound);
                  },
                ),
              );
            },
          );
        } else if (state is SoundsErrorState) {
          return Center(child: Text(state.message));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

// Tutorial Overlay Widget
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const TutorialOverlay({
    super.key,
    required this.onDismiss,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Material(
          color: Colors.black.withOpacity(0.85 * _fadeAnimation.value),
          child: Stack(
            children: [
              // Tap to dismiss
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onDismiss,
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Tutorial card - ekranning markazida
              Center(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.card,
                            AppColors.cardLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon yoki animatsiya
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accent.withOpacity(0.3),
                                  AppColors.accent.withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.accent.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              CupertinoIcons.hand_point_left_fill,
                              size: 40,
                              color: AppColors.accent,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Title
                          MyText(
                            content: 'Pro Tip! 💡',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),

                          const SizedBox(height: 12),

                          // Description
                          MyText(
                            content:
                            'Hold any sound card to see more options:',
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          // Features list
                          _buildFeatureItem(
                            CupertinoIcons.arrow_down_circle_fill,
                            'Download',
                            'Save sounds to your device',
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            CupertinoIcons.square_arrow_up_fill,
                            'Share',
                            'Share with friends',
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            CupertinoIcons.heart_fill,
                            'Favorite',
                            'Add to your favorites',
                          ),

                          const SizedBox(height: 24),

                          // Got it button
                          GestureDetector(
                            onTap: widget.onDismiss,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accent.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: MyText(
                                content: 'Got it!',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Skip button yuqorida o'ng burchakda
              Positioned(
                top: 60,
                right: 20,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: GestureDetector(
                    onTap: widget.onDismiss,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                      ),
                      child: MyText(
                        content: 'Skip',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withOpacity(0.2),
                AppColors.accent.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.accent,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                content: title,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              MyText(
                content: description,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}