import 'dart:io';
import 'package:admin_coffee/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart'; // Import this for input formatters

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isButtonEnabled = false;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController.addListener(_updateButtonState);
    phoneController.addListener(_updateButtonState);
    addressController.addListener(_updateButtonState);
    emailController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = nameController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          emailController.text.isNotEmpty;
    });
  }

  bool _isEmailValid(String email) {
    final emailRegExp =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegExp.hasMatch(email);
  }

  bool _isPhoneValid(String phone) {
    final phoneRegExp = RegExp(r"^[0-9]{10}$");
    return phoneRegExp.hasMatch(phone);
  }

  void _saveProfile() {
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    if (!_isEmailValid(email)) {
      _showError("Please enter a valid email address.");
      return;
    }

    if (!_isPhoneValid(phone)) {
      _showError("Please enter a valid 10-digit phone number.");
      return;
    }

    _showSuccess("Profile information saved successfully!");

    nameController.clear();
    phoneController.clear();
    addressController.clear();
    emailController.clear();

    setState(() {
      _image = null;
      isButtonEnabled = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Choose Profile Picture",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  icon: FontAwesomeIcons.camera,
                  label: "Camera",
                  onPressed: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      setState(() {
                        _image = File(pickedFile.path);
                      });
                    }
                  },
                ),
                _buildOptionButton(
                  icon: FontAwesomeIcons.images,
                  label: "Gallery",
                  onPressed: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _image = File(pickedFile.path);
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.background,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            elevation: 5,
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      appBar: AppBar(
        title: const Text(
          "Account",
          style: TextStyle(color: AppColors.text),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 80.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.arrowLeft,
            color: AppColors.text,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Icon(
                                FontAwesomeIcons.camera,
                                color: AppColors.background.withOpacity(0.7),
                                size: 30,
                              )
                            : null,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      if (_image == null)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: AppColors.background,
                            child: Icon(
                              FontAwesomeIcons.plus,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                EditableUserInfoField(
                  icon: FontAwesomeIcons.user,
                  label: 'Name',
                  controller: nameController,
                  hintText: 'Enter your name',
                ),
                EditableUserInfoField(
                  icon: FontAwesomeIcons.phone,
                  label: 'Phone',
                  controller: phoneController,
                  hintText: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                EditableUserInfoField(
                  icon: FontAwesomeIcons.locationArrow,
                  label: 'Address',
                  controller: addressController,
                  hintText: 'Enter your address',
                ),
                EditableUserInfoField(
                  icon: FontAwesomeIcons.envelope,
                  label: 'Email',
                  controller: emailController,
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled ? _saveProfile : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isButtonEnabled ? AppColors.background : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: isButtonEnabled
                          ? AppColors.background.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
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

class EditableUserInfoField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const EditableUserInfoField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.background, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                labelText: label,
                hintText: hintText,
                labelStyle: TextStyle(
                    color: AppColors.background, fontWeight: FontWeight.w600),
                hintStyle: const TextStyle(color: Colors.black45),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
