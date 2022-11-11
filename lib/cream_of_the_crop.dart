import 'dart:typed_data';

import 'cream_of_the_crop_platform_interface.dart';
import 'enums/image_export_type_enum.dart';

class CreamOfTheCrop {
  Future<String?> getPlatformVersion() {
    return CreamOfTheCropPlatform.instance.getPlatformVersion();
  }

  /// Scale Image
  /// Scales an image to fit within the bounds of [maxWidth] and [maxHeight]
  Future<Uint8List?> scaleImage(Uint8List imageBytes, double maxWidth, double maxHeight,
      {double quality = 0.8, ImageExportType imageExportType = ImageExportType.jpeg}) async {
    return await CreamOfTheCropPlatform.instance.scaleImage(
      imageBytes,
      maxWidth,
      maxHeight,
      quality,
      imageExportType,
    );
  }
}
