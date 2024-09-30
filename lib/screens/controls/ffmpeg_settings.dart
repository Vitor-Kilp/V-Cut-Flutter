import 'package:flutter/material.dart';
import 'package:v_cut_flutter/screens/controls/ffmpeg_helpers.dart';

class FfmpegSettings extends StatefulWidget {
  final FfmpegOptionsStream optionsStream;
  const FfmpegSettings({super.key, required this.optionsStream});

  @override
  State<FfmpegSettings> createState() => _FfmpegSettingsState();
}

class _FfmpegSettingsState extends State<FfmpegSettings> {
  @override
  void initState() {
    super.initState();
    widget.optionsStream.stream.listen((options) {
      setState(() {}); // Update UI when options change
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const Divider(),
          const SizedBox(
            height: 16,
          ),
          Tooltip(
            waitDuration: Duration(milliseconds: 500),
            message:
                "Basically video quality where 0 is lossless, 26 is default, \n and 51 is worst possible. A lower value is a higher quality",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CRF Value: ${!widget.optionsStream.lastUpdate.isTwopass ? widget.optionsStream.lastUpdate.crf : "disabled"}',
                  style: const TextStyle(fontSize: 16),
                ),
                SizedBox(
                  child: Slider(
                    value: (widget.optionsStream.lastUpdate.crf).toDouble(),
                    min: 0,
                    max: 51,
                    divisions: 51,
                    label: '${widget.optionsStream.lastUpdate.crf}',
                    onChanged: !widget.optionsStream.lastUpdate.isTwopass
                        ? (value) {
                            widget.optionsStream.changeCrf(value.toInt());
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              DropdownMenu<EncodingDevice>(
                initialSelection: widget.optionsStream.lastUpdate.encodeUsing,
                label: const Text(
                  'Encoding Device: ',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                ),
                onSelected: (EncodingDevice? newValue) {
                  if (newValue != null) {
                    widget.optionsStream.changeTranscodingDevice(newValue);
                  }
                },
                dropdownMenuEntries: EncodingDevice.values
                    .map<DropdownMenuEntry<EncodingDevice>>(
                        (EncodingDevice value) {
                  return DropdownMenuEntry<EncodingDevice>(
                    value: value,
                    label: value.value,
                  );
                }).toList(),
              ),
              const SizedBox(
                width: 16,
              ),
              DropdownMenu<AcceptedResolutions>(
                initialSelection: widget.optionsStream.lastUpdate.resolution,
                label: const Text(
                  'Resolution: ',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                ),
                onSelected: (AcceptedResolutions? newValue) {
                  if (newValue != null) {
                    widget.optionsStream.changeResolution(newValue);
                  }
                },
                dropdownMenuEntries: AcceptedResolutions.values
                    .map<DropdownMenuEntry<AcceptedResolutions>>(
                        (AcceptedResolutions value) {
                  return DropdownMenuEntry<AcceptedResolutions>(
                    value: value,
                    label: "${value.value}p",
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          const Text("Two pass",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Divider(),
          Row(
            children: [
              Tooltip(
                waitDuration: Duration(milliseconds: 500),
                message:
                    "Slower, two pass method, but keeps the file size close \n to the selected value. Ignores CRF.",
                child: ToggleButtons(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  isSelected: [widget.optionsStream.lastUpdate.isTwopass],
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                      child: Text("Specific file size",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                  onPressed: (_) {
                    final old = widget.optionsStream.lastUpdate.isTwopass;
                    widget.optionsStream.changeTwopass(!old);
                  },
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: 240,
                child: Column(
                  children: [
                    Text(
                      '${widget.optionsStream.lastUpdate.maxSizeInMB} MB',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: (widget.optionsStream.lastUpdate.maxSizeInMB)
                          .toDouble(),
                      min: 6,
                      max: 100,
                      label: '${widget.optionsStream.lastUpdate.maxSizeInMB}',
                      onChanged: widget.optionsStream.lastUpdate.isTwopass
                          ? (value) {
                              widget.optionsStream.changeMaxSize(value.toInt());
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
