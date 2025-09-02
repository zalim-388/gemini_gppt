// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Authentication/Login_screen.dart';
import 'package:gemini_gpt/bloc/GeminiGptBloc.dart';

import 'package:gemini_gpt/widgets/theme_mode.dart';
import 'package:provider/provider.dart';

const String apikeyy = "AIzaSyCHztN3IPc9Y_8lEsv7v_UiIG1Ich7cbGE";

void main() async {
  Gemini.init(apiKey: apikeyy, enableDebugging: true);
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider<GeminiGptBloc>(
          create: (_) => GeminiGptBloc(geminiApi: apikeyy),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            builder:
                (context, child) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Gemini GPT',
                  themeMode: themeProvider.themeMode,
                  theme: ThemeData(
                    useMaterial3: true,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.blue,
                      brightness: Brightness.light,
                    ),
                    scaffoldBackgroundColor: Colors.white,
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.blue,
                      brightness: Brightness.dark,
                    ),
                    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                  home: LoginScreen(),
                ),
          );
        },
      ),
    );
  }
}
