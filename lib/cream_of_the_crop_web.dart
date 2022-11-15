// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';

import 'package:cream_of_the_crop/enums/image_export_type_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'cream_of_the_crop_platform_interface.dart';
import 'util/util.dart';

/// A web implementation of the CreamOfTheCropPlatform of the CreamOfTheCrop plugin.
class CreamOfTheCropWeb extends CreamOfTheCropPlatform {
  /// Constructs a CreamOfTheCropWeb
  CreamOfTheCropWeb();

  static void registerWith(Registrar registrar) {
    CreamOfTheCropPlatform.instance = CreamOfTheCropWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }

  @override
  Future<Uint8List?> scaleImage(
    Uint8List imageBytes,
    double maxWidth,
    double maxHeight,
    double quality,
    ImageExportType imageExportType,
  ) async {
    if (quality > 1 || quality < 0) {
      throw ("Quality must be between 0 and 1 (inclusive) and not null");
    }

    // Convert to base64 string
    String base64Image = base64Encode(imageBytes);

    // Get the base64 URI media type
    String mediaType = getDataUriImageMediaType(base64Image);

    // Create an HTML image element to hold our image
    var image = html.ImageElement();
    image.src = 'data:$mediaType;base64,$base64Image';

    // Wait for the image to load / render
    await image.onLoad.first;

    // Get the greater scale discrepancy based on width / height so we know how to factor down the image to fit within the bounds
    double heightScale = maxHeight / image.height!;
    double widthScale = maxWidth / image.width!;

    double scaleFactor = min(heightScale, widthScale);

    int scaledWidth = (image.width! * scaleFactor).toInt();
    int scaledHeight = (image.height! * scaleFactor).toInt();

    // Create a Canvas we can use to draw and transform the image
    var canvas = html.CanvasElement(width: scaledWidth, height: scaledHeight);

    // Get 2d context of the canvas
    var ctx = canvas.context2D;

    // Draw the scaled image
    ctx.drawImageScaled(image, 0, 0, scaledWidth, scaledHeight);

    // Convert to a base64 data URL
    String exportDataUrl = canvas.toDataUrl(imageExportType.mediaType, quality);

    // Convert back to bytes
    UriData? uriData = Uri.parse(exportDataUrl).data;

    if (uriData == null) {
      throw ("scaleImage() Canvas export uriData was null.");
    }

    // Convert back to bytes
    Uint8List exportData = uriData.contentAsBytes();

    // Return
    return exportData;
  }

  @override
  Future<Uint8List?> cropImage(Uint8List imageBytes, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh,
      double quality, ImageExportType imageExportType, bool allowUnequalAspectRatio) async {
    // Validate quality
    if (quality > 1 || quality < 0) {
      throw ("Quality must be between 0 and 1 (inclusive) and not null");
    }

    // Validate export width and height match aspect ratio of cropped pixels
    String croppedAspectRatio = (sw / sh).toStringAsFixed(2);
    String exportAspectRatio = (dw / dh).toStringAsFixed(2);
    if ((croppedAspectRatio != exportAspectRatio) && allowUnequalAspectRatio == false) {
      throw ("Crop and export aspect ratios must match (rounded to two decimal places). Ex: 4:6 = 0.67; 1:1 = 1. Provider cropped aspect ratio: $croppedAspectRatio, provided export aspect ratio: $exportAspectRatio. Use `allowUnequalAspectRatio: true` to force and stretch the exported image.");
    }

    // Convert to base64 string
    String base64Image = base64Encode(imageBytes);

    // Get the base64 URI media type
    String mediaType = getDataUriImageMediaType(base64Image);

    // Create an HTML image element to hold our image
    var image = html.ImageElement();
    image.src = 'data:$mediaType;base64,$base64Image';

    // Wait for the image to load / render
    await image.onLoad.first;

    // Create a Canvas we can use to draw and transform the image
    var canvas = html.CanvasElement(width: dw, height: dh);

    // Get 2d context of the canvas
    var ctx = canvas.context2D;

    // Source Rectangle
    html.Rectangle sourceRect = html.Rectangle(sx, sy, sw, sh);

    // Destination Rectangle
    html.Rectangle destRect = html.Rectangle(dx, dy, dw, dh);

    // Draw the scaled image
    ctx.drawImageToRect(image, destRect, sourceRect: sourceRect);
    // ctx.drawImageScaledFromSource(image, sx, sy, sw, sh, dx, dy, dw, dh);

    // Convert to a base64 data URL
    String exportDataUrl = canvas.toDataUrl(imageExportType.mediaType, quality);

    // Convert back to bytes
    UriData? uriData = Uri.parse(exportDataUrl).data;

    if (uriData == null) {
      throw ("cropImage() Canvas export uriData was null.");
    }

    // Convert back to bytes
    Uint8List exportData = uriData.contentAsBytes();

    // Return
    return exportData;
  }
}
