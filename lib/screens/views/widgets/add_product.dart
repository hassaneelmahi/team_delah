import 'package:admin_coffee/screens/views/widgets/product_widget/add_product_details.dart';
import 'package:admin_coffee/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final List<String> availableOptions = [
    "Size",
    "Add-Customization",
    "add-panel"
  ];

  final List<String> tempSelectedOptions = [];
  final List<String> selectedOptions = [];

  void _showOptionsDialog() {
    tempSelectedOptions.clear();
    tempSelectedOptions.addAll(selectedOptions);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Select Options",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableOptions.map((option) {
              return ListTile(
                leading: Icon(
                  tempSelectedOptions.contains(option)
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: tempSelectedOptions.contains(option)
                      ? Colors.green
                      : Colors.grey,
                ),
                title: Text(
                  option,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  setState(() {
                    if (tempSelectedOptions.contains(option)) {
                      tempSelectedOptions.remove(option);
                    } else {
                      tempSelectedOptions.add(option);
                    }
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedOptions.clear();
                  selectedOptions.addAll(tempSelectedOptions);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Apply",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  FontAwesomeIcons.arrowLeft,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  "Back",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 4,
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _showOptionsDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      elevation: 6,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.tune, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Options",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      elevation: 1,
                      shadowColor: Colors.grey.shade200,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.save_outlined,
                            color: Colors.black, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          "Save Draft",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      elevation: 6,
                      shadowColor: Colors.greenAccent.shade200,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          "Add Product",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: AddProductDetails(selectedOptions: selectedOptions),
    );
  }
}
