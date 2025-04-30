import 'package:atlas_app/imports.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:convert/convert.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';

final _key = dotenv.env['ENCRYPT_KEY'] ?? '';
final _apiKey = dotenv.env['API_KEY'] ?? "";

String encryptMessage(String message) {
  final keyBytes = encrypt.Key(Uint8List.fromList(hex.decode(_key)));
  final iv = encrypt.IV(
    Uint8List(16)..setRange(0, 16, List<int>.generate(16, (i) => Random.secure().nextInt(256))),
  );
  final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));
  final encrypted = encrypter.encrypt(message, iv: iv);
  return base64.encode(iv.bytes + encrypted.bytes);
}

String decryptMessage(String encryptedMessage) {
  final keyBytes = encrypt.Key(Uint8List.fromList(hex.decode(_key)));
  final encryptedBytes = Uint8List.fromList(base64.decode(encryptedMessage));
  final iv = encrypt.IV(encryptedBytes.sublist(0, 16));
  final cipherText = encryptedBytes.sublist(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));

  final decrypted = encrypter.decryptBytes(encrypt.Encrypted(cipherText), iv: iv);

  return utf8.decode(decrypted);
}

Future<Map<String, String>> generateAuthHeaders() async {
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final nonce = _generateNonce(16);
  final message = '$timestamp:$nonce';

  final hmac = Hmac(sha256, utf8.encode(_apiKey));
  final hash = hmac.convert(utf8.encode(message)).toString();

  return {
    'x-timestamp': timestamp,
    'x-nonce': nonce,
    'x-hash': hash,
    'Content-Type': 'application/json',
  };
}

String _generateNonce(int length) {
  final random = Random.secure();
  const chars = '0123456789abcdef';
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}
