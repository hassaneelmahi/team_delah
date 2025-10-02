import 'package:admin_coffee/screens/login/coffee_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'employee_dashboard.dart'; // لإعادة استخدام OrderCardFixedHeight

class ReadyOrderPage extends StatefulWidget {
  final Map<String, dynamic>? initialOrder;

  const ReadyOrderPage({Key? key, this.initialOrder}) : super(key: key);

  @override
  State<ReadyOrderPage> createState() => _ReadyOrderPageState();
}

class _ReadyOrderPageState extends State<ReadyOrderPage> {
  List<dynamic> readyOrders = [];
  bool isLoading = true;
  String? coffeeShopId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If the page was pushed with an initialOrder, make sure it's shown
    if (widget.initialOrder != null) {
      final order = widget.initialOrder!;
      if (!readyOrdersContains(order)) {
        setState(() {
          readyOrders.insert(0, order);
        });
      }
    }
  }

  bool readyOrdersContains(Map<String, dynamic> order) {
    return readyOrders.any((o) => o['_id'] == order['_id']);
  }

//==================
  void _initializeAndFetch() {
    final box = GetStorage();
    coffeeShopId = box.read('coffeeShopId');

    if (coffeeShopId == null || coffeeShopId!.isEmpty) {
      // Use WidgetsBinding to schedule snackbar after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "Authentication Error",
          "Could not find your coffee shop ID. Please log in again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.offAll(() => const LoginPage());
      });
      setState(() => isLoading = false);
    } else {
      print("🔎 ReadyOrderPage: coffeeShopId=$coffeeShopId");
      fetchReadyOrders();
    }
  }

  Future<void> fetchReadyOrders() async {
    if (coffeeShopId == null) {
      setState(() => isLoading = false);
      return;
    }
    // Correctly construct the URL with the coffeeShopId as a query parameter
    final url = Uri.parse(
        "https://delahcoffeebackend-production.up.railway.app/api/orders/ready?coffeeShopId=$coffeeShopId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔁 ReadyOrderPage response body: ${response.body}');
        setState(() {
          readyOrders = data["data"] ?? [];
          isLoading = false;
        });
      } else {
        print("❌ Failed to fetch ready orders: ${response.body}");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('Error', 'Failed to fetch ready orders');
        });
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching ready orders: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> markOrderAsDelivered(String orderId) async {
    final url = Uri.parse(
        "https://delahcoffeebackend-production.up.railway.app/api/orders/orders/mark-delivered");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"orderId": orderId}),
      );

      print("======================Sending orderId: $orderId");

      if (response.statusCode == 200) {
        print("✅ Order marked as Delivered");
        // Remove from list and refresh UI
        setState(() {
          readyOrders.removeWhere((order) => order['_id'] == orderId);
        });
      } else {
        print("❌ Failed to update status: ${response.body}");
      }
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ready Orders"),
        backgroundColor: const Color(0xFF00512D),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Search field to filter by the trailing characters of order ID
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by last characters of order ID',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        _searchQuery = v.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // Show helpful empty state when there are no ready orders at all
                  if (readyOrders.isEmpty)
                    const Expanded(
                        child: Center(child: Text("No Ready Orders Found")))
                  else
                    // Filtered grid
                    Expanded(
                      child: Builder(builder: (context) {
                        final List<dynamic> filtered = _searchQuery.isEmpty
                            ? readyOrders
                            : readyOrders.where((order) {
                                final id = order['_id']?.toString() ?? '';
                                return id.endsWith(_searchQuery);
                              }).toList();

                        if (filtered.isEmpty) {
                          return const Center(
                              child: Text('No matching orders'));
                        }

                        return GridView.builder(
                          itemCount: filtered.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) {
                            var order = filtered[index];
                            return OrderCardFixedHeight(
                              key: ValueKey(order['_id']),
                              orderId: order['_id'],
                              date: order['createdAt'],
                              clientName: "Client ${index + 1}",
                              items: order['orderItems'],
                              onAction: () =>
                                  markOrderAsDelivered(order['_id']),
                              buttonText: "Delivered",
                            );
                          },
                        );
                      }),
                    ),
                ],
              ),
            ),
    );
  }
}
