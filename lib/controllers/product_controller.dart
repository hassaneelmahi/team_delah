import 'package:get/get.dart';

class ProductController extends GetxController{
   Future<List<Map<String, dynamic>>> fetchData() async {
    return List.generate(
      5,
      (index) => {
        'productName': 'Product $index',
        'stock': '${(index + 1) * 20} units',
        'price': '\$${(index + 1) * 100}',
        'sku': 'SKU${(index + 1000) }',
        'category' : 'Category $index'
        
      },
    );
  }
}