import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cream_of_the_crop_platform_interface.dart';
import 'enums/image_export_type_enum.dart';

/// An implementation of [CreamOfTheCropPlatform] that uses method channels.
class MethodChannelCreamOfTheCrop extends CreamOfTheCropPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cream_of_the_crop');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Uint8List?> scaleImage(
      Uint8List imageBytes, double maxWidth, double maxHeight, double quality, ImageExportType imageExportType) async {
    return await CreamOfTheCropPlatform.instance.scaleImage(
      imageBytes,
      maxWidth,
      maxHeight,
      quality,
      imageExportType,
    );
  }

  @override
  Future<Uint8List?> cropImage(Uint8List imageBytes, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh,
      double quality, ImageExportType imageExportType, bool allowUnequalAspectRatio) async {
    return await CreamOfTheCropPlatform.instance.cropImage(
      imageBytes,
      sx,
      sy,
      sw,
      sh,
      dx,
      dy,
      dw,
      dh,
      quality,
      imageExportType,
      allowUnequalAspectRatio,
    );
  }
}
