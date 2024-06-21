// encryption_util.dart
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionUtil {
  static Uint8List encryptImage(
      Uint8List imageBytes, String keyString, String ivString) {
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromUtf8(ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encryptedBytes = encrypter.encryptBytes(imageBytes, iv: iv).bytes;
    return Uint8List.fromList(encryptedBytes);
  }

  static Uint8List decryptImage(
      Uint8List encryptedBytes, String keyString, String ivString) {
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromUtf8(ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decryptedBytes =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);
    return Uint8List.fromList(decryptedBytes);
  }
}
