

import 'package:flutter/material.dart';

@immutable
sealed class GeminiGptEvent {}

class FetchGeminiGpt extends GeminiGptEvent {
  final String prompt;

  FetchGeminiGpt({required this.prompt});
}
