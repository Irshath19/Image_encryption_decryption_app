import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomElevatedButton extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color hoverColor;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    Key? key,
    required this.child,
    required this.backgroundColor,
    required this.hoverColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  _CustomElevatedButtonState createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHovered = false;
        });
      },
      child: ElevatedButton(
        onPressed: widget.onPressed,
        child: widget.child,
        style: ElevatedButton.styleFrom(
          foregroundColor: Color.fromARGB(255, 248, 223, 85),
          backgroundColor: _isHovered ? widget.hoverColor : widget.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class ImageEncryptionApp extends StatefulWidget {
  const ImageEncryptionApp({Key? key}) : super(key: key);

  @override
  _ImageEncryptionAppState createState() => _ImageEncryptionAppState();
}

class _ImageEncryptionAppState extends State<ImageEncryptionApp> {
  Uint8List? _imageBytes;
  Uint8List? _encryptedImageBytes;
  Uint8List? _decryptedImageBytes;
  final String _keyString = 'my32lengthsupersecretnooneknows1'; 
  final String _ivString = 'my16bytesiv12345';
  final int _maxFileSize = 12 * 1024 * 1024; 

  Future<void> pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      if (result.files.single.size > _maxFileSize) {
        // Show an alert dialog if the file size exceeds 12 MB
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('File too large'),
              content: const Text('Please select an image smaller than 12 MB.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      setState(() {
        _imageBytes = result.files.single.bytes;
      });
    }
  }

  Uint8List encryptImage(
      Uint8List imageBytes, String keyString, String ivString) {
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromUtf8(ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encryptedBytes = encrypter.encryptBytes(imageBytes, iv: iv).bytes;
    return Uint8List.fromList(encryptedBytes);
  }

  Uint8List decryptImage(
      Uint8List encryptedBytes, String keyString, String ivString) {
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromUtf8(ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decryptedBytes =
        encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);
    return Uint8List.fromList(decryptedBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Encryption Decryption',
            style: TextStyle(color: Color.fromARGB(255, 249, 249, 249))),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[200], // Background color
      body: Stack(
        children: [
          if (_imageBytes != null)
            Positioned.fill(
              child: SvgPicture.memory(
                _imageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _imageBytes != null
                        ? Column(
                            children: [
                              const Text('Original Image:',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Image.memory(_imageBytes!, height: 180),
                            ],
                          )
                        : Container(),
                    const SizedBox(height: 22),
                    _encryptedImageBytes != null
                        ? Column(
                            children: [
                              const Text('Encrypted Image (not a real image):',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Encrypted Image Data',
                                    style: TextStyle(
                                        color: Colors.grey[700], fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    const SizedBox(height: 22),
                    _decryptedImageBytes != null
                        ? Column(
                            children: [
                              const Text('Decrypted Image:',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Image.memory(_decryptedImageBytes!, height: 180),
                            ],
                          )
                        : Container(),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: () async {
                        await pickImage();
                      },
                      child: const Text('Pick Image'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 14),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_imageBytes != null) {
                          setState(() {
                            _encryptedImageBytes = encryptImage(
                                _imageBytes!, _keyString, _ivString);
                          });
                        }
                      },
                      child: const Text('Encrypt Image'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 14),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_encryptedImageBytes != null) {
                          setState(() {
                            _decryptedImageBytes = decryptImage(
                                _encryptedImageBytes!, _keyString, _ivString);
                          });
                        }
                      },
                      child: const Text('Decrypt Image'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 14),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
