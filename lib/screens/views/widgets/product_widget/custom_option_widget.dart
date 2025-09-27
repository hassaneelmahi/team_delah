import 'package:flutter/material.dart';

class CustomOptionWidget extends StatefulWidget {
  const CustomOptionWidget({super.key});

  @override
  State<CustomOptionWidget> createState() => _CustomOptionWidgetState();
}

class _CustomOptionWidgetState extends State<CustomOptionWidget> {
  final TextEditingController customizationNameController =
      TextEditingController();
  final TextEditingController optionTypeController = TextEditingController();
  final TextEditingController optionPriceController = TextEditingController();

  String? customizationName;
  final List<Map<String, dynamic>> optionTypes = [];

  void _addOptionType(String type, String price) {
    if (type.isEmpty) {
      _showSnackbar("Option type cannot be empty!", Colors.redAccent);
      return;
    }

    double parsedPrice = double.tryParse(price) ?? 0.0;

    setState(() {
      optionTypes.add({'type': type.trim(), 'price': parsedPrice});
    });
    optionTypeController.clear();
    optionPriceController.clear();
  }

  void _saveCustomization() {
    if (customizationName == null || customizationName!.isEmpty) {
      _showSnackbar(
          "Please provide a name for the customization.", Colors.redAccent);
      return;
    }

    if (optionTypes.isEmpty) {
      _showSnackbar("Please add at least one option type.", Colors.redAccent);
      return;
    }

    _showSnackbar("Customization saved successfully!", Colors.green);
    print("Customization Name: $customizationName");
    print("Option Types: $optionTypes");
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double halfWidth = MediaQuery.of(context).size.width / 2 - 24;

    return Container(
      width: halfWidth,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add Customization",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _saveCustomization,
                label: const Text(
                  "Save",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabeledInputField(
            "Customization Name",
            "Enter customization name (e.g., Milk)",
            customizationNameController,
            onChanged: (value) => setState(() {
              customizationName = value;
            }),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildLabeledInputField(
                  "Option Type",
                  "Enter option type (e.g., Whole Milk)",
                  optionTypeController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLabeledInputField(
                  "Price",
                  "0.00",
                  optionPriceController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _addOptionType(
                optionTypeController.text, optionPriceController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              "Add Option Type",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (optionTypes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Added Option Types:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: optionTypes.length,
                  itemBuilder: (context, index) {
                    final option = optionTypes[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text(
                        option['type'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        option['price'] == 0.0
                            ? "Free"
                            : "\$${option['price'].toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            optionTypes.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLabeledInputField(
    String label,
    String placeholder,
    TextEditingController controller, {
    void Function(String)? onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
