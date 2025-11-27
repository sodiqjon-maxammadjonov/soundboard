import 'package:soundboard/ui/widget/field/search_field.dart';

import '../../../data/library/libray.dart';

class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key});

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SoundsBloc>().add(LoadSoundsEvent());
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

              return SoundsGrid(
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
