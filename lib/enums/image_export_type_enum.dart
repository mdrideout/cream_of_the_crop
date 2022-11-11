enum ImageExportType {
  jpeg,
  png,
}

extension DataMediaTypeExtension on ImageExportType {
  String get mediaType {
    switch (this) {
      case ImageExportType.jpeg:
        return "image/jpeg";
      case ImageExportType.png:
        return "image/png";
      default:
        return "image/jpg";
    }
  }
}
