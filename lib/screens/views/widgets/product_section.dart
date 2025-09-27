import 'package:admin_coffee/controllers/product_controller.dart';
import 'package:admin_coffee/screens/views/widgets/add_product.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductSection extends StatefulWidget {
  const ProductSection({super.key});

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  final ProductController controller = Get.put(ProductController());

  bool _ascending = true;
  String _sortColumn = "productName";
  String _filterCategory = "All";
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            _buildDashboardCards(),
            SizedBox(height: 30),
            _buildFilters(),
            SizedBox(height: 30),
            _buildDataTable(),
            SizedBox(height: 20),
            _buildPagination(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Products Overview",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Get.to(() => AddProduct());
          },
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            "Add Product",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            backgroundColor: Colors.greenAccent.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
            shadowColor: Colors.greenAccent.shade200,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCard("Total Products", "\$500", Icons.inventory, Colors.green),
        _buildCard("Out of Stock", "\500", Icons.warning, Colors.redAccent),
        _buildCard(
            "New Products", "1500", Icons.new_releases, Colors.greenAccent),
        _buildCard("Category", "\$25,000", Icons.category, Colors.orange),
      ],
    );
  }

  Widget _buildCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 30),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search Product",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
          SizedBox(width: 16),
          DropdownButton<String>(
            value: _filterCategory,
            onChanged: (value) => setState(() {
              _filterCategory = value!;
            }),
            underline: Container(),
            icon: Icon(Icons.filter_list),
            items: [
              "All",
              "Category0",
              "Category1",
              "Category2",
              "Category3",
              "Category4"
            ]
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Something Went Wrong"));
          }
          final data = snapshot.data ?? [];
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: [
                'productName',
                'category',
                'stock',
                'price',
                'sku'
              ].indexOf(_sortColumn),
              sortAscending: _ascending,
              columns: [
                _buildDataColumn("Product Name", 'productName'),
                _buildDataColumn("Category", 'category'),
                _buildDataColumn("Stock", 'stock', numeric: true),
                _buildDataColumn("Price", 'price', numeric: true),
                _buildDataColumn("SKU", 'sku'),
              ],
              rows: data.map((item) => _buildDataRow(item)).toList(),
            ),
          );
        },
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> item) {
    return DataRow(cells: [
      DataCell(Text(item["productName"]?.toString() ?? "N/A")),
      DataCell(Text(item["category"]?.toString() ?? "N/A")),
      DataCell(Text(item["stock"]?.toString() ?? "N/A")),
      DataCell(Text(item["price"]?.toString() ?? "N/A")),
      DataCell(Text(item["sku"]?.toString() ?? "N/A")),
    ]);
  }

  DataColumn _buildDataColumn(String label, String key,
      {bool numeric = false}) {
    return DataColumn(
      label: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      numeric: numeric,
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumn = key;
          _ascending = ascending;
        });
      },
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("1-5 of 5 items"),
        SizedBox(width: 16),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.chevron_left),
          color: Colors.grey,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.redAccent, borderRadius: BorderRadius.circular(4)),
          child: Text(
            "1",
            style: TextStyle(color: Colors.white),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.chevron_right),
          color: Colors.redAccent,
        )
      ],
    );
  }
}
