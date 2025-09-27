import 'package:get/get.dart';

class InventoryController extends GetxController{
   Future<List<Map<String, dynamic>>> fetchData() async {
    return List.generate(
      5,
      (index) => {
        'productName': 'product $index',
        'stock': '${(index + 1) * 20} units',
        'reorderlevel': '${(index + 1) * 5} units',
        'status' : index % 2 == 0 ? "In stock" : "Low stock"
        
      },
    );
  }
}