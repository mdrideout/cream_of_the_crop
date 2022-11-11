import 'dart:ui' as ui;

import 'package:cream_of_the_crop/cream_of_the_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final double imageDisplayWidth = 300;
  XFile? pickedImage;
  Uint8List? imageBytes;
  ui.Image? decodedImage;

  // Converted image vars
  final double resizeMaxDimension = 300;
  DateTime? creamResizeStart;
  DateTime? creamResizeEnd;
  bool creamResizeLoading = false;
  Uint8List? creamImageBytes;
  ui.Image? creamDecodedImage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
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
                  Text("Size: ${(imageBytes!.lengthInBytes * 0.000001).toStringAsFixed(2)} MB"),
                  Text("Width: ${decodedImage!.width}px, Height: ${decodedImage!.height}px"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        creamResizeLoading = true;
                        creamResizeStart = DateTime.now();
                      });

                      await Future.delayed(const Duration(microseconds: 3000));

                      Uint8List? resizeBytes =
                          await _creamOfTheCropPlugin.scaleImage(imageBytes!, resizeMaxDimension, double.infinity);

                      if (resizeBytes == null) {
                        debugPrint("Image failed to resize. Null data received from cream_of_the_crop.");
                        return;
                      }

                      // Decode as image
                      ui.Image decoded = await decodeImageFromList(resizeBytes);

                      setState(() {
                        creamImageBytes = resizeBytes;
                        creamDecodedImage = decoded;
                        creamResizeLoading = false;
                        creamResizeEnd = DateTime.now();
                      });
                    },
                    child: const Text("Resize Image: Cream Of The Crop"),
                  ),
                ],
                const SizedBox(height: 20),
                if (creamResizeLoading) const CircularProgressIndicator(),
                if (creamImageBytes != null && creamDecodedImage != null) ...[
                  SizedBox(width: imageDisplayWidth, child: Image.memory(creamImageBytes!)),
                  Text("Size: ${(creamImageBytes!.lengthInBytes * 0.000001).toStringAsFixed(2)} MB"),
                  Text("Width: ${creamDecodedImage!.width}px, Height: ${creamDecodedImage!.height}px"),
                  Text("Processing Time: ${creamResizeEnd!.difference(creamResizeStart!).inSeconds}")
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
