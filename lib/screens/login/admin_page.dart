import 'package:admin_coffee/screens/views/dashboard_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_coffee/theme/app_color.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final String correctCode = "1234"; // Set the required code here
  final int requiredCodeLength = 4;
  late final List<TextEditingController> _controllers =
      List.generate(requiredCodeLength, (index) => TextEditingController());

  void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12.0,
      margin: EdgeInsets.all(16),
      icon: Icon(Icons.error_outline, color: Colors.white),
      padding: EdgeInsets.all(16),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0, 4),
          blurRadius: 10,
        ),
      ],
    );
  }

  void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12.0,
      margin: EdgeInsets.all(16),
      icon: Icon(Icons.check_circle_outline, color: Colors.white),
      padding: EdgeInsets.all(16),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0, 4),
          blurRadius: 10,
        ),
      ],
    );
  }

  void validateCode() {
    FocusScope.of(context).unfocus();
    String enteredCode = _controllers.map((controller) => controller.text).join();

    if (enteredCode.length < requiredCodeLength) {
      showErrorSnackbar('Error', 'Please enter a $requiredCodeLength-digit code.');
    } else if (enteredCode == correctCode) {
      showSuccessSnackbar('Success', 'Access granted successfully!');
      // Navigate to the DashboardApp page
      Get.to(() => DashboardApp());
    } else {
      showErrorSnackbar('Error', 'Incorrect code. Please try again.');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Image.asset(
                "assets/images/admin.png",
                height: 200,
              ),
              const SizedBox(height: 30),
              const Text(
                "Admin Access",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Please enter the $requiredCodeLength-digit admin code to access the dashboard.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(requiredCodeLength, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 50,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < requiredCodeLength - 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: validateCode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  backgroundColor: AppColors.background,
                  shadowColor: Colors.black26,
                ),
                child: const Text(
                  'Access Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
