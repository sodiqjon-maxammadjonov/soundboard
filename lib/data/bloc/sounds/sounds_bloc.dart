import 'package:soundboard/data/library/libray.dart';

part 'sounds_event.dart';
part 'sounds_state.dart';

class SoundsBloc extends Bloc<SoundsEvent, SoundsState> {
  SoundsBloc() : super(SoundsInitial()) {
    on<SoundsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
