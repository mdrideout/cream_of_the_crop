String getDataUriImageMediaType(String base64Image) {
  // The first character can be used to identify the media type
  final imageTypeId = base64Image[0];

  // Convert the id to the uri field required value
  switch (imageTypeId) {
    case "/":
      return "image/jpeg";
    case "i":
      return "image/png";
    case "R":
      return "image/gif";
    case "U":
      return "image/webp";
    default:
      return "image/jpeg";
  }
}
