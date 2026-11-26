import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Privacy & volatile-memory hygiene helpers implementing Module 1 mandates.
///
/// Important engineering honesty note regarding Dart/Flutter memory:
/// Calling [bestEffortWipeBytes] overwrites the mutable [Uint8List] buffer in
/// managed Dart memory with zeroes immediately before releasing references.
/// However, Dart VM garbage collection and underlying platform image decoders
/// may retain transient copies outside direct Dart pointer control. True
/// hardware-isolated zeroization requires native C/Kotlin/Swift enclave code.
class BiometricPrivacyGuard {
  const BiometricPrivacyGuard._();

  /// Overwrites a mutable [Uint8List] buffer with zeroes on a best-effort basis.
  static void bestEffortWipeBytes(Uint8List? bytes) {
    if (bytes == null) return;
    if (bytes.isNotEmpty) {
      bytes.fillRange(0, bytes.length, 0);
    }
  }

  /// Strips JPEG APP1-APP15 metadata segments (including EXIF / GPS / camera
  /// serial metadata) cleanly in memory without persisting temporary files.
  /// Returns the sanitized bytes (or original bytes if non-JPEG / unrecognized).
  static Uint8List stripExifMetadataInMemory(Uint8List rawBytes) {
    if (rawBytes.length < 4) return rawBytes;

    // Check JPEG SOI marker (0xFF, 0xD8)
    if (rawBytes[0] != 0xFF || rawBytes[1] != 0xD8) {
      return rawBytes;
    }

    final output = BytesBuilder(copy: false);
    output.add(const [0xFF, 0xD8]); // SOI

    int offset = 2;
    while (offset + 1 < rawBytes.length) {
      if (rawBytes[offset] != 0xFF) {
        // Reached entropy-coded scan payload
        output.add(rawBytes.sublist(offset));
        break;
      }

      final marker = rawBytes[offset + 1];

      // EOI or SOS (Start of Scan): copy remainder intact
      if (marker == 0xD9 || marker == 0xDA) {
        output.add(rawBytes.sublist(offset));
        break;
      }

      // Standalone markers without length field (RSTn, TEM, padding 0xFF)
      if (marker == 0xFF) {
        offset += 1;
        continue;
      }
      if (marker == 0x00 ||
          marker == 0x01 ||
          (marker >= 0xD0 && marker <= 0xD7)) {
        output.add(rawBytes.sublist(offset, offset + 2));
        offset += 2;
        continue;
      }

      if (offset + 3 >= rawBytes.length) {
        output.add(rawBytes.sublist(offset));
        break;
      }

      final segmentLength =
          (rawBytes[offset + 2] << 8) | rawBytes[offset + 3];
      if (segmentLength < 2 || offset + 2 + segmentLength > rawBytes.length) {
        output.add(rawBytes.sublist(offset));
        break;
      }

      // Drop APP1..APP15 (0xE1..0xEF) & COM (0xFE) metadata blocks while
      // retaining JFIF APP0 (0xE0) and essential quantization/Huffman tables.
      final isSensitiveMetadata =
          (marker >= 0xE1 && marker <= 0xEF) || marker == 0xFE;

      if (!isSensitiveMetadata) {
        output.add(rawBytes.sublist(offset, offset + 2 + segmentLength));
      }

      offset += 2 + segmentLength;
    }

    return output.takeBytes();
  }

  /// Safely deletes temporary plugin capture files immediately after reading
  /// bytes into volatile memory.
  static Future<void> deleteTempFileIfExists(String? filePath) async {
    if (filePath == null || filePath.isEmpty || kIsWeb) return;
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort temp cleanup
    }
  }
}
