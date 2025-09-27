import 'package:admin_coffee/controllers/dashbord_controller.dart';
import 'package:admin_coffee/screens/views/widgets/add_admin/add_admin_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StatisticsSection extends StatefulWidget {
  const StatisticsSection({super.key});

  @override
  State<StatisticsSection> createState() => _StatisticsSectionState();
}

class _StatisticsSectionState extends State<StatisticsSection> {
  final DashboardController controller = Get.put(DashboardController());

  bool _ascending = true;
  String _sortColumn = "productName";
  String _filterCategory = "All";
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dashboard Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                     Get.to(() => AddAdminPage());
                  },
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text("Add Admin"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDashboardCards(),
            const SizedBox(height: 30),
            _buildChartsRow(),
            const SizedBox(height: 30),
            _buildFilters(),
            const SizedBox(height: 30),
            _buildDataTable(),
            const SizedBox(height: 20),
            _buildPagination(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCard(
            "Total Revenue", "\$25,000", Icons.attach_money, Colors.green),
        _buildCard(
            "Avg Order Value", "\$100", Icons.bar_chart, Colors.blueAccent),
        _buildCard("Total Customers", "1500", Icons.people, Colors.greenAccent),
        _buildCard(
            "Total Product", "\$25,000", Icons.attach_money, Colors.orange),
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

  Widget _buildChartsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: 350, child: _buildLineChart()),
        SizedBox(width: 350, child: _buildBarChart()),
        SizedBox(width: 340, child: _buildPieChart()),
      ],
    );
  }

  Widget _buildLineChart() {
    return _buildChartsContainer(
      title: "Sales Trend",
      chart: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  ["Jan", "Feb", "Mar", "Apr", "May"][value.toInt()],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  "${value.toInt()}k",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 1.5),
                FlSpot(2, 2),
                FlSpot(3, 2.5),
                FlSpot(4, 3),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(
                    "${barSpot.y}k",
                    TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return _buildChartsContainer(
      title: "Category Sales",
      chart: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ["A", "B", "C", "D"];
                  return Text(
                    titles[value.toInt()],
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}K',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
                x: 0,
                barRods: [BarChartRodData(toY: 10, color: Colors.blueAccent)]),
            BarChartGroupData(
                x: 1,
                barRods: [BarChartRodData(toY: 12, color: Colors.blueAccent)]),
            BarChartGroupData(
                x: 2,
                barRods: [BarChartRodData(toY: 14, color: Colors.blueAccent)]),
            BarChartGroupData(
                x: 3,
                barRods: [BarChartRodData(toY: 8, color: Colors.blueAccent)]),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: _buildChartsContainer(
        title: "Revenue Distribution",
        chart: PieChart(
          PieChartData(
            sectionsSpace: 0,
            centerSpaceRadius: 50,
            sections: [
              PieChartSectionData(
                value: 40,
                color: Colors.blue,
                title: "40%",
                titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              PieChartSectionData(
                value: 30,
                color: Colors.green,
                title: "30%",
                titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              PieChartSectionData(
                value: 20,
                color: Colors.orange,
                title: "20%",
                titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              PieChartSectionData(
                value: 10,
                color: Colors.red,
                title: "10%",
                titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsContainer({required String title, required Widget chart}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          SizedBox(height: 200, child: chart),
        ],
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
          final data = _applyFilters(snapshot.data!);
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: [
                          'productName',
                          'category',
                          'sales',
                          'stock',
                          'totalRevenue',
                          'averageOrderValue',
                          'dateAdded',
                        ].indexOf(_sortColumn) >=
                        0
                    ? [
                        'productName',
                        'category',
                        'sales',
                        'stock',
                        'totalRevenue',
                        'averageOrderValue',
                        'dateAdded',
                      ].indexOf(_sortColumn)
                    : null,
                sortAscending: _ascending,
                columns: [
                  _buildDataColumn("Product Name", 'productName'),
                  _buildDataColumn("Category", 'category'),
                  _buildDataColumn("Sales", 'sales', numeric: true),
                  _buildDataColumn("Stock", 'stock', numeric: true),
                  _buildDataColumn("Total Revenue", 'totalRevenue',
                      numeric: true),
                  _buildDataColumn("Avg Order Value", 'averageOrderValue',
                      numeric: true),
                  _buildDataColumn("Date Added", 'dateAdded'),
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
    String formatNumber(dynamic value) {
      if (value == null) return "N/A";
      if (value is num) return NumberFormat('#,###').format(value);
      return value.toString();
    }

    String formatCurrency(dynamic value) {
      if (value == null) return "N/A";
      if (value is num) return "\$${NumberFormat('#,###.00').format(value)}";
      return value.toString();
    }

    String formatDate(dynamic value) {
      if (value == null) return "N/A";
      try {
        return DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(value.toString()));
      } catch (e) {
        return "Invalid Date";
      }
    }

    return DataRow(cells: [
      DataCell(Text(item["productName"]?.toString() ?? "N/A")),
      DataCell(Text(item["category"]?.toString() ?? "N/A")),
      DataCell(Text(formatNumber(item["sales"]))),
      DataCell(Text(formatNumber(item["stock"]))),
      DataCell(Text(formatCurrency(item["totalRevenue"]))),
      DataCell(Text(formatCurrency(item["averageOrderValue"]))),
      DataCell(Text(formatDate(item["dateAdded"]))),
    ]);
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    String searchText = _searchController.text.toLowerCase();

    var filterData = data.where((item) {
      if (_filterCategory != "All" && item["category"] != _filterCategory) {
        return false;
      }
      if (searchText.isNotEmpty &&
          !item["productName"].toLowerCase().contains(searchText)) {
        return false;
      }
      return true;
    }).toList();

    filterData.sort((a, b) {
      var aValue = a[_sortColumn];
      var bValue = b[_sortColumn];

      if (aValue is String && bValue is String) {
        return _ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      } else if (aValue is num && bValue is num) {
        return _ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      }
      return 0;
    });

    return filterData;
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("1-10 of 50 items"),
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
