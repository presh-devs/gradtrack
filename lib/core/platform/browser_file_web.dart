import 'dart:js_interop';

import 'package:web/web.dart' as web;

void downloadTextFile(String filename, String text, String mimeType) {
  final blob = web.Blob([text.toJS].toJS, web.BlobPropertyBag(type: '$mimeType;charset=utf-8'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
