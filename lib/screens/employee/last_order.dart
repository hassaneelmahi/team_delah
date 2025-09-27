import 'package:admin_coffee/theme/app_color.dart';
import 'package:flutter/material.dart';

class LastOrderPage extends StatefulWidget {
  const LastOrderPage({Key? key}) : super(key: key);

  @override
  State<LastOrderPage> createState() => _LastOrderPageState();
}

class _LastOrderPageState extends State<LastOrderPage> {
  final List<Map<String, dynamic>> lastOrders = [
    // Sample orders
    for (int i = 1; i <= 30; i++) // Generate 30 orders for demonstration
      {
        'orderNumber': i,
        'date': "01 Nov 2023, 03:30 PM",
        'items': [
          OrderItem(
            imageUrl: 'assets/images/p2.png',
            name: 'Item $i Name',
            type: 'Hot',
            price: 4.50,
            quantity: 1,
          ),
          OrderItem(
            imageUrl: 'assets/images/p3.png',
            name: 'Item $i Second Name',
            type: 'Food',
            price: 2.75,
            quantity: 1,
          ),
        ],
      }
  ];

  int itemsPerPage = 6; // Number of items to display per page
  int currentPage = 1; // Current page

  List<Map<String, dynamic>> getCurrentPageOrders() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(0, lastOrders.length);
    return lastOrders.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentOrders = getCurrentPageOrders();
    int totalPages = (lastOrders.length / itemsPerPage).ceil();

    return Scaffold(
      backgroundColor: AppColors.text,
      appBar: AppBar(
        title: const Text(
          "Last Orders",
          style: TextStyle(color: AppColors.text),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        toolbarHeight: 80.0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.99,
                children: currentOrders.map((order) {
                  return OrderCard(
                    orderNumber: order['orderNumber'],
                    date: order['date'],
                    items: order['items'],
                  );
                }).toList(),
              ),
            ),
          ),
          _buildPaginationControls(totalPages),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${((currentPage - 1) * itemsPerPage) + 1}-${(currentPage * itemsPerPage).clamp(0, lastOrders.length)} of ${lastOrders.length} orders",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                onPressed: currentPage > 1
                    ? () {
                        setState(() {
                          currentPage--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_back_ios),
                color: currentPage > 1 ? Colors.black : Colors.grey,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "$currentPage",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: currentPage < totalPages
                    ? () {
                        setState(() {
                          currentPage++;
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward_ios),
                color: currentPage < totalPages ? Colors.black : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final int orderNumber;
  final String date;
  final List<OrderItem> items;

  const OrderCard({
    Key? key,
    required this.orderNumber,
    required this.date,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order #$orderNumber",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children:
                  items.map((item) => OrderItemWidget(item: item)).toList(),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'x${items.length} Items',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderItem {
  final String imageUrl;
  final String name;
  final String type;
  final double price;
  final int quantity;

  OrderItem({
    required this.imageUrl,
    required this.name,
    required this.type,
    required this.price,
    required this.quantity,
  });
}

class OrderItemWidget extends StatelessWidget {
  final OrderItem item;

  const OrderItemWidget({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${item.type}...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Qty: ${item.quantity}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
