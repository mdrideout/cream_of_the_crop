import 'package:crop_image/crop_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Crop Image Dialog
/// [onCropDone] runs after the [finalCropPixels] have been selected by the user
AlertDialog cropImageDialog(
  BuildContext context,
  Uint8List imageBytes,
  Function(Rect finalCropPixels) onCropDone,
) {
  final CropController controller = CropController(
    aspectRatio: 1,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  return AlertDialog(
    title: const Text("Crop"),
    content: CropImage(
      controller: controller,
      image: Image.memory(imageBytes),
      minimumImageSize: 100,
    ),
    actions: [
      TextButton(
        onPressed: () async {
          Rect finalCropRelative = controller.crop;
          Rect finalCropPixels = controller.cropSize;

          debugPrint(
            "Crop Relative: Top: ${finalCropRelative.top}, Right: ${finalCropRelative.right}, Bottom: ${finalCropRelative.bottom}, Left: ${finalCropRelative.left}",
          );

          debugPrint(
            "Crop Pixels: Top: ${finalCropPixels.top}, Right: ${finalCropPixels.right}, Bottom: ${finalCropPixels.bottom}, Left: ${finalCropPixels.left}",
          );

          onCropDone(finalCropPixels);

          Navigator.of(context).pop();
        },
        child: const Text("Done"),
      ),
    ],
  );
}
