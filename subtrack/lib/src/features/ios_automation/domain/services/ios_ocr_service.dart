import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final iosOcrServiceProvider = Provider((ref) => IosOcrService());

class IosOcrService {
  static const MethodChannel _methodChannel = MethodChannel('com.subtrack.app/ios_ocr');

  Future<List<String>?> scanDocument() async {
    try {
      final List<dynamic>? result = await _methodChannel.invokeMethod('scanDocument');
      return result?.cast<String>();
    } on PlatformException catch (e) {
      print("Failed to scan document: '${e.message}'.");
      return null;
    }
  }
}
