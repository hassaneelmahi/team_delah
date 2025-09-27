import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class OrderService {
  final String baseUrl =
      "https://delahcoffeebackend-production.up.railway.app/api/orders";

  late final WebSocketChannel channel;

  OrderService(String coffeeShopId) {
    channel = IOWebSocketChannel.connect(
      "wss://delahcoffeebackend-production.up.railway.app/orders/ws",
    );

    // Send coffeeShopId once connected
    channel.sink.add(jsonEncode({
      "coffeeShopId": coffeeShopId,
    }));
  }

  Stream<List<dynamic>> getOrderStream() {
    return channel.stream.map((event) {
      print("📩 WebSocket raw event: $event");

      try {
        final decoded = jsonDecode(event);

        if (decoded is Map && decoded.containsKey('orders')) {
          final List<dynamic> allOrders = decoded['orders'] ?? [];
          print("✅ Orders received from backend: $allOrders");
          return allOrders;
        }

        print("⚠️ Unexpected format from backend: $decoded");
        return <dynamic>[]; // Safe fallback
      } catch (e) {
        print("❌ Error parsing WebSocket data: $e");
        return <dynamic>[];
      }
    });
  }

  void closeWebSocket() {
    channel.sink.close();
  }
}
