import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'similar_event.dart';
part 'similar_state.dart';

class SimilarBloc extends Bloc<SimilarEvent, SimilarState> {
  SimilarBloc() : super(SimilarInitial()) {
    on<SimilarEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
