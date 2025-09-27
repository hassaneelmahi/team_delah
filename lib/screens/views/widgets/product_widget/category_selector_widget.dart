import 'package:flutter/material.dart';

class CategoryAndSizeWidget extends StatefulWidget {
  final List<String> selectedOptions;

  const CategoryAndSizeWidget({super.key, required this.selectedOptions});

  @override
  State<CategoryAndSizeWidget> createState() => _CategoryAndSizeWidgetState();
}

class _CategoryAndSizeWidgetState extends State<CategoryAndSizeWidget> {
  String? selectedCategory = "Coffee";
  final List<String> categories = [
    "Coffee",
    "Tea",
    "Juice",
    "Smoothie",
    "Pastry",
    "Other"
  ];
  final TextEditingController newCategoryController = TextEditingController();

  List<String> selectedSizes = [];
  final List<String> sizes = ["S", "M", "L", "XL", "XXL"];
  final Map<String, double?> sizePrices = {};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: _buildCategoryWidget(),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 1,
            child: widget.selectedOptions.contains("Size")
                ? _buildSizeSelector()
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Text(
                "Category",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedCategory == null || selectedCategory!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select or enter a category."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Category '${selectedCategory!}' saved successfully!",
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    print("Selected Category: $selectedCategory");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
          _buildDropdownSection(),
          if (selectedCategory == "Other") ...[
            const SizedBox(height: 16),
            _buildCustomCategoryInput(),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Product Category",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade600,
              ),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                  if (selectedCategory != "Other") {
                    newCategoryController.clear();
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCategoryInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Custom Category Name",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: newCategoryController,
          decoration: InputDecoration(
            hintText: "Enter your category name",
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: () {
              String newCategory = newCategoryController.text.trim();
              if (newCategory.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a category name."),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              } else {
                setState(() {
                  categories.insert(categories.length - 1, newCategory);
                  selectedCategory = newCategory;
                });

                newCategoryController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Category '$newCategory' has been added."),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              "Add Category",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Sizes",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedSizes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select at least one size."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (sizePrices.values.any((price) => price == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Please assign prices to all selected sizes."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Sizes and prices saved successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    print("Selected Sizes: $selectedSizes");
                    print("Size Prices: $sizePrices");
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: sizes.map((size) {
              bool isSelected = selectedSizes.contains(size);
              return FilterChip(
                label: Text(
                  size,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.greenAccent.shade400,
                backgroundColor: Colors.grey.shade200,
                elevation: 4,
                pressElevation: 6,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedSizes.add(size);
                      sizePrices[size] = null;
                    } else {
                      selectedSizes.remove(size);
                      sizePrices.remove(size);
                    }
                  });
                },
              );
            }).toList(),
          ),
          if (selectedSizes.isNotEmpty) ...[
            const SizedBox(height: 24),
            Column(
              children: selectedSizes.map((size) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          size,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Enter price",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          onChanged: (value) {
                            setState(() {
                              sizePrices[size] = double.tryParse(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
