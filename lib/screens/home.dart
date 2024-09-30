import 'package:flutter/material.dart';
import 'package:v_cut_flutter/screens/custom_windows_controls/app_bar.dart';
import 'package:v_cut_flutter/screens/custom_windows_controls/windows_controls.dart';
import 'package:v_cut_flutter/screens/home_dropzone.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        topChild: const WindowsControls(),
        appBar: AppBar(
          title: const Column(
            children: [
              Row(
                children: [
                  Icon(Icons.cut),
                  SizedBox(
                    width: 16,
                  ),
                  Text("V-Cut"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: const FileDropZone(),
    );
  }
}
