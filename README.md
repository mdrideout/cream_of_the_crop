# Cream Of The Crop
Blazingly fast image crop and resize processing for Flutter Web.

**Features:**
- Crop
- Resize

[Logo of cropping whipped cream]


### Why?
This package exists because image resize and crop transformations _on web_ from the dart [image](https://pub.dev/packages/image)
package are slow. See the performance warning on that package for details.

<img src="./assets/benchmark-dart-vs-canvas.png" alt="Dart Image vs Cream Of The Crop Benchmark. 1.591 vs 38.634" width="400" />

### How?

In almost all modern web browsers, **cream_of_the_crop** can leverage the GPU Accelerated HTML &lt;canvas&gt; element to perform resize and crop operations.

### Example
Try the project in the example folder to see how much faster this is compared to the dart image package.

### No User Interface
This package has no user interface for the cropping mechanism. It is designed to be used with [crop_image](https://pub.dev/packages/crop_image)
or any other cropping library that doesn't handle its own image transformation. **crop_image** provides a user interface
for cropping the image, and generates crop values that this package can consume to transform the image data.

### iOS / Android?
This package is for web only. Make use of the `kIsWeb` conditional to ensure you are only calling its functions on web.
Other platforms will throw an unimplemented error.

The [image](https://pub.dev/packages/image) package is much more performant on iOS and Android devices, and should
provide a decent user experience. There is potential to add native Swift and Kotlin code to handle these tasks even faster.
Consider checking out [flutter_native_image](https://pub.dev/packages/flutter_native_image).

# Installation:
Add more readme for setup and use

# Crop Example:
```dart
[Example code here for using crop_image with this plugin]
```


# Room for Improvement
Very large images (over 15MB) can take 2-3 seconds to process. The image processing blocks the main UI thread so a progress indicator won't animate.
This could potentially be fixed by moving the processing code over to external javascript and setting up a web worker, however, the installation
process would be much more complex for the package user. 

A typical 10MP smart phone photo of ~5MB can be processed in under 1 second on an average computer, so in most cases the experience should be good enough as is.