import 'package:soundboard/data/bloc/similar/similar_bloc.dart';

import '../library/libray.dart';

class Providers {
  static final List<SingleChildWidget> providers = [
    BlocProvider(create: (context) => SoundsBloc()),
    BlocProvider(create: (context) => PlayerBloc()),
    BlocProvider(create: (context) => FavoritesBloc()),
    BlocProvider(create: (context) => SimilarBloc()),
  ];
}