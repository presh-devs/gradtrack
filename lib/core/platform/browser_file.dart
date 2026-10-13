import 'dart:convert';

import 'package:file_picker/file_picker.dart';

import 'browser_file_stub.dart' if (dart.library.js_interop) 'browser_file_web.dart' as impl;

/// A picked text file.
class PickedText {
  const PickedText(this.name, this.text);
  final String name;
  final String text;
}

/// Opens the file chooser for CSV/TSV/TXT; null if cancelled.
Future<PickedText?> pickTextFile() async {
  final files = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['csv', 'tsv', 'txt'],
  );
  final file = files.firstOrNull;
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  // Spreadsheet exports are usually UTF-8; fall back to Latin-1 (old Excel).
  String text;
  try {
    text = utf8.decode(bytes);
  } on FormatException {
    text = latin1.decode(bytes);
  }
  return PickedText(file.name, text);
}

/// Saves [text] as a download in the browser (no-op elsewhere).
void downloadTextFile(String filename, String text, {String mimeType = 'text/csv'}) =>
    impl.downloadTextFile(filename, text, mimeType);
