import 'package:admin_coffee/controllers/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomersSection extends StatefulWidget {
  const CustomersSection({super.key});

  @override
  State<CustomersSection> createState() => _CustomersSectionState();
}

class _CustomersSectionState extends State<CustomersSection> {
  final CustomerController controller = Get.put(CustomerController());

  bool _ascending = true;
  String _sortColumn = "customerId";
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
              "Customers Overview",
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
        _buildCard("Total Customers", "1000", Icons.people, Colors.green),
        _buildCard(
            "Active Customers", "800", Icons.check_circle, Colors.redAccent),
        _buildCard(
            "Inactive Customers", "150", Icons.block, Colors.greenAccent),
        _buildCard("New Customers", "50", Icons.person_add, Colors.orange),
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
                hintText: "Search Customers",
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
                        'customerId',
                        'customerName',
                        'email',
                        'totalOrders',
                        'status'
                      ].indexOf(_sortColumn) >=
                      0
                  ? [
                      'customerId',
                      'customerName',
                      'email',
                      'totalOrders',
                      'status'
                    ].indexOf(_sortColumn)
                  : null,
              sortAscending: _ascending,
              columns: [
                _buildDataColumn("Customer ID", 'customerId'),
                _buildDataColumn("Customer Name", 'customerName'),
                _buildDataColumn("Email", 'email'),
                _buildDataColumn("Total Orders", 'totalOrders', numeric: true),
                _buildDataColumn("Status", 'status'),
              ],
              rows: data.map((item) => _buildDataRow(item)).toList(),
            ),
          );
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
    return DataRow(
      cells: [
        DataCell(Text(item["customerId"]?.toString() ?? "N/A")),
        DataCell(Text(item["customerName"]?.toString() ?? "N/A")),
        DataCell(Text(item["email"]?.toString() ?? "N/A")),
        DataCell(Text(item["totalOrders"]?.toString() ?? "N/A")),
        DataCell(Text(item["status"]?.toString() ?? "N/A")),
      ],
    );
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    String searchText = _searchController.text.toLowerCase();
    return data.where((item) {
      if (searchText.isNotEmpty &&
          !item["customerName"].toLowerCase().contains(searchText)) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("1-30 of 200 Customers"),
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
        ),
      ],
    );
  }
}
