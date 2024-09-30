import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:v_cut_flutter/screens/home.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Necessary initialization for package:media_kit.
  MediaKit.ensureInitialized();

  doWhenWindowReady(() {
    const initialSize = Size(1200, 700);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });

  runApp(const MyApp());
}

class FFMpegInstance {
  late FFMpegHelper ffmpeg;
  bool _isInitialized = false;

  FFMpegInstance() {
    _initialize();
  }

  Future<void> _initialize() async {
    await FFMpegHelper.instance.initialize();
    ffmpeg = FFMpegHelper.instance;

    if (Platform.isWindows) {
      bool success = await ffmpeg.setupFFMpegOnWindows(
        onProgress: (FFMpegProgress progress) {
          //downloadProgress.value = progress;
        },
      );
    }
    _isInitialized = true;
  }

  Future<FFMpegHelper> ensureInitialized() async {
    if (!_isInitialized) {
      await _initialize();
    }
    return ffmpeg;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "V-Cut",
      initialRoute: "/",
      routes: {"/": (context) => const Home()},
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        scheme: FlexScheme.blue,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.blue,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
    );
  }
}
