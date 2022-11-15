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

  /// Crop Image
  /// Crops an image based on the values provided.
  ///
  /// [sx], [sy] = Crop position relative to the top left of the original image
  ///
  /// [sw], [sh] = Width and height of the area to remain
  ///
  /// [dx], [dy] = Relative position on the destination canvas (almost always 0,0 since creating a canvas larger than the desired image is not supported right now)
  ///
  /// [dw], [dh] = Final width and height of the finished image
  Future<Uint8List?> cropImage(Uint8List imageBytes, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh,
      {double quality = 0.8,
      ImageExportType imageExportType = ImageExportType.jpeg,
      bool allowUnequalAspectRatio = false}) async {
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
