import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:path/path.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:v_cut_flutter/utils/dragable_file.dart';

class FileCopyPopup {
  StateSetter? _dialogStateSetter;
  final BuildContext context;
  File filePath;
  bool copied = false;

  FileCopyPopup({required this.context, required this.filePath});

  resetPopup() {
    copied = false;
  }

  showPopup() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, stateSetter) {
          _dialogStateSetter = stateSetter;
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          "Success!",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onDoubleTap: () {
                            OpenFile.open(filePath.path);
                          },
                          child: DragableFile(
                            name:
                                "${basename(filePath.path)} ${(filePath.statSync().size / 1024 / 1024).toStringAsFixed(1)} MB",
                            dragItemProvider: (DragItemRequest request) async {
                              final item = DragItem();
                              item.add(Formats.fileUri(filePath.uri));
                              return item;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.copy),
                          onPressed: () async {
                            final clipboard = SystemClipboard.instance;
                            if (clipboard != null) {
                              final item = DataWriterItem();
                              item.add(Formats.fileUri(filePath.uri));
                              await clipboard.write([item]);
                              _dialogStateSetter?.call(() {
                                copied = true;
                              });
                            }
                          },
                          label: Text(!copied ? "Copy file" : "Copied!"),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        resetPopup();
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).then((_) {
      resetPopup();
    });
  }
}
