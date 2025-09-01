// lib/bloc/gemini_gpt_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:gemini_gpt/bloc/GeminiGptEvent.dart';
import 'package:gemini_gpt/bloc/GeminiGptState.dart';
import 'package:gemini_gpt/repositary/Api/GeminiApi.dart';

class GeminiGptBloc extends Bloc<GeminiGptEvent, GeminiGptState> {
  final GeminiApi api = GeminiApi();

  GeminiGptBloc({required String geminiApi}) : super(GeminiGptInitial()) {
    on<FetchGeminiGpt>((event, emit) async {
      try {
        emit(GeminiGptBlocLoading());
        final gemini = await api.getGemini(event.prompt);
        emit(GeminiGptBlocLoaded(gemini: gemini));
      } catch (e) {
        emit(GeminiGptBlocError(message: e.toString()));
      }
    });
  }
}
