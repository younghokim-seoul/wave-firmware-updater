
extension ExtractStringExtension on String {
  String extractDataBootloaderData() {


    print(this);
    int startIndex = indexOf(',') + 1;
    int endIndex = indexOf('%');

    if (startIndex >= 0 && endIndex >= 0 && endIndex > startIndex) {
      print("substring(startIndex, endIndex) "  + substring(startIndex, endIndex));
      return substring(startIndex, endIndex);
    } else {
      return '';
    }
  }


  String extractDataFirmwareDownData() {
    int startIndex = indexOf('\$\$') + 2;
    int endIndex = indexOf('%');

    if (startIndex >= 0 && endIndex >= 0 && endIndex > startIndex) {
      return substring(startIndex, endIndex);
    } else {
      return '';
    }
  }
}