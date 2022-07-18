import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerDialog extends StatefulWidget {
  final Function(String) updatePhoto;
  const ImagePickerDialog({Key? key, required this.updatePhoto}) : super(key: key);

  @override
  _ImagePickerDialogState createState() => _ImagePickerDialogState();
}

class _ImagePickerDialogState extends State<ImagePickerDialog> {
  final ImagePicker imagePicker = ImagePicker();

  void _openGallery(BuildContext context) async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    String imagePath = pickedFile!.path;
    widget.updatePhoto(imagePath);
    Navigator.pop(context);
  }

  void _openCamera(BuildContext context) async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    String imagePath = pickedFile!.path;
    widget.updatePhoto(imagePath);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Choose option",
        style: TextStyle(color: Colors.blue),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            const Divider(height: 1, color: Colors.black),
            ListTile(
              onTap: () {
                _openGallery(context);
              },
              title: const Text("Gallery"),
              leading: const Icon(Icons.photo, color: Colors.blue),
            ),
            const Divider(height: 1, color: Colors.black),
            ListTile(
              onTap: () {
                _openCamera(context);
              },
              title: const Text("Camera"),
              leading: const Icon(
                Icons.camera_alt,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}