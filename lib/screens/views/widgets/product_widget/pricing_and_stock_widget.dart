import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PricingAndStockWidget extends StatelessWidget {
  final TextEditingController basePricingController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController discountTypeController = TextEditingController();

  PricingAndStockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double halfWidth = MediaQuery.of(context).size.width / 2; // Half page width

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              _buildSectionTitle("Pricing and Stock"),
              ElevatedButton(
                onPressed: () {
                  // Validation before saving
                  if (basePricingController.text.isEmpty ||
                      quantityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill in all required fields."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    // Save logic
                    print("Base Pricing: ${basePricingController.text}");
                    print("Quantity: ${quantityController.text}");
                    print("Discount: ${discountController.text}");
                    print("Discount Type: ${discountTypeController.text}");

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Pricing and stock details saved!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                child: _buildInputField(
                  "Base Pricing",
                  "\$47.55",
                  controller: basePricingController,
                  width: halfWidth,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: _buildInputField(
                  "Quantity",
                  "77",
                  controller: quantityController,
                  width: halfWidth,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                child: _buildInputField(
                  "Discount",
                  "10%",
                  controller: discountController,
                  width: halfWidth,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{1,3}%?$')),
                  ],
                  onChanged: (value) {
                    // Validate input
                    if (value.isNotEmpty && value.endsWith('%')) {
                      int discount =
                          int.tryParse(value.replaceAll('%', '')) ?? 0;
                      if (discount < 0 || discount > 100) {
                        discountController.text = '100%';
                        discountController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: discountController.text.length),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: _buildInputField(
                  "Discount Type",
                  "Chinese New Year Discount",
                  controller: discountTypeController,
                  width: halfWidth,
                  keyboardType: TextInputType.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String placeholder, {
    required TextEditingController controller,
    required double width,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: width,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
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
        ),
      ],
    );
  }
}
