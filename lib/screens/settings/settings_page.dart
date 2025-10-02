import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  bool is24Hours = false;
  bool notificationsEnabled = true;

  // Products management
  List<dynamic> products = [];
  bool productsLoading = false;
  // search/filter
  final TextEditingController productSearchController = TextEditingController();
  String productFilter = '';
  // per-product toggling/loading state
  Map<String, bool> toggling = {};
  // local overrides for availability when backend doesn't return per-shop flags
  Map<String, bool> availabilityOverrides = {};

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    // Load any saved settings
    final o = box.read('shopOpeningTime');
    final c = box.read('shopClosingTime');
    final s = box.read('shopIs24Hours');
    final n = box.read('shopNotifications');
    if (o is String) openingTime = _timeOfDayFromString(o);
    if (c is String) closingTime = _timeOfDayFromString(c);
    if (s is bool) is24Hours = s;
    if (n is bool) notificationsEnabled = n;

    // load persisted availability overrides so UI keeps toggled state across refreshes
    try {
      final stored = box.read('availabilityOverrides');
      if (stored is Map) {
        availabilityOverrides = stored
            .map<String, bool>((k, v) => MapEntry(k.toString(), v == true));
      }
    } catch (_) {}

    // attempt to load products for this coffee shop
    final coffeeShopId = box.read('coffeeShopId');
    if (coffeeShopId != null && coffeeShopId is String) {
      _loadProducts(coffeeShopId);
    }
  }

  TimeOfDay _timeOfDayFromString(String s) {
    final parts = s.split(":");
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: h, minute: m);
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String _timeToString(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickOpening() async {
    final now = TimeOfDay.now();
    final picked =
        await showTimePicker(context: context, initialTime: openingTime ?? now);
    if (picked != null) setState(() => openingTime = picked);
  }

  Future<void> _pickClosing() async {
    final now = TimeOfDay.now();
    final picked =
        await showTimePicker(context: context, initialTime: closingTime ?? now);
    if (picked != null) setState(() => closingTime = picked);
  }

  Future<void> _save() async {
    if (openingTime != null)
      box.write('shopOpeningTime', _timeToString(openingTime!));
    if (closingTime != null)
      box.write('shopClosingTime', _timeToString(closingTime!));
    box.write('shopIs24Hours', is24Hours);
    box.write('shopNotifications', notificationsEnabled);

    // Also attempt to persist to backend if coffeeShopId is available
    final coffeeShopId = box.read('coffeeShopId');
    if (coffeeShopId != null && coffeeShopId is String) {
      final payload = <String, dynamic>{};
      if (openingTime != null)
        payload['openingTime'] = _timeToString(openingTime!);
      if (closingTime != null)
        payload['closingTime'] = _timeToString(closingTime!);
      payload['is24Hours'] = is24Hours;

      try {
        final url = Uri.parse(
            'https://delahcoffeebackend-production.up.railway.app/api/coffeeShop/$coffeeShopId');
        final resp = await http.put(url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload));
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          final updated = data['data'] ?? data;
          if (updated is Map) {
            if (updated['openingTime'] != null)
              box.write('shopOpeningTime', updated['openingTime']);
            if (updated['closingTime'] != null)
              box.write('shopClosingTime', updated['closingTime']);
            if (updated['is24Hours'] != null)
              box.write('shopIs24Hours', updated['is24Hours']);
          }
          Get.snackbar('Saved', 'Settings saved to server',
              snackPosition: SnackPosition.BOTTOM);
          return;
        } else {
          Get.snackbar('Warning', 'Saved locally but failed to update server',
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        Get.snackbar('Warning', 'Saved locally but failed to update server',
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar('Saved', 'Settings saved locally',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _loadProducts(String coffeeShopId) async {
    setState(() => productsLoading = true);
    try {
      // Use categories_with_products which returns all products and exposes per-shop isAvailable
      final url = Uri.parse(
          'https://delahcoffeebackend-production.up.railway.app/api/products/categories_with_products?coffeeShopId=$coffeeShopId&includeSoldOut=true');
      final resp =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        // server returns { categories: [ { products: [...] }, ... ] }
        List items = [];
        try {
          if (data is Map && data['categories'] is List) {
            for (final c in data['categories']) {
              if (c is Map && c['products'] is List) {
                items.addAll(c['products']);
              }
            }
          } else if (data is List) {
            // fallback: if API returned a flat list
            items = data;
          } else if (data is Map && data['products'] is List) {
            items = data['products'];
          }
        } catch (_) {
          items = [];
        }
        final normalized = items.map<Map>((e) {
          if (e is Map) {
            final copy = Map.of(e);
            copy['isAvailable'] = _productIsAvailable(copy);
            return copy;
          }
          return (e as Map);
        }).toList();
        // apply any local overrides so UI reflects recent toggles even if server doesn't
        try {
          for (var p in normalized) {
            final id = (p['_id'] ?? p['id'] ?? p['productId'])?.toString();
            if (id != null && availabilityOverrides.containsKey(id)) {
              p['isAvailable'] = availabilityOverrides[id];
            }
          }
        } catch (_) {}
        // Debug: log what we received and which items are marked unavailable
        try {
          print(
              'SettingsPage._loadProducts: coffeeShopId=$coffeeShopId fetched ${items.length} items');
          final unavailable =
              normalized.where((e) => (e['isAvailable'] == false)).toList();
          print(
              'SettingsPage._loadProducts: unavailable count=${unavailable.length}');
          if (unavailable.isNotEmpty) {
            print(
                'SettingsPage._loadProducts: unavailable ids=${unavailable.map((e) => e['_id'] ?? e['id'] ?? e['productId']).toList()}');
          } else {
            // when none are unavailable, print a truncated sample of the raw response to inspect server payload
            try {
              final raw = resp.body;
              final t = raw.length > 1500
                  ? raw.substring(0, 1500) + '... (truncated)'
                  : raw;
              print('SettingsPage._loadProducts: raw response (truncated): $t');
            } catch (_) {}
          }
        } catch (_) {}
        setState(() => products = normalized);
      } else {
        setState(() => products = []);
        Get.snackbar('Error', 'Failed to load products (${resp.statusCode})',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      setState(() => products = []);
      Get.snackbar('Error', 'Failed to load products',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => productsLoading = false);
    }
  }

  String? _getProductImage(dynamic images) {
    try {
      if (images == null) return null;
      if (images is String && images.isNotEmpty) return images;
      if (images is List && images.isNotEmpty) {
        final first = images.first;
        if (first is String) return first;
        if (first is Map)
          return first['url'] ??
              first.values.firstWhere((v) => v is String, orElse: () => null);
      }
      if (images is Map) {
        // try common keys
        if (images['hot'] is String) return images['hot'];
        if (images['iced'] is String) return images['iced'];
        // fallback to first string value
        final val =
            images.values.firstWhere((v) => v is String, orElse: () => null);
        if (val is String) return val;
      }
    } catch (e) {}
    return null;
  }

  // Normalize/interpret availability from different backend fields
  bool _productIsAvailable(Map p) {
    try {
      // Support nested availability maps per coffeeShopId
      final coffeeShopId = box.read('coffeeShopId');
      if (coffeeShopId != null) {
        if (p.containsKey('availability')) {
          final av = p['availability'];
          if (av is Map) {
            // keyed by shop id
            final v = av[coffeeShopId] ?? av[coffeeShopId.toString()];
            if (v is bool) return v;
            // sometimes availability map stores objects with isAvailable
            if (v is Map && v['isAvailable'] is bool) return v['isAvailable'];
          }
        }
      }
      if (p.containsKey('isAvailable')) {
        final v = p['isAvailable'];
        if (v is bool) return v;
      }
      if (p.containsKey('is_available')) {
        final v = p['is_available'];
        if (v is bool) return v;
      }
      // Some APIs return isSoldOut boolean (true = sold out)
      if (p.containsKey('isSoldOut')) {
        final v = p['isSoldOut'];
        if (v is bool) return !v;
      }
      if (p.containsKey('is_sold_out')) {
        final v = p['is_sold_out'];
        if (v is bool) return !v;
      }
      // fallback to available if no clear flag
      return true;
    } catch (e) {
      return true;
    }
  }

  Widget _availabilityButton({
    required bool isAvailable,
    required bool isToggling,
    required VoidCallback onPressed,
    bool compact = false,
  }) {
    // professional styles
    final borderRadius = BorderRadius.circular(12.0);
    final buttonHeight = 42.0;
    final textStyle = const TextStyle(
        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600);

    if (isToggling) {
      // compact disabled state with spinner
      final color = isAvailable ? Colors.red.shade600 : Colors.green.shade600;
      return Container(
        height: buttonHeight,
        padding: compact ? const EdgeInsets.symmetric(horizontal: 8) : null,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              ),
              if (!compact) const SizedBox(width: 10),
              if (!compact)
                const Text('Updating…', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    // action button
    final actionColor =
        isAvailable ? Colors.red.shade600 : Colors.green.shade600;
    final icon =
        isAvailable ? Icons.remove_shopping_cart : Icons.check_circle_outline;
    final label = isAvailable ? 'Sold out' : 'Make available';

    return Material(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.12),
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Ink(
          height: buttonHeight,
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 8)
              : const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: actionColor,
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              if (!compact) const SizedBox(width: 10),
              if (!compact)
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(label, style: textStyle),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleSoldOut(Map product) async {
    final coffeeShopId = box.read('coffeeShopId');
    if (coffeeShopId == null || coffeeShopId is! String) {
      Get.snackbar('Error', 'Coffee shop not set',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final prodId = product['_id'] ?? product['id'] ?? product['productId'];
    if (prodId == null) return;

    // current availability as seen by client
    final currentAvailable =
        (product['isAvailable'] ?? product['is_available'] ?? true) as bool;
    final newAvailable = !currentAvailable; // toggle
    final soldOutParam = !newAvailable; // soldOut=true -> isAvailable=false

    final prodKey = prodId.toString();
    // include backend auth token (vendor/admin). Require it to avoid 401.
    final token = box.read('token');
    if (token == null || token is! String || token.isEmpty) {
      Get.snackbar('Not authenticated',
          'No backend token found. Please login as vendor/admin before changing availability',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      // mark this product as toggling
      setState(() => toggling[prodKey] = true);
      final url = Uri.parse(
          'https://delahcoffeebackend-production.up.railway.app/api/products/$prodId/soldout');
      final body =
          jsonEncode({'soldOut': soldOutParam, 'coffeeShopId': coffeeShopId});
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final resp = await http.patch(url, headers: headers, body: body);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final updated = data['product'] ?? data['data'] ?? data;
        // Debug: log server response for toggle
        try {
          print('SettingsPage._toggleSoldOut: server response: ${resp.body}');
        } catch (_) {}
        // update local list
        // ensure updated has normalized isAvailable flag for UI
        try {
          if (updated is Map) {
            // normalize existing server value
            updated['isAvailable'] = _productIsAvailable(updated);
            // force toggled state so UI updates immediately
            updated['isAvailable'] = newAvailable;

            // update nested availability map for this coffeeShopId if present
            try {
              final shopId = coffeeShopId;
              final av = updated['availability'];
              if (av is Map) {
                av[shopId] = newAvailable;
                av[shopId.toString()] = newAvailable;
              } else {
                updated['availability'] = {
                  shopId: newAvailable,
                  shopId.toString(): newAvailable
                };
              }
            } catch (_) {}
          }
        } catch (_) {}
        setState(() {
          final idx = products.indexWhere((p) {
            final idp = p['_id'] ?? p['id'] ?? p['productId'];
            return idp != null &&
                prodId != null &&
                idp.toString() == prodId.toString();
          });
          if (idx >= 0) products[idx] = updated;
          // set a local override so UI shows the toggled availability immediately
          try {
            availabilityOverrides[prodKey] = newAvailable;
            // persist overrides
            try {
              box.write('availabilityOverrides', availabilityOverrides);
            } catch (_) {}
          } catch (_) {}
        });
        Get.snackbar('Success', 'Product availability updated',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        String msg = 'Failed to update product (${resp.statusCode})';
        try {
          print('SettingsPage._toggleSoldOut: error response: ${resp.body}');
        } catch (_) {}
        try {
          final parsed = jsonDecode(resp.body);
          // prefer explicit message fields if available
          if (parsed is Map && parsed['message'] != null) {
            msg = parsed['message'].toString();
          } else {
            msg = resp.body.toString();
          }
        } catch (_) {
          msg = resp.body.toString();
        }
        Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      // clear toggling state for this product
      setState(() => toggling[prodKey] = false);
    }
  }

  void _resetToDefaults() {
    setState(() {
      openingTime = const TimeOfDay(hour: 9, minute: 0);
      closingTime = const TimeOfDay(hour: 18, minute: 0);
      is24Hours = false;
      notificationsEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Button style palette
    final Color primary = const Color(0xFF00512D);
    final ButtonStyle primaryButton = ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 6,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
      minimumSize: const Size(120, 44),
    );

    final ButtonStyle smallButton = ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      minimumSize: const Size(72, 36),
    );

    final ButtonStyle outlinedWhite = OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.white.withOpacity(0.12)),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00512D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            const Text('Business hours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Opening time'),
              subtitle: Text(openingTime != null
                  ? _timeToString(openingTime!)
                  : 'Not set'),
              trailing: ElevatedButton(
                onPressed: _pickOpening,
                style: smallButton,
                child: const Text('Change'),
              ),
            ),
            ListTile(
              title: const Text('Closing time'),
              subtitle: Text(closingTime != null
                  ? _timeToString(closingTime!)
                  : 'Not set'),
              trailing: ElevatedButton(
                onPressed: _pickClosing,
                style: smallButton,
                child: const Text('Change'),
              ),
            ),
            SwitchListTile(
              title: const Text('24-hour format'),
              value: is24Hours,
              onChanged: (v) => setState(() => is24Hours = v),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Enable notifications'),
              value: notificationsEnabled,
              onChanged: (v) => setState(() => notificationsEnabled = v),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Other',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text('Clear cached data'),
              trailing: ElevatedButton.icon(
                onPressed: () {
                  box.erase();
                  Get.snackbar('Cleared', 'Local cache cleared',
                      snackPosition: SnackPosition.BOTTOM);
                },
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.white),
                label:
                    const Text('Clear', style: TextStyle(color: Colors.white)),
                style: smallButton,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Products',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () {
                    final coffeeShopId = box.read('coffeeShopId');
                    if (coffeeShopId != null && coffeeShopId is String) {
                      _loadProducts(coffeeShopId);
                    } else {
                      Get.snackbar('Error', 'No coffee shop selected',
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh products'),
                  style: smallButton,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // search input for products
            TextField(
              controller: productSearchController,
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: productFilter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          productSearchController.clear();
                          setState(() => productFilter = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) =>
                  setState(() => productFilter = v.trim().toLowerCase()),
            ),
            const SizedBox(height: 8),
            productsLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('No products found for this coffee shop.'),
                      )
                    : Column(
                        children: products.where((p) {
                          if (productFilter.isEmpty) return true;
                          final name = (p['name'] ?? p['title'] ?? '')
                              .toString()
                              .toLowerCase();
                          final id =
                              (p['_id'] ?? p['id'] ?? p['productId'] ?? '')
                                  .toString()
                                  .toLowerCase();
                          return name.contains(productFilter) ||
                              id.contains(productFilter);
                        }).map<Widget>((p) {
                          final id = p['_id'] ?? p['id'] ?? p['productId'];
                          final name = p['name'] ?? p['title'] ?? 'Unnamed';
                          final img = _getProductImage(p['images']);
                          final isAvailable = _productIsAvailable(p as Map);
                          // keep local normalized flag
                          try {
                            p['isAvailable'] = isAvailable;
                          } catch (_) {}

                          return ListTile(
                            key: ValueKey(id),
                            leading: img != null
                                ? Image.network(img,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.local_cafe))
                                : const Icon(Icons.local_cafe),
                            title: Text(name),
                            subtitle: Text(
                                '${id != null ? id.toString() : ''}${isAvailable ? '' : ' — Sold out'}'),
                            trailing: LayoutBuilder(
                              builder: (context, constraints) {
                                final useCompact = constraints.maxWidth < 120;
                                return _availabilityButton(
                                  isAvailable: isAvailable,
                                  isToggling:
                                      toggling[(id ?? '').toString()] == true,
                                  compact: useCompact,
                                  onPressed: () => _toggleSoldOut(p),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Save settings',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                    style: primaryButton,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _resetToDefaults,
                  style: outlinedWhite,
                  child: const Text('Defaults',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
