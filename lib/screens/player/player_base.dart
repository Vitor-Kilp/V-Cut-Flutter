import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:v_cut_flutter/screens/controls/ffmpeg_helpers.dart';
import 'package:v_cut_flutter/screens/controls/ffmpeg_settings.dart';
import 'package:v_cut_flutter/screens/controls/video_settings.dart';

class PlayerBase extends StatefulWidget {
  final Uri videoFile;

  const PlayerBase({super.key, required this.videoFile});

  @override
  State<PlayerBase> createState() => _PlayerBaseState();
}

class _PlayerBaseState extends State<PlayerBase> {
  final player = Player();
  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);
  FfmpegOptionsStream optionsStream = FfmpegOptionsStream();
  bool initilizedController = false;

  @override
  initState() {
    super.initState();

    initializeController();
  }

  initializeController() {
    player.open(Media(widget.videoFile.toString()));
  }

  @override
  didUpdateWidget(covariant PlayerBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoFile != widget.videoFile) {
      // Video file changed, so reinitialize the controller
      initializeController();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox(
              width: 400,
              height: windowSize.height - 60,
              child: FfmpegSettings(
                optionsStream: optionsStream,
              )),
        ),
        Column(
          children: [
            ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: windowSize.height - 215,
                    maxWidth: windowSize.width - 400),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Video(
                    controller: controller,
                  ),
                )),
            ConstrainedBox(
                constraints: BoxConstraints(maxWidth: windowSize.width - 400),
                child: VideoSettings(
                    videoFile: widget.videoFile,
                    videoController: controller,
                    optionsStream: optionsStream))
          ],
        ),
      ],
    );
  }
}
