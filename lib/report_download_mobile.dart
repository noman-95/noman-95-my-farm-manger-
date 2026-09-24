import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

Future<void> downloadBytes(Uint8List bytes, String filename, String mime) async {
  await Share.shareXFiles([XFile.fromData(bytes, name: filename, mimeType: mime)],
      subject: filename);
}
