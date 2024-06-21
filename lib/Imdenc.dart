// image_picker_and_encrypt.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import './imgutil.dart'; // Import the encryption utilities
import 'package:url_launcher/url_launcher.dart';

class ImagePickerAndEncrypt extends StatefulWidget {
  const ImagePickerAndEncrypt({Key? key}) : super(key: key);

  @override
  _ImagePickerAndEncryptState createState() => _ImagePickerAndEncryptState();
}

class _ImagePickerAndEncryptState extends State<ImagePickerAndEncrypt> {
  Uint8List? _imageBytes;
  Uint8List? _encryptedImageBytes;
  final String _keyString = 'my32lengthsupersecretnooneknows1'; // 32 chars
  final String _ivString = 'my16bytesiv12345'; // 16 chars
  final int _maxFileSize = 12 * 1024 * 1024; // 12 MB in bytes

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

  Future<String> _saveAndReturnFilePath(
      Uint8List bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';
    File file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  Future<void> encryptAndDownload() async {
    if (_imageBytes != null) {
      Uint8List encryptedBytes =
          EncryptionUtil.encryptImage(_imageBytes!, _keyString, _ivString);

      String filePath =
          await _saveAndReturnFilePath(encryptedBytes, 'encrypted_image.png');

      // Launch download dialog
      await launch(filePath);
    } else {
      // Show an alert if no image is selected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No image selected'),
            content: const Text('Please select an image to encrypt.'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Encryption',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[200], // Background color
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _imageBytes != null
                    ? Column(
                        children: [
                          const Text('Selected Image:',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Image.memory(_imageBytes!, height: 180),
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
                    encryptAndDownload();
                  },
                  child: const Text('Encrypt Image & Download'),
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
    );
  }
}
