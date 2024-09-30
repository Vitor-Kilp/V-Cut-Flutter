import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stream_mixin/stream_mixin.dart';
import 'package:super_clipboard/src/formats_base.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:v_cut_flutter/screens/player/player_home.dart';

class Counter with StreamMixin<Uri> {
  changeFileUrl(Uri fileUrl) {
    update(fileUrl);
  }
}

class FileDropZone extends StatefulWidget {
  const FileDropZone({super.key});

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  final counter = Counter();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: DropRegion(
        // Formats this region can accept.
        formats: Formats.standardFormats,
        hitTestBehavior: HitTestBehavior.opaque,
        onDropOver: (event) {
          if (event.session.allowedOperations.contains(DropOperation.copy)) {
            return DropOperation.copy;
          } else {
            return DropOperation.none;
          }
        },
        onDropEnter: (event) {
          // This is called when region first accepts a drag. You can use this
          // to display a visual indicator that the drop is allowed.
        },
        onDropLeave: (event) {
          // Called when drag leaves the region. Will also be called after
          // drag completion.
          // This is a good place to remove any visual indicators.
        },
        onPerformDrop: (event) async {
          final item = event.session.items.first;

          final reader = item.dataReader!;

          var formats = reader.getFormats(Formats.standardFormats);

          SimpleFileFormat? getFileFormat(
              {required List<DataFormat<Object>> formats}) {
            final videoFormats = [
              Formats.avi,
              Formats.mp4,
              Formats.m4a,
              Formats.m4v,
              Formats.flv,
              Formats.mkv,
              Formats.mov,
              Formats.webm,
              Formats.wmv
            ];

            for (final videoFormat in videoFormats) {
              if (formats.contains(videoFormat)) {
                return videoFormat;
              }
            }
            return null;
          }

          var videoFileFormat = getFileFormat(formats: formats);

          if (videoFileFormat != null) {
            reader.getValue(Formats.fileUri, (fileUri) {
              if (fileUri != null) {
                counter.changeFileUrl(fileUri);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerHome(
                      videoFileUri: fileUri,
                    ),
                  ),
                );
              }
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(40),
          child: DottedBorder(
              radius: const Radius.circular(20.0),
              borderType: BorderType.RRect,
              color: Colors.white,
              strokeWidth: 1.5,
              dashPattern: const [10, 8],
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Solte seu video aqui:",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    const Text("ou", style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                allowMultiple: false,
                                type: FileType.custom,
                                allowedExtensions: [
                              "avi",
                              "mp4",
                              "m4a",
                              "m4v",
                              "flv",
                              "mkv",
                              "mov",
                              "webm",
                              "wmv"
                            ]);

                        if (result != null) {
                          final fileUri = Uri.file(result.files.single.path!);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerHome(
                                videoFileUri: fileUri,
                              ),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(16.0)), // Add padding here
                      ),
                      label: const Text(
                        "Escolha um video",
                      ),
                      icon: const Icon(
                        textDirection: TextDirection.ltr,
                        Icons.file_copy,
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
