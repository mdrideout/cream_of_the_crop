import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cream_of_the_crop/cream_of_the_crop.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_tool;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

  DateTime? dartResizeStart;
  DateTime? dartResizeEnd;
  Uint8List? dartImageBytes;
  ui.Image? dartDecodedImage;
  bool dartProcessing = false;

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
      debugPrint("Image failed to resize. Null data received from cream_of_the_crop.");
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
    return MaterialApp(
      home: Scaffold(
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
      ),
    );
  }
}
