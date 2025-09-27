import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GeneralInformationAndImageUploadWidget extends StatefulWidget {
  const GeneralInformationAndImageUploadWidget({super.key});

  @override
  _GeneralInformationAndImageUploadWidgetState createState() =>
      _GeneralInformationAndImageUploadWidgetState();
}

class _GeneralInformationAndImageUploadWidgetState
    extends State<GeneralInformationAndImageUploadWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _hotImage;
  XFile? _coldImage;

  Future<void> _pickImage(bool isHotImage) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isHotImage) {
          _hotImage = pickedFile;
        } else {
          _coldImage = pickedFile;
        }
      });
    }
  }

  void _deleteImage(bool isHotImage) {
    setState(() {
      if (isHotImage) {
        _hotImage = null;
      } else {
        _coldImage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double halfWidth = MediaQuery.of(context).size.width / 2; // Half page width

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: General Information fields
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  "Name Product",
                  "Puffer Jacket With Pocket Detail",
                  controller: nameController,
                  width: halfWidth,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  "Description Product",
                  "Cropped puffer jacket made of technical fabric. High neck and long sleeves. Flap pocket at the chest and in-seam side pockets at the hip. Inside pocket detail. Hem with elastic interior. Zip-up front.",
                  maxLines: 5,
                  controller: descriptionController,
                  width: halfWidth,
                ),
              ],
            ),
          ),
        ),
        // Right side: Image upload section
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Upload Images"),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFixedSizeImageUploadSection(
                      context,
                      Colors.redAccent,
                      true,
                      _hotImage,
                    ),
                    const SizedBox(width: 32),
                    _buildFixedSizeImageUploadSection(
                      context,
                      Colors.blueAccent,
                      false,
                      _coldImage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    String placeholder, {
    int maxLines = 1,
    required TextEditingController controller,
    required double width,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: width,
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildFixedSizeImageUploadSection(
    BuildContext context,
    Color accentColor,
    bool isHotImage,
    XFile? imageFile,
  ) {
    return GestureDetector(
      onTap: () => _pickImage(isHotImage),
      child: Stack(
        children: [
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imageFile.path),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: accentColor.withOpacity(0.8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap to upload",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
          ),
          if (imageFile != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _deleteImage(isHotImage),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
