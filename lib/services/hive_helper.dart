import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  static const String productBoxName = 'products';
  static Box<Map<String, dynamic>>? _productBox;

  static Box<Map<String, dynamic>> get _box {
    final box = _productBox;
    if (box == null) {
      throw StateError('HiveHelper belum diinisialisasi. Panggil HiveHelper.init() terlebih dahulu.');
    }
    return box;
  }

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    _productBox = await Hive.openBox<Map<String, dynamic>>(productBoxName);
  }

  static bool get isInitialized => _productBox != null;

  static String _extractId(Map<String, dynamic> product) {
    final id = product['id'];
    if (id == null) {
      throw ArgumentError.value(product, 'product', 'Produk harus memiliki properti "id".');
    }
    return id.toString();
  }

  // Insert product
  static Future<void> insertProduct(Map<String, dynamic> product) async {
    final id = _extractId(product);
    await _box.put(id, product);
  }

  // Get all products
  static List<Map<String, dynamic>> getAllProducts() {
    return _box.values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  // Get product by ID
  static Map<String, dynamic>? getProductById(String id) {
    return _box.get(id);
  }

  // Update product
  static Future<void> updateProduct(Map<String, dynamic> product) async {
    final id = _extractId(product);
    await _box.put(id, product);
  }

  // Delete product
  static Future<void> deleteProduct(String id) async {
    await _box.delete(id);
  }

  // Delete all products
  static Future<void> deleteAllProducts() async {
    await _box.clear();
  }

  // Get product count
  static int getProductCount() {
    return _box.length;
  }
}
