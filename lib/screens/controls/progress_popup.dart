import 'dart:io';

import 'package:ffmpeg_helper/ffmpeg_helper.dart';
import 'package:flutter/material.dart';
import 'package:v_cut_flutter/screens/controls/file_copy_popup.dart';

class ProgressPopup {
  bool showingProgressDialog = false;
  double progress = 0;
  StateSetter? _dialogStateSetter;
  final BuildContext context;
  bool finishedProcessing = false;

  ProgressPopup({
    required this.context,
  });

  updateProgress(Statistics stats, totalTime) {
    _dialogStateSetter?.call(() {
      progress = stats.getTimeDuration().inSeconds / totalTime;
    });
  }

  finishedProcess(File file) {
    _dialogStateSetter?.call(() {
      finishedProcessing = true;
      hidePopup();
      final copyPopup = FileCopyPopup(context: context, filePath: file);
      copyPopup.showPopup();
    });
  }

  hidePopup() {
    if (showingProgressDialog) {
      Navigator.pop(context);
      resetPopup();
    }
  }

  resetPopup() {
    progress = 0;
    showingProgressDialog = false;
    finishedProcessing = false;
  }

  showPopup(void Function() cancelCallback) {
    if (showingProgressDialog) {
      return;
    }

    showingProgressDialog = true;

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
                  children: <Widget>[
                    const Text(
                      "Processing video...",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "${(progress * 100).ceil().toString()} %",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            value: progress,
                            semanticsLabel: 'Processing',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        cancelCallback();
                        resetPopup();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
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
