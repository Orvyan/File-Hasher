import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

typedef ProgressCallback = void Function(double percent);

class _DigestSink implements Sink<Digest> {
  Digest? _value;
  Digest get value {
    final v = _value;
    if (v == null) {
      throw StateError('No digest added to sink.');
    }
    return v;
  }
  @override
  void add(Digest data) { _value = data; }
  @override
  void close() {}
}

class FileHashService {
  final int chunkSize;
  FileHashService({this.chunkSize = 1024 * 64});

  Future<String> computeSha256(File file, {ProgressCallback? onProgress}) async {
    final total = await file.length();
    final raf = await file.open();
    try {
      final digestSink = _DigestSink();
      final converter = sha256.startChunkedConversion(digestSink);
      int processed = 0;
      final buffer = Uint8List(chunkSize);
      while (true) {
        final read = await raf.readInto(buffer);
        if (read == 0) break;
        final chunk = (read == buffer.length) ? buffer : Uint8List.view(buffer.buffer, 0, read);
        converter.add(chunk);
        processed += read;
        if (onProgress != null && total > 0) onProgress(processed / total);
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      converter.close();
      final digest = digestSink.value;
      return _bytesToHex(digest.bytes);
    } finally {
      await raf.close();
    }
  }

  String _bytesToHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
