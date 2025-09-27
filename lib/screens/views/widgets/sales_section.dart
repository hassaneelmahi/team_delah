import 'package:admin_coffee/controllers/sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SalesSection extends StatefulWidget {
  const SalesSection({super.key});

  @override
  State<SalesSection> createState() => _SalesSectionState();
}

class _SalesSectionState extends State<SalesSection> {
  final SalesController controller = Get.put(SalesController());

  bool _ascending = true;
  String _sortColumn = "salesId";
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
              "Sales Overview",
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
        _buildCard("Total Sales", "500 units", Icons.attach_money, Colors.green),
        _buildCard("Total Revenue", "\$50.00", Icons.money, Colors.redAccent),
        _buildCard("Avg Order Value", "\$500", Icons.bar_chart, Colors.greenAccent),
        _buildCard("Sales Growth", "15%", Icons.trending_up, Colors.orange),
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
                hintText: "Search Sales",
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
                'salesId', 'totalAmount', 'orderCount', 'date', 'growth'
              ].indexOf(_sortColumn) >= 0
                  ? ['salesId', 'totalAmount', 'orderCount', 'date', 'growth'].indexOf(_sortColumn)
                  : null,
              sortAscending: _ascending,
              columns: [
                _buildDataColumn("Sales ID", 'salesId'),
                _buildDataColumn("Total Amount", 'totalAmount'),
                _buildDataColumn("Order Count", 'orderCount', numeric: true),
                _buildDataColumn("Date", 'date'),
                _buildDataColumn("Growth", 'growth', numeric: true),
              ],
              rows: data.map((item) => _buildDataRow(item)).toList(),
            ),
          );
        },
      ),
    );
  }

  DataColumn _buildDataColumn(String label, String key, {bool numeric = false}) {
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
        DataCell(Text(item["salesId"]?.toString() ?? "N/A")),
        DataCell(Text(item["totalAmount"]?.toString() ?? "N/A")),
        DataCell(Text(item["orderCount"]?.toString() ?? "N/A")),
        DataCell(Text(item["date"]?.toString() ?? "N/A")),
        DataCell(Text(item["growth"]?.toString() ?? "N/A")),
      ],
    );
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    String searchText = _searchController.text.toLowerCase();
    return data.where((item) {
      if (searchText.isNotEmpty &&
          !item["salesId"].toLowerCase().contains(searchText)) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("1-10 of 500 Sales"),
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
