import 'package:flutter/material.dart';
import 'general_information_widget.dart';
import 'pricing_and_stock_widget.dart';
import 'category_selector_widget.dart';
import 'custom_option_widget.dart';
import 'custom_panel_widget.dart'; // Import the CustomPanelWidget file

class AddProductDetails extends StatelessWidget {
  final List<String> selectedOptions;

  const AddProductDetails({super.key, required this.selectedOptions});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GeneralInformationAndImageUploadWidget(),
            PricingAndStockWidget(),
            CategoryAndSizeWidget(selectedOptions: selectedOptions),
            if (selectedOptions.contains("add-panel")) ...[
              const SizedBox(height: 16),
              const CustomPanelWidget(),
            ],
            if (selectedOptions.contains("Add-Customization")) ...[
              const SizedBox(height: 16),
              const CustomOptionWidget(),
            ],
          ],
        ),
      ),
    );
  }
}
