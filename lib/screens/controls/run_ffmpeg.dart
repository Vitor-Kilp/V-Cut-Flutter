import 'dart:io';

import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:v_cut_flutter/main.dart';
import 'package:v_cut_flutter/screens/controls/ffmpeg_helpers.dart';
import 'package:path/path.dart' as path;

class FFMPegRunManager {
  bool cancelled = false;
  FFMpegHelperSession? session;

  cancelRun() {
    cancelled = true;
    session?.cancelSession();
  }

  runFfmpegCommand(
      {required double startTime,
      required double endTime,
      required Uri videoFile,
      required FfmpegOptions options,
      required String outputFile,
      required dynamic Function(Statistics, {bool? isFirstPass}) callbackStats,
      required dynamic Function(File?) callbackOnComplete}) async {
    final ffmpeg = await FFMpegInstance().ensureInitialized();

    var isFirstPass = true;

    final maxSize = options.maxSizeInMB * 1024 * 1024;

    final bitrate = (((maxSize * 8) / (endTime - startTime)) - (128000 * 2)) *
        0.98; // subtract audio bitrate

    final firstPassCmd = CustomArgument([
      '-b:v',
      bitrate.round().toString(),
      '-pass',
      '1',
      '-an',
      '-f',
      'mp4',
      '-passlogfile',
      path.join((await getTemporaryDirectory()).path, 'ffmpeg_v_cut.log'),
    ]);

    final secondPassCmd = CustomArgument([
      '-b:v',
      bitrate.round().toString(),
      '-pass',
      '2',
      '-passlogfile',
      path.join((await getTemporaryDirectory()).path, 'ffmpeg_v_cut.log'),
    ]);

    final gpuNvidiaCommand = CustomArgument([
      "-c:v",
      "h264_nvenc",
      "-preset:v",
      "p5",
      "-rc:v",
      "vbr",
      "-cq:v",
      options.crf.toString(),
      "-profile:v",
      "high"
    ]);

    final gpuAmdCommand = CustomArgument([
      "-c:v",
      "h264_amf",
      "-qp",
      options.crf.toString(),
    ]);

    final cpuCommand = CustomArgument([
      "-c:v",
      "libx264",
      "-crf:v",
      options.crf.toString(),
    ]);

    Future<FFMpegCommand> buildCommand() async {
      final useTwoPassCommand = switch (options.isTwopass) {
        true => switch (isFirstPass) {
            true => firstPassCmd,
            false => secondPassCmd
          },
        false => const CustomArgument([]),
      };

      final useTwoPassDevice = switch (options.encodeUsing) {
        EncodingDevice.gpuNvidia =>
          const CustomArgument(["-c:v", "h264_nvenc"]),
        EncodingDevice.gpuAMD => const CustomArgument(["-c:v", "h264_amf"]),
        EncodingDevice.cpu => const CustomArgument(["-c:v", "libx264"])
      };

      final useEncodingDevice = switch (options.isTwopass) {
        true => useTwoPassDevice,
        false => switch (options.encodeUsing) {
            EncodingDevice.gpuNvidia => gpuNvidiaCommand,
            EncodingDevice.gpuAMD => gpuAmdCommand,
            EncodingDevice.cpu => cpuCommand
          }
      };

      return FFMpegCommand(
        args: [
          const CustomArgument(["-c:a", "aac", "-b:a", "128k"]),
          useTwoPassCommand,
          useEncodingDevice,
          const OverwriteArgument(),
          TrimArgument(
            start: Duration(milliseconds: (startTime * 1000).floor()),
            end: Duration(milliseconds: (endTime * 1000).floor()),
          ),
        ],
        filterGraph: FilterGraph(chains: [
          FilterChain(inputs: [
            const FFMpegStream(videoId: "[0:v]"),
          ], filters: [
            ScaleFilter(height: options.resolution.value, width: -2),
          ], outputs: [])
        ]),
        inputs: [
          FFMpegInput.asset(
              videoFile.toString().substring(8).replaceAll("%20", " "))
        ],
        outputFilepath: outputFile,
      );
    }

    if (cancelled) {
      return;
    }

    if (options.isTwopass) {
      File? filePath;
      session = await ffmpeg.runAsync(await buildCommand(),
          statisticsCallback: (stats) => {
                callbackStats(stats, isFirstPass: true),
              },
          onComplete: (_) async {
            if (cancelled) {
              return;
            }

            isFirstPass = false;

            session = await ffmpeg.runAsync(await buildCommand(),
                statisticsCallback: callbackStats,
                onComplete: (outputFile) => callbackOnComplete(outputFile));
          });

      return filePath;
    } else {
      session = await ffmpeg.runAsync(await buildCommand(),
          statisticsCallback: callbackStats,
          onComplete: (outputFile) => callbackOnComplete(outputFile));
    }
  }
}
