import 'package:flutter/material.dart';

import 'package:gemini_gpt/repositary/model/geminimodel.dart';

@immutable
sealed class GeminiGptState {}

class GeminiGptInitial extends GeminiGptState {}

class GeminiGptBlocLoading extends GeminiGptState {}

class GeminiGptBlocLoaded extends GeminiGptState {
  final Model gemini;
  GeminiGptBlocLoaded({required this.gemini});
}

class GeminiGptBlocError extends GeminiGptState {
  final String message;
  GeminiGptBlocError({required this.message});
}
