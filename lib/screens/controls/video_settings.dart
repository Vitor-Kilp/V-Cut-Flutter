import 'dart:io';

import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:v_cut_flutter/screens/controls/ffmpeg_helpers.dart';
import 'package:v_cut_flutter/screens/controls/progress_popup.dart';
import 'package:v_cut_flutter/screens/controls/run_ffmpeg.dart';
import 'package:v_cut_flutter/utils/debouncer.dart';
import 'package:v_cut_flutter/utils/error_popup.dart';

class VideoSettings extends StatefulWidget {
  final Uri videoFile;
  final VideoController videoController;
  final FfmpegOptionsStream optionsStream;
  const VideoSettings(
      {super.key,
      required this.videoFile,
      required this.videoController,
      required this.optionsStream});

  @override
  State<VideoSettings> createState() => _VideoSettingsState();
}

class _VideoSettingsState extends State<VideoSettings>
    with TickerProviderStateMixin {
  RangeValues _currentRangeValues = const RangeValues(0, 0);
  double videoDuration = 0;
  bool showSlider = false;
  final Debouncer _debouncer = Debouncer(milliseconds: 6);
  ProgressPopup? popup;
  bool previewing = false;

  @override
  initState() {
    super.initState();

    popup = ProgressPopup(context: context);

    widget.videoController.player.stream.duration.listen((duration) {
      if (duration.inSeconds != 0.0) {
        videoDuration = duration.inSeconds.toDouble();
        _currentRangeValues = RangeValues(0, videoDuration);
        setState(() {
          showSlider = true;
        });
      }
    });
  }

  preview() {
    final playerCon = widget.videoController.player;

    playerCon.seek(
        Duration(milliseconds: (_currentRangeValues.start * 1000).floor()));
    playerCon.play();

    playerCon.stream.position.listen((position) {
      if (position.inMilliseconds >= _currentRangeValues.end * 1000) {
        playerCon.pause();
        setState(() {
          previewing = false;
        });
      }
    });
  }

  callbackStats(Statistics stats, {bool? isFirstPass}) {
    final total = isFirstPass != null
        ? videoDuration
        : _currentRangeValues.end - _currentRangeValues.start;
    popup?.updateProgress(stats, total);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        showSlider
            ? RangeSlider(
                values: _currentRangeValues,
                max: videoDuration,
                labels: RangeLabels(
                  _currentRangeValues.start.round().toString(),
                  _currentRangeValues.end.round().toString(),
                ),
                onChanged: (values) {
                  final oldValue = _currentRangeValues.start;

                  setState(() {
                    _currentRangeValues = values;
                  });

                  if (oldValue != values.start) {
                    _debouncer.runAsync(() async {
                      widget.videoController.player.seek(Duration(
                          milliseconds: (values.start.floor() * 1000).round()));
                    });
                  }
                },
                onChangeStart: (RangeValues values) {},
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_currentRangeValues.start.toStringAsFixed(1)} s",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                "${_currentRangeValues.end.toStringAsFixed(1)} s",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                String? outputFile;
                while (outputFile == null) {
                  outputFile = await FilePicker.platform.saveFile(
                    dialogTitle: 'Choose location to save',
                    allowedExtensions: ['mp4'],
                    type: FileType.custom,
                    lockParentWindow: true,
                    fileName: 'video.mp4',
                  );
                }

                final manager = FFMPegRunManager();

                popup?.showPopup(manager.cancelRun);

                onComplete(File? file) {
                  if (file != null) {
                    popup?.showPopup(manager.cancelRun);
                    popup?.finishedProcess(file);
                  } else {
                    popup?.hidePopup();
                    ErrorPopup(context: context);
                  }
                }

                manager.runFfmpegCommand(
                    startTime: _currentRangeValues.start,
                    endTime: _currentRangeValues.end,
                    videoFile: widget.videoFile,
                    options: widget.optionsStream.lastUpdate,
                    outputFile: outputFile,
                    callbackStats: callbackStats,
                    callbackOnComplete: onComplete);
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Cut",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            ToggleButtons(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              isSelected: [previewing],
              constraints: const BoxConstraints(minWidth: 80, minHeight: 35),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Preview",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ],
              onPressed: (_) {
                if (!previewing) {
                  preview();
                } else {
                  widget.videoController.player.pause();
                }

                setState(() {
                  previewing = !previewing;
                });
              },
            ),
            const SizedBox(
              width: 16,
            ),
          ],
        ),
      ],
    );
  }
}
