import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerButton extends StatefulWidget {
  final ValueSetter<File> updateImagePathCallback;
  final Color themeColor;

  const ImagePickerButton({
    super.key,
    required this.updateImagePathCallback,
    required this.themeColor,
  });

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  final ImagePicker _picker = ImagePicker();

  File? image;

  void updateSelectedImage(XFile? newImage) {
    if (newImage == null) {
      return;
    }

    File imgFile = File(newImage.path);

    setState(() {
      image = imgFile;
    });

    widget.updateImagePathCallback(imgFile);
  }

  Future _getImageFromCamera() async {
    final returnedImage = await _picker.pickImage(source: ImageSource.camera);

    updateSelectedImage(returnedImage);
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(16.0));

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.themeColor,
                    width: 2,
                  ),
                  borderRadius: borderRadius),
              width: 380,
              height: 200,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: image != null
                    ? Image.file(
                        image!,
                        fit: BoxFit.cover,
                      )
                    : const Center(),
              )),
          SizedBox(
            width: 380,
            height: 200,
            child: IconButton(
              alignment: Alignment.center,
              icon: Icon(
                Icons.camera_alt,
                color: widget.themeColor,
                size: 60,
              ),
              onPressed: () => _getImageFromCamera(),
            ),
          ),
        ],
      ),
    );
  }
}
