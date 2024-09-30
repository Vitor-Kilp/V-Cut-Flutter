
import 'package:flutter/material.dart';
import 'package:v_cut_flutter/screens/custom_windows_controls/app_bar.dart';
import 'package:v_cut_flutter/screens/custom_windows_controls/windows_controls.dart';
import 'package:v_cut_flutter/screens/player/player_base.dart';

class PlayerHome extends StatefulWidget {
  final Uri videoFileUri;

  const PlayerHome({super.key, required this.videoFileUri});

  @override
  State<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(appBar: AppBar(title: const Text("Cut video"),), topChild: const WindowsControls(),) ,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [PlayerBase(videoFile: widget.videoFileUri)],
        ),
      ),
    );
  }
}
