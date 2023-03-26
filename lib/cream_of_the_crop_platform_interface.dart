import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cream_of_the_crop_method_channel.dart';
import 'enums/image_export_type_enum.dart';
import 'models/image_dimensions.dart';

abstract class CreamOfTheCropPlatform extends PlatformInterface {
  /// Constructs a CreamOfTheCropPlatform.
  CreamOfTheCropPlatform() : super(token: _token);

  static final Object _token = Object();

  static CreamOfTheCropPlatform _instance = MethodChannelCreamOfTheCrop();

  /// The default instance of [CreamOfTheCropPlatform] to use.
  ///
  /// Defaults to [MethodChannelCreamOfTheCrop].
  static CreamOfTheCropPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CreamOfTheCropPlatform] when
  /// they register themselves.
  static set instance(CreamOfTheCropPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Uint8List?> scaleImage(
      Uint8List imageBytes, double maxWidth, double maxHeight, double quality, ImageExportType imageExportType) {
    throw UnimplementedError('scaleImage() has not been implemented.');
  }

  Future<Uint8List?> cropImage(Uint8List imageBytes, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh,
      double quality, ImageExportType imageExportType, bool allowUnequalAspectRatio) {
    throw UnimplementedError('scaleImage() has not been implemented.');
  }

  Future<ImageDimensions> getImageDimensions(Uint8List imageBytes) async {
    throw UnimplementedError('getImageDimensions() has not been implemented.');
  }
}
