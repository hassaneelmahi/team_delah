import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SectionModel {
  final String title;
  final IconData icon;

  const SectionModel({
    required this.title,
    required this.icon,
  });
}

class DashboardController extends GetxController {
  final RxInt currentSectionIndex = 0.obs;

  final RxBool sidebarOpen = true.obs;

  final List<SectionModel> sections = const [
    SectionModel(title: "Statistics", icon: FontAwesomeIcons.caretDown),
    SectionModel(title: "Products", icon: FontAwesomeIcons.shoppingBag),
    SectionModel(title: "Orders", icon: FontAwesomeIcons.firstOrder),
    SectionModel(title: "Customers", icon: FontAwesomeIcons.peopleGroup),
    SectionModel(title: "Inventory", icon: FontAwesomeIcons.fileInvoice),
    SectionModel(title: "Sales", icon: FontAwesomeIcons.moneyBill),
  ];

  Future<List<Map<String, dynamic>>> fetchData() async {
    return List.generate(
      5,
      (index) => {
        'productName': 'Product $index',
        'sales': '\$${(index + 1) * 1000}',
        'stock': '${(index + 1) * 20} units',
        'category': 'Category $index',
        'dateAdded': '2024-10-1${index + 1}',
        'totalRevenue': '\$${(index + 1) * 5000}',
        'averageOrderValue': '\$${(index + 1) * 50}',
        'customerCount': (index + 1) * 100,
      },
    );
  }

  void changeSection(int index) {
    currentSectionIndex.value = index;
  }

  void toggleSidebar() {
    sidebarOpen.value = !sidebarOpen.value;
  }
}
