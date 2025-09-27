import 'package:get/get.dart';

class CustomerController extends GetxController {
  Future<List<Map<String, dynamic>>> fetchData() async {
    return List.generate(
        5,
        (index) => {
              'customerId': 'CUS${(index + 1000)}',
              'customerName': 'Customer $index',
              'email': 'customer$index@example.com',
              'totalOrders': (index + 1) * 5,
              'status': index % 2 == 0 ? "Active" : "Inactive",
            });
  }
}
