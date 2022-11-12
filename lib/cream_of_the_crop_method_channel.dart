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
}
