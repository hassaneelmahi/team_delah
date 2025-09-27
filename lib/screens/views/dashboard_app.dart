import 'package:admin_coffee/controllers/dashbord_controller.dart';
import 'package:admin_coffee/screens/views/widgets/cusromer_section.dart';
import 'package:admin_coffee/screens/views/widgets/inventory_section.dart';
import 'package:admin_coffee/screens/views/widgets/order_section.dart';
import 'package:admin_coffee/screens/views/widgets/product_section.dart';
import 'package:admin_coffee/screens/views/widgets/sales_section.dart';
import 'package:admin_coffee/screens/views/widgets/statistics_section.dart';
import 'package:admin_coffee/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find();

    return Scaffold(
      backgroundColor: AppColors.text,
      body: Row(
        children: [
          Container(
            width: 200,
            height: double.infinity,
            color: Colors.green,
            child: _buildSideBar(controller),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildContent(controller)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBar(DashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "Main Menu",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: List.generate(
              controller.sections.length,
              (index) => _buildSideBarItem(
                controller.sections[index].icon,
                controller.sections[index].title,
                index,
                controller,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideBarItem(
      IconData icon, String title, int index, DashboardController controller) {
    return Obx(() {
      final isSelected = controller.currentSectionIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeSection(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isSelected ? Colors.orange : Colors.white,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: isSelected ? Colors.orange : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              "Welcome Admin",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DashboardController controller) {
    return Obx(() {
      switch (controller.currentSectionIndex.value) {
        case 0:
          return StatisticsSection();
        case 1:
          return ProductSection();
        case 2:
          return OrderSection();
        case 3:
          return CustomersSection();
        case 4:
          return InventorySection();
        case 5:
          return SalesSection();
        default:
          return Center(
            child: Text("Data Not Found"),
          );
      }
    });
  }
}
