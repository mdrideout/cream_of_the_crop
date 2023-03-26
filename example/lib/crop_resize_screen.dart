import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cream_of_the_crop/cream_of_the_crop.dart';
import 'package:cream_of_the_crop/models/image_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_tool;
import 'package:image_picker/image_picker.dart';

import 'crop_image_dialog.dart';

class CropResizeScreen extends StatefulWidget {
  const CropResizeScreen({Key? key}) : super(key: key);

  @override
  State<CropResizeScreen> createState() => _CropResizeScreenState();
}

class _CropResizeScreenState extends State<CropResizeScreen> {
  final _creamOfTheCropPlugin = CreamOfTheCrop();

  // Image picking state

  // Image related
  final ImagePicker imagePicker = ImagePicker();
  final double imageDisplayWidth = 600;
  XFile? pickedImage;
  Uint8List? imageBytes;
  ui.Image? decodedImage;

  // Converted image vars
  final double resizeMaxDimension = 600;
  final double resizeQuality = 0.80;

  DateTime? creamResizeStart;
  DateTime? creamResizeEnd;
  Uint8List? creamImageBytes;
  ui.Image? creamDecodedImage;
  bool creamProcessing = false;

  DateTime? creamCropResizeStart;
  DateTime? creamCropResizeEnd;
  Uint8List? creamCropImageBytes;
  ui.Image? creamCropDecodedImage;
  bool creamCropProcessing = false;

  DateTime? dartResizeStart;
  DateTime? dartResizeEnd;
  Uint8List? dartImageBytes;
  ui.Image? dartDecodedImage;
  bool dartProcessing = false;

  void printDimensions() async {
    ImageDimensions imageDimensions = await _creamOfTheCropPlugin.getImageDimensions(imageBytes!);
    print("Image Dimensions - Height: ${imageDimensions.height}; Width: ${imageDimensions.width}");
  }

  /// Cream Of The Crop Resize Function
  void creamResize() async {
    setState(() {
      creamResizeStart = DateTime.now();
      creamProcessing = true;
    });

    Uint8List? resizeBytes = await _creamOfTheCropPlugin.scaleImage(
      imageBytes!,
      resizeMaxDimension,
      double.infinity,
    );

    if (resizeBytes == null) {
      debugPrint("Image failed to resize. Null data received from cream_of_the_crop scaleImage().");
      return;
    }

    // Decode as image
    ui.Image decoded = await decodeImageFromList(resizeBytes);

    setState(() {
      creamImageBytes = resizeBytes;
      creamDecodedImage = decoded;
      creamResizeEnd = DateTime.now();
      creamProcessing = false;
    });
  }

  /// Cream Of The Crop Crop Function
  void creamCrop(Rect finalCropPixels) async {
    setState(() {
      creamCropResizeStart = DateTime.now();
      creamCropProcessing = true;
    });

    // Create all variables for cropping
    // dart:ui decoded original image dimensions
    int decodedWidth = decodedImage!.width;
    int decodedHeight = decodedImage!.height;
    debugPrint("Width: $decodedWidth, Height: $decodedHeight");

    // Desired final pixel size of the image
    int exportWidth = 500;
    int exportHeight = 500;

    // Values provided by crop_image package cropping UI
    double cropTop = finalCropPixels.top;
    double cropRight = finalCropPixels.right;
    double cropBottom = finalCropPixels.bottom;
    double cropLeft = finalCropPixels.left;

    // Distances From Edges
    int distTop = cropTop.toInt();
    int distRight = (decodedWidth - cropRight).toInt();
    int distLeft = cropLeft.toInt();
    int distBottom = (decodedHeight - cropBottom).toInt();

    // Calculated crop values needed to create the cropped image data
    int sx = distLeft;
    int sy = distTop;
    int sw = decodedWidth - distLeft - distRight;
    int sh = decodedHeight - distTop - distBottom;
    int dx = 0;
    int dy = 0;
    int dw = exportWidth;
    int dh = exportHeight;

    // Crop the image (from the original image bytes)
    Uint8List? croppedBytes = await _creamOfTheCropPlugin.cropImage(
      imageBytes!,
      sx,
      sy,
      sw,
      sh,
      dx,
      dy,
      dw,
      dh,
    );

    if (croppedBytes == null) {
      debugPrint("Image failed to crop. Null data received from cream_of_the_crop cropImage().");
      return;
    }

    // Decode as image
    ui.Image decoded = await decodeImageFromList(croppedBytes);

    setState(() {
      creamCropImageBytes = croppedBytes;
      creamCropDecodedImage = decoded;
      creamCropResizeEnd = DateTime.now();
      creamCropProcessing = false;
    });
  }

  /// Dart Image Resize Function
  void dartResize() async {
    setState(() {
      dartResizeStart = DateTime.now();
      dartProcessing = true;
    });

    // Decode the image to the dart_image format
    image_tool.Image? dartImage = image_tool.decodeImage(imageBytes!);

    if (dartImage == null) {
      debugPrint("dart_image failed to decode the picked image.");
      return;
    }

    // Resize the image
    image_tool.Image resizedImage = image_tool.copyResize(dartImage, width: resizeMaxDimension.toInt());

    // Encode it back as a jpg
    Uint8List resizedBytes =
        Uint8List.fromList(image_tool.encodeJpg(resizedImage, quality: (resizeQuality * 100).toInt()));

    // Decode for dart:ui so we can access the dimensions
    ui.Image decoded = await decodeImageFromList(resizedBytes);

    setState(() {
      dartImageBytes = resizedBytes;
      dartDecodedImage = decoded;
      dartResizeEnd = DateTime.now();
      dartProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cream Of The Crop Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                  "This is meant for Flutter Web only. iOS and Android do not have the image processing speed issues of dart web."),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

                  if (image != null) {
                    debugPrint("Picked Image ${image.path}");

                    // Read as bytes
                    Uint8List bytes = await image.readAsBytes();

                    // Decode as image
                    ui.Image decoded = await decodeImageFromList(bytes);

                    setState(() {
                      pickedImage = image;
                      imageBytes = bytes;
                      decodedImage = decoded;
                    });
                  }
                },
                child: const Text("Pick An Image"),
              ),
              if (imageBytes != null && decodedImage != null) ...[
                const SizedBox(height: 20),
                SizedBox(width: imageDisplayWidth, child: Image.memory(imageBytes!)),
                const SizedBox(height: 10),
                Text("Size: ${(imageBytes!.lengthInBytes * 0.000001).toStringAsFixed(3)} MB"),
                Text("Width: ${decodedImage!.width}px, Height: ${decodedImage!.height}px"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    printDimensions();
                  },
                  child: const Text("Get Image Dimensions Via Cream Of Crop Web"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            creamResize();
                          },
                          child: const Text("Resize Image: Cream Of The Crop"),
                        ),
                        const SizedBox(height: 20),
                        if (creamProcessing) ...const [
                          Text("Processing image with cream..."),
                          CircularProgressIndicator(),
                        ],
                        if (creamImageBytes != null && creamDecodedImage != null) ...[
                          SizedBox(width: imageDisplayWidth, child: Image.memory(creamImageBytes!)),
                          const SizedBox(height: 10),
                          Text(
                              "Size: ${(creamImageBytes!.lengthInBytes * 0.000001).toStringAsFixed(3)} MB at $resizeQuality quality"),
                          Text("Width: ${creamDecodedImage!.width}px, Height: ${creamDecodedImage!.height}px"),
                          Text(
                              "Processing Time: ${(creamResizeEnd!.difference(creamResizeStart!).inMilliseconds / 1000).toStringAsFixed(3)} seconds")
                        ],
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Launch the crop dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return cropImageDialog(context, imageBytes!, (Rect finalCropPixels) {
                                  // Perform the crop with cream_of_the_crop
                                  creamCrop(finalCropPixels);
                                });
                              },
                            );
                          },
                          child: const Text("Crop Image: Cream Of The Crop"),
                        ),
                        const SizedBox(height: 20),
                        if (creamCropProcessing) ...const [
                          Text("Processing image with dart..."),
                          CircularProgressIndicator(),
                        ],
                        if (creamCropImageBytes != null && creamCropDecodedImage != null) ...[
                          SizedBox(width: imageDisplayWidth, child: Image.memory(creamCropImageBytes!)),
                          const SizedBox(height: 10),
                          Text(
                              "Size: ${(creamCropImageBytes!.lengthInBytes * 0.000001).toStringAsFixed(3)} MB at $resizeQuality quality"),
                          Text("Width: ${creamCropDecodedImage!.width}px, Height: ${creamCropDecodedImage!.height}px"),
                          Text(
                              "Processing Time: ${(creamCropResizeEnd!.difference(creamCropResizeStart!).inMilliseconds / 1000).toStringAsFixed(3)} seconds")
                        ],
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            dartResize();
                          },
                          child: const Text("Resize Image: Dart Image"),
                        ),
                        const SizedBox(height: 20),
                        if (dartProcessing) ...const [
                          Text("Processing image with dart..."),
                          CircularProgressIndicator(),
                        ],
                        if (dartImageBytes != null && dartDecodedImage != null) ...[
                          SizedBox(width: imageDisplayWidth, child: Image.memory(dartImageBytes!)),
                          const SizedBox(height: 10),
                          Text(
                              "Size: ${(dartImageBytes!.lengthInBytes * 0.000001).toStringAsFixed(3)} MB at $resizeQuality quality"),
                          Text("Width: ${dartDecodedImage!.width}px, Height: ${dartDecodedImage!.height}px"),
                          Text(
                              "Processing Time: ${(dartResizeEnd!.difference(dartResizeStart!).inMilliseconds / 1000).toStringAsFixed(3)} seconds")
                        ],
                      ],
                    )
                  ],
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
