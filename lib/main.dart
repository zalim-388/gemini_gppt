// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemini_gpt/Ui/Authentication/Login_screen.dart';
import 'package:gemini_gpt/bloc/GeminiGptBloc.dart';

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
    return BlocProvider<GeminiGptBloc>(
      create: (_) => GeminiGptBloc(geminiApi: apikeyy),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Gemini GPT',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: LoginScreen()
            // HomePage()
            // buildSettingsPage(context),
            ),
      ),
    );
  }
}
