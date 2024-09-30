import 'dart:async';

import 'package:stream_mixin/stream_mixin.dart';

enum EncodingDevice {
  gpuNvidia("Nvidia GPU"),
  gpuAMD("AMD GPU"),
  cpu("CPU");

  const EncodingDevice(this.value);
  final String value;
}

enum AcceptedResolutions {
  p2160(2160),
  p1080(1080),
  p720(720),
  p480(480),
  p360(360),
  p240(240);

  const AcceptedResolutions(this.value);
  final int value;
}

class FfmpegOptions {
  int crf = 26;
  EncodingDevice encodeUsing = EncodingDevice.cpu;
  AcceptedResolutions resolution = AcceptedResolutions.p1080;
  bool isTwopass = false;
  int maxSizeInMB = 23;
  double startTime = 0;
  double endTime = 1;
}

class FfmpegOptionsStream with StreamMixin<FfmpegOptions> {
  final StreamController<FfmpegOptions> _controller =
      StreamController<FfmpegOptions>.broadcast();

  Stream<FfmpegOptions> get stream => _controller.stream;

  @override
  FfmpegOptions get lastUpdate => super.lastUpdate ?? FfmpegOptions();

  @override
  void update(FfmpegOptions element) {
    lastUpdate = element;
    _controller.add(element);
  }

  void changeMaxSize(int maxSize) {
    final options = lastUpdate;
    options.maxSizeInMB = maxSize;
    update(options);
  }

  void changeTwopass(bool isTwoPass) {
    final options = lastUpdate;
    options.isTwopass = isTwoPass;
    update(options);
  }

  void changeCrf(int crf) {
    final options = lastUpdate;
    options.crf = crf;
    update(options);
  }

  void changeTranscodingDevice(EncodingDevice encodeUsing) {
    final options = lastUpdate;
    options.encodeUsing = encodeUsing;
    update(options);
  }

  void changeResolution(AcceptedResolutions resolution) {
    final options = lastUpdate;
    options.resolution = resolution;
    update(options);
  }
}
