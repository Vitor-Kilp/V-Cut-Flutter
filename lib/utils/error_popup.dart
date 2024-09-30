import 'package:flutter/material.dart';

class ErrorPopup {
  final BuildContext context;

  ErrorPopup({required this.context}) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, stateSetter) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Error!"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  ]),
            ),
          );
        },
      ),
    );
  }
}
