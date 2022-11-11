# cream_of_the_crop

Blazingly fast image transformations for Flutter Web.

This package exists because image resize and crop transformations on web from the [image](https://pub.dev/packages/image)
package are unusably slow.

cream_of_the_crop uses the GPU Accelerated HTML \<canvas> element to perform resize and crop operations.

Try the example project to see how much faster this is compared to the dart image package.

There is no user interface for the cropping. This package is designed to be used with [crop_image](https://pub.dev/packages/crop_image), which
provides a user interface for cropping the image, and generates crop values that this package
can use to actually transform the image.

## Features
- Crop
- Resize

# TODO:
Add more readme
