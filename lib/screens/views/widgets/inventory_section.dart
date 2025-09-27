import 'package:admin_coffee/controllers/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventorySection extends StatefulWidget {
  const InventorySection({super.key});

  @override
  State<InventorySection> createState() => _InventorySectionState();
}

class _InventorySectionState extends State<InventorySection> {
  final InventoryController controller = Get.put(InventoryController());

  bool _ascending = true;
  String _sortColumn = "productName";
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "inventory Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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

  Widget _buildDashboardCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCard("Total stock", "500 units", Icons.inventory, Colors.green),
        _buildCard("Loz stck item", "200", Icons.warning, Colors.redAccent),
        _buildCard("Out of stock", "50", Icons.cancel, Colors.greenAccent),
        _buildCard("Reoorder items", "10", Icons.reorder, Colors.orange),
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
                  SizedBox(height: 10),
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
                hintText: "Search Inventory",
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
          final data = _applyFilters(snapshot.data!);
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: [
                          'productName',
                          'stock',
                          'reorderlevel',
                          'totalOrders',
                          'status',
                        ].indexOf(_sortColumn) >=
                        0
                    ? [
                        'productName',
                        'stock',
                        'reorderlevel',
                        'totalOrders',
                        'status',
                      ].indexOf(_sortColumn)
                    : null,
                sortAscending: _ascending,
                columns: [
                  _buildDataColumn("customer ID", 'productName'),
                  _buildDataColumn("customer Name", 'stock'),
                  _buildDataColumn("Email", 'reorderlevel', numeric: true),
                  _buildDataColumn("status", 'status'),
                ],
                rows: data.map((item) => _buildDataRow(item)).toList(),
              ));
        },
      ),
    );
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

  DataRow _buildDataRow(Map<String, dynamic> item) {
    return DataRow(cells: [
      DataCell(Text(item["productName"]?.toString() ?? "N/A")),
      DataCell(Text(item["stock"]?.toString() ?? "N/A")),
      DataCell(Text(item["reorderlevel"]?.toString() ?? "N/A")),
      DataCell(Text(item["status"]?.toString() ?? "N/A")),
    ]);
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    String searchText = _searchController.text.toLowerCase();

    return data.where((item) {
      if (searchText.isNotEmpty &&
          !item["productName"].toLowerCase().contains(searchText)) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("1-30 of 200 items"),
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
