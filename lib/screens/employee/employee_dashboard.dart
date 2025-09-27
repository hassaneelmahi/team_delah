import 'package:admin_coffee/screens/employee/readyorder_page.dart';
import 'package:admin_coffee/services/order_service.dart';
import 'package:admin_coffee/screens/login/coffee_page.dart';
import 'package:flutter/material.dart';
import 'package:admin_coffee/screens/settings/settings_page.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart'; // ✅ NEW
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  late OrderService orderService;
  late Stream<List<dynamic>> orderStream;
  final AudioPlayer _audioPlayer = AudioPlayer(); // ✅ NEW
  int _previousOrderCount = 0; // ✅ NEW
  // Track orders we've optimistically removed from the dashboard after marking ready
  final Set<String> _locallyMarkedReady = <String>{};

  int currentPage = 0;
  static const int ordersPerPage = 8;
  String? coffeeShopName;

  @override
  void initState() {
    super.initState();

    final coffeeShopId = GetStorage().read('coffeeShopId');

    if (coffeeShopId == null ||
        coffeeShopId is! String ||
        coffeeShopId.isEmpty) {
      // يظهر تنبيه ويرجع إلى صفحة تسجيل الدخول
      Future.delayed(Duration.zero, () {
        Get.snackbar(
            "خطأ", "لم يتم العثور على coffeeShopId. يرجى تسجيل الدخول مجددًا.");
        Get.offAll(() => const LoginPage());
      });
      return;
    }

    orderService = OrderService(coffeeShopId);
    orderStream = orderService.getOrderStream();

    // Fetch coffee shop name to show in AppBar
    _fetchCoffeeShopName(coffeeShopId);
  }

  Future<void> _fetchCoffeeShopName(String coffeeShopId) async {
    try {
      final url = Uri.parse(
          'https://delahcoffeebackend-production.up.railway.app/api/coffeeShop');
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        List<dynamic> list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          list = decoded['data'] as List<dynamic>;
        }
        final found = list.firstWhere(
            (c) =>
                c != null && (c['_id']?.toString() == coffeeShopId.toString()),
            orElse: () => null);
        if (found != null) {
          setState(() => coffeeShopName =
              found['name'] ?? found['coffeeShopName'] ?? found['title']);
        }
      }
    } catch (e) {
      // ignore
    }
  }

  // Async handler used by the UI. Optimistically removes the order from the
  // dashboard, calls the backend, and on failure restores it.
  Future<void> _handleMarkAsReady(String orderId) async {
    if (orderId.isEmpty) return;
    // Optimistically mark as ready so it disappears from the list immediately
    setState(() {
      _locallyMarkedReady.add(orderId);
    });
    final updatedOrder = await markOrderAsReady(orderId);
    if (updatedOrder == null) {
      // Revert the optimistic update if the call failed
      setState(() {
        _locallyMarkedReady.remove(orderId);
      });
      Get.snackbar('Error', 'Could not mark order as ready');
      return;
    }

    // On success, navigate to ReadyOrderPage and pass the updated order so it's shown immediately.
    Get.to(() => ReadyOrderPage(initialOrder: updatedOrder));
  }

  void goToNextPage(int totalOrders) {
    final maxPage = (totalOrders / ordersPerPage).ceil() - 1;
    if (currentPage < maxPage) {
      setState(() => currentPage++);
    }
  }

  void goToPreviousPage() {
    if (currentPage > 0) {
      setState(() => currentPage--);
    }
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      print("❌ Error playing sound: $e");
    }
  }

  @override
  void dispose() {
    orderService.closeWebSocket();
    _audioPlayer.dispose(); // ✅ Clean up audio player
    super.dispose();
  }

  Future<void> _performLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    GetStorage().remove('coffeeShopId');
    Get.offAll(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Employee Dashboard"),
            if (coffeeShopName != null)
              Text(
                coffeeShopName!,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF00512D),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const ReadyOrderPage());
              },
              icon: const Icon(Icons.done_all_rounded,
                  size: 20, color: Colors.white),
              label: const Text('Ready Orders',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007244),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          // Popup menu for extra actions
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'refresh':
                    setState(() {});
                    break;
                  case 'settings':
                    Get.to(() => const SettingsPage());
                    break;
                  case 'help':
                    // TODO: show help
                    break;
                  case 'logout':
                    await _performLogout();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'refresh',
                    child: ListTile(
                        leading: Icon(Icons.refresh), title: Text('Refresh'))),
                const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'))),
                const PopupMenuItem(
                    value: 'help',
                    child: ListTile(
                        leading: Icon(Icons.help_outline),
                        title: Text('Help'))),
                const PopupMenuDivider(),
                const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                        leading: Icon(Icons.logout), title: Text('Logout'))),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<dynamic> allOrders = snapshot.data!;
          // Filter out orders we've locally marked as ready so they disappear immediately
          allOrders = allOrders
              .where((o) => !_locallyMarkedReady.contains(o['_id']))
              .toList();
          int totalOrders = allOrders.length;

          // ✅ Play notification if new order received
          if (totalOrders > _previousOrderCount) {
            _playNotificationSound();
          }
          _previousOrderCount = totalOrders;

          // If there are no orders, show a friendly empty state with image and refresh button
          if (totalOrders == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image removed per request; show a simple icon-based empty state
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFFEDEFF0),
                          radius: 70,
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: const Color(0xFF00512D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00512D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'There are currently no pending orders. Relax — new orders will appear here as they come in.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00512D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          int startIndex = currentPage * ordersPerPage;
          int endIndex = startIndex + ordersPerPage;
          List<dynamic> paginatedOrders = allOrders.sublist(
            startIndex,
            endIndex > totalOrders ? totalOrders : endIndex,
          );

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                    itemCount: paginatedOrders.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      var order = paginatedOrders[index];
                      return OrderCardFixedHeight(
                        key: ValueKey(order['_id']),
                        orderId: order['_id'],
                        date: order['createdAt'],
                        clientName: "Client ${startIndex + index + 1}",
                        items: order['orderItems'],
                        onAction: () => _handleMarkAsReady(order['_id']),
                        buttonText: "Mark as Ready",
                      );
                    },
                  ),
                ),
              ),
              if (totalOrders > ordersPerPage)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            currentPage > 0 ? () => goToPreviousPage() : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Previous"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentPage > 0
                              ? const Color(0xFF00512D)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Page ${currentPage + 1} of ${(totalOrders / ordersPerPage).ceil()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF00512D),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed:
                            (currentPage + 1) * ordersPerPage < totalOrders
                                ? () => goToNextPage(totalOrders)
                                : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("Next"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (currentPage + 1) * ordersPerPage < totalOrders
                                  ? const Color(0xFF00512D)
                                  : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class OrderCardFixedHeight extends StatefulWidget {
  final String orderId;
  final String date;
  final String clientName;
  final List<dynamic> items;
  final VoidCallback onAction;
  final String buttonText;

  const OrderCardFixedHeight({
    Key? key,
    required this.orderId,
    required this.date,
    required this.clientName,
    required this.items,
    required this.onAction,
    required this.buttonText,
  }) : super(key: key);

  @override
  State<OrderCardFixedHeight> createState() => _OrderCardFixedHeightState();
}

class _OrderCardFixedHeightState extends State<OrderCardFixedHeight> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollHint = false;
  late Timer _timer;
  Duration _elapsed = Duration.zero;
  late DateTime createdAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScroll());
    _scrollController.addListener(_checkScroll);

    createdAt = DateTime.parse(widget.date).toLocal();
    _elapsed = DateTime.now().difference(createdAt);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(createdAt);
      });
    });
  }

  void _checkScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    setState(() {
      _showScrollHint = maxScroll > 0;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScroll);
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // ✅ Client name and timer on the same row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.clientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "⏱ ${_formatDuration(_elapsed)}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              "ID: ...${widget.orderId.length > 4 ? widget.orderId.substring(widget.orderId.length - 4) : widget.orderId}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                children: [
                  Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    radius: const Radius.circular(8),
                    thickness: 4,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(right: 5),
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        var item = widget.items[index];
                        var product = item['productId'] ?? {};

                        // product['images'] can be in different shapes depending on backend data
                        // (Map with keys 'hot'/'iced', List, or a String). Normalize safely.
                        String imagePath = 'assets/images/default.png';
                        try {
                          final images = product['images'];
                          if (images is Map) {
                            final hot = images['hot'];
                            final iced = images['iced'];
                            if (hot != null && hot.toString().isNotEmpty) {
                              imagePath = hot.toString();
                            } else if (iced != null &&
                                iced.toString().isNotEmpty) {
                              imagePath = iced.toString();
                            }
                          } else if (images is List && images.isNotEmpty) {
                            // assume list of url strings, take first non-empty
                            final firstNonEmpty = images.firstWhere(
                                (e) => e != null && e.toString().isNotEmpty,
                                orElse: () => null);
                            if (firstNonEmpty != null)
                              imagePath = firstNonEmpty.toString();
                          } else if (images is String && images.isNotEmpty) {
                            imagePath = images;
                          }
                        } catch (e) {
                          // fallback already set
                        }

                        return OrderItemWidget(
                          imagePath: imagePath,
                          name: product['name'],
                          quantity: item['quantity'],
                          additives: item['additives'],
                        );
                      },
                    ),
                  ),
                  if (_showScrollHint)
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: widget.onAction,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF00512D),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(widget.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> markOrderAsReady(String orderId) async {
  final url = Uri.parse(
      "https://delahcoffeebackend-production.up.railway.app/api/orders/orders/$orderId/ready");

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("✅ Order marked as ready");
      try {
        final body = response.body;
        final parsed = jsonDecode(body);
        // backend returns { success: true, message: ..., data: order }
        return parsed['data'] != null
            ? Map<String, dynamic>.from(parsed['data'])
            : null;
      } catch (e) {
        return null;
      }
    } else {
      print("❌ Failed to update status: ${response.body}");
      return null;
    }
  } catch (e) {
    print("❌ Error: $e");
    return null;
  }
}

class OrderItemWidget extends StatelessWidget {
  final String imagePath;
  final String name;
  final int quantity;
  final List<dynamic> additives;

  const OrderItemWidget({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.quantity,
    required this.additives,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> extractValues(List<dynamic> additives) {
      List<String> values = [];
      for (var additive in additives) {
        if (additive is Map<String, dynamic> && additive.containsKey("value")) {
          var value = additive["value"];
          if (value is String && value.trim().isNotEmpty) {
            values.add(value.trim());
          } else if (value is Map<String, dynamic>) {
            values.addAll(value.values.map((v) => v.toString().trim()));
          }
        }
      }
      return values;
    }

    List<String> additiveValues = extractValues(additives);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                if (additiveValues.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Wrap(
                      spacing: 4.0,
                      runSpacing: 2.0,
                      children: additiveValues.map((additive) {
                        return Chip(
                          label: Text(
                            additive,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white),
                          ),
                          backgroundColor:
                              const Color(0xFF00512D).withOpacity(0.8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            "x$quantity",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
