
import 'package:soundboard/ui/widget/field/search_field.dart';

import '../../../data/library/libray.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(LoadFavoriteSoundsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<FavoritesBloc>().add(LoadFavoriteSoundsEvent(searchQuery: query));
  }

  void _toggleFavorite(int id, bool isFavorite) {
    if (isFavorite) {
      context.read<SoundsBloc>().add(RemoveFavoriteEvent(id));
      context.read<FavoritesBloc>().add(LoadFavoriteSoundsEvent());
      HapticFeedback.lightImpact();
    } else {
      context.read<SoundsBloc>().add(AddFavoriteEvent(id));
      context.read<FavoritesBloc>().add(LoadFavoriteSoundsEvent());
      HapticFeedback.mediumImpact();
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
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state){
        print("state is: $state");
        if (state is SoundsInitial) {
          return const Center(child: CupertinoActivityIndicator());
        } else if(state is FavoritesLoadingState){
          return BlocBuilder<PlayerBloc, SoundPlayerState>(

            builder: (context, playerState){
              int? playingSoundId;
              if (playerState is SoundPlayerPlayingState) {
                playingSoundId = playerState.currentSound.id;
              }
              return SoundsGrid(
                searchField: MySearchField(
                  controller: _searchController,
                  placeholder: "Search from favorites...",
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
              );
            },
          );
        }
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
                      AppColors.accent.withValues(alpha: 0.2),
                      AppColors.accentPink.withValues(alpha: 0.2),
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
      },
    );
  }
}
