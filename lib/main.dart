import 'package:flutter/material.dart';
import 'screens/database_debug_screen.dart';
import 'services/hive_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  runApp(const MyApp());
}

const eigerBrandColor = Color(0xFFd84a1c);

class EigerProduct {
  final String id;
  final String name;
  final String category;
  final String price;
  final String oldPrice;
  final String description;
  final int rating;
  final IconData icon;
  final String imageUrl;

  const EigerProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.oldPrice,
    required this.description,
    required this.rating,
    required this.icon,
    required this.imageUrl,
  });
}

const products = [
  EigerProduct(
    id: 'p1',
    name: 'Trocadero Azteca 2.0',
    category: 'Sandal',
    price: 'Rp 142.350',
    oldPrice: 'Rp 219.000',
    description:
        'Sandal outdoor ringan dengan sol anti slip dan bantalan lembut untuk aktivitas sehari-hari.',
    rating: 5,
    icon: Icons.directions_walk,
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80',
  ),
  EigerProduct(
    id: 'p2',
    name: 'Kinkajou 3.5',
    category: 'Sandal',
    price: 'Rp 148.850',
    oldPrice: 'Rp 229.000',
    description:
        'Sandal hiking breathable dengan desain modern dan ketahanan air ringan.',
    rating: 4,
    icon: Icons.hiking,
    imageUrl:
        'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=900&q=80',
  ),
  EigerProduct(
    id: 'p3',
    name: 'Safar Low Cut',
    category: 'Sepatu',
    price: 'Rp 148.850',
    oldPrice: 'Rp 229.000',
    description:
        'Sepatu gunung low cut dengan bantalan nyaman dan traksi kuat untuk permukaan berbatu.',
    rating: 5,
    icon: Icons.sports_martial_arts,
    imageUrl:
        'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=900&q=80',
  ),
  EigerProduct(
    id: 'p4',
    name: 'Caldera Men 2.0',
    category: 'Sandal',
    price: 'Rp 559.200',
    oldPrice: 'Rp 699.000',
    description:
        'Sandal crossover dengan strap empuk dan sol fleksibel untuk kegiatan santai.',
    rating: 5,
    icon: Icons.waving_hand,
    imageUrl:
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80',
  ),
  EigerProduct(
    id: 'p5',
    name: 'Junior Mini Tigerpaw',
    category: 'Anak',
    price: 'Rp 239.250',
    oldPrice: 'Rp 319.000',
    description: 'Sandal anak yang tangguh dan ringan dengan desain playful.',
    rating: 4,
    icon: Icons.child_care,
    imageUrl:
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=900&q=80',
  ),
];

const categories = ['Semua', 'Pria', 'Wanita', 'Anak', 'Equipment'];

class OrderItem {
  final EigerProduct product;
  final int quantity;

  const OrderItem({required this.product, required this.quantity});
}

class Order {
  final String id;
  final List<OrderItem> items;
  final String paymentMethod;
  final int totalPrice;
  final DateTime createdAt;
  final String status;

  const Order({
    required this.id,
    required this.items,
    required this.paymentMethod,
    required this.totalPrice,
    required this.createdAt,
    required this.status,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eiger Adventure',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        primaryColor: eigerBrandColor,
        colorScheme: ColorScheme.fromSeed(seedColor: eigerBrandColor),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final Map<String, int> _cartItems = {};
  final List<Order> _orders = [];

  void _onNavSelected(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _selectedCategory = 'Semua';
      }
    });
  }

  void _addToCart(EigerProduct product) {
    setState(() {
      _cartItems[product.id] = (_cartItems[product.id] ?? 0) + 1;
    });
  }

  void _updateCartQuantity(EigerProduct product, int delta) {
    setState(() {
      final currentQuantity = _cartItems[product.id] ?? 0;
      final nextQuantity = currentQuantity + delta;
      if (nextQuantity <= 0) {
        _cartItems.remove(product.id);
      } else {
        _cartItems[product.id] = nextQuantity;
      }
    });
  }

  void _removeFromCart(EigerProduct product) {
    setState(() {
      _cartItems.remove(product.id);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  int get _cartCount => _cartItems.values.fold(0, (sum, item) => sum + item);

  void _placeOrder(List<Tuple> cartItems, String paymentMethod) {
    if (cartItems.isEmpty) {
      return;
    }

    final totalPrice = cartItems.fold<int>(0, (sum, item) {
      final numericPrice = int.parse(
        item.product.price.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      return sum + (numericPrice * item.quantity);
    });

    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      items: cartItems
          .map(
            (item) => OrderItem(product: item.product, quantity: item.quantity),
          )
          .toList(),
      paymentMethod: paymentMethod,
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
      status: 'Dikirim',
    );

    setState(() {
      _orders.add(order);
      _cartItems.clear();
    });
  }

  List<EigerProduct> get _visibleProducts {
    final normalizedQuery = _searchQuery.toLowerCase();
    return products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          product.category == _selectedCategory ||
          (_selectedCategory == 'Pria' && product.category == 'Sepatu') ||
          (_selectedCategory == 'Wanita' && product.category == 'Sandal');
      final matchesSearch =
          normalizedQuery.isEmpty ||
          product.name.toLowerCase().contains(normalizedQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Eiger Adventure'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 26),
              if (_cartCount > 0)
                Positioned(
                  right: 0,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_cartCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: eigerBrandColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari produk, kategori atau promo...',
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            selectedColor: eigerBrandColor,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
            ),
            onSelected: (_) => setState(() => _selectedCategory = category),
          );
        },
      ),
    );
  }

  Widget _buildFlashSale() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flash Sale',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(216, 74, 28, 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(product.icon, color: eigerBrandColor),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Diskon 25%',
                              style: TextStyle(
                                color: eigerBrandColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: eigerBrandColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.oldPrice,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 250,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: _visibleProducts.length,
        itemBuilder: (context, index) {
          final product = _visibleProducts[index];
          return _ProductCard(
            product: product,
            onAdd: () => _addToCart(product),
          );
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          _buildFlashSale(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Populer Untukmu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _buildProductGrid(),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryChips(),
        Expanded(
          child: _visibleProducts.isEmpty
              ? const Center(
                  child: Text(
                    'Produk tidak ditemukan.',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 250,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: _visibleProducts.length,
                  itemBuilder: (context, index) {
                    final product = _visibleProducts[index];
                    return _ProductCard(
                      product: product,
                      onAdd: () => _addToCart(product),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCartTab() {
    final cartProductList = _cartItems.entries.map((entry) {
      final product = products.firstWhere((product) => product.id == entry.key);
      return Tuple(product, entry.value);
    }).toList();

    final totalPrice = cartProductList.fold<double>(0, (sum, item) {
      final numericPrice = double.parse(
        item.product.price.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      return sum + numericPrice * item.quantity;
    });

    return cartProductList.isEmpty
        ? const Center(
            child: Text(
              'Keranjang belanja Anda kosong.',
              style: TextStyle(color: Colors.black54),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar belanja',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _cartItems.isEmpty ? null : _clearCart,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Kosongkan'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: cartProductList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartProductList[index];
                      return CartItemCard(
                        product: item.product,
                        quantity: item.quantity,
                        onIncrease: () => _updateCartQuantity(item.product, 1),
                        onDecrease: () => _updateCartQuantity(item.product, -1),
                        onRemove: () => _removeFromCart(item.product),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: eigerBrandColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaymentPage(
                            cartItems: cartProductList,
                            onPlaceOrder: _placeOrder,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: eigerBrandColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Checkout Sekarang'),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Akun Saya',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: eigerBrandColor,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text('Eiger Customer'),
                subtitle: const Text('Loyal shopper'),
                trailing: Text(
                  'Gold',
                  style: TextStyle(
                    color: eigerBrandColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pengaturan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _ProfileOption(icon: Icons.location_on, label: 'Alamat Pengiriman'),
            _ProfileOption(icon: Icons.payment, label: 'Metode Pembayaran'),
            _ProfileOption(
              icon: Icons.history,
              label: 'Riwayat Pemesanan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderHistoryPage(orders: _orders),
                  ),
                );
              },
            ),
            _ProfileOption(
              icon: Icons.local_shipping,
              label: 'Pemantauan Pesanan',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderTrackingPage()),
                );
              },
            ),
            _ProfileOption(
              icon: Icons.support_agent,
              label: 'Bantuan & Layanan',
            ),
            _ProfileOption(
              icon: Icons.info_outline,
              label: 'Tentang Eiger Adventure',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Developer Tools',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _ProfileOption(
              icon: Icons.storage,
              label: 'Database Debug',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DatabaseDebugScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widgets = [
      _buildHomeTab(),
      _buildCategoriesTab(),
      _buildCartTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      appBar: _buildAppBar(),
      body: widgets[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: eigerBrandColor,
        unselectedItemColor: Colors.black54,
        onTap: _onNavSelected,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final EigerProduct product;
  final VoidCallback onAdd;

  const _ProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product, onAdd: onAdd),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color.fromRGBO(216, 74, 28, 0.14),
                    child: Center(
                      child: Icon(
                        product.icon,
                        size: 56,
                        color: eigerBrandColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.category,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: eigerBrandColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.oldPrice,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: eigerBrandColor,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tambah'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final EigerProduct product;
  final VoidCallback onAdd;

  const ProductDetailPage({
    required this.product,
    required this.onAdd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                product.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: const Color.fromRGBO(216, 74, 28, 0.14),
                  child: Center(
                    child: Icon(product.icon, size: 92, color: eigerBrandColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.category,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              product.price,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: eigerBrandColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.oldPrice,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black45,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: List.generate(
                product.rating,
                (index) =>
                    const Icon(Icons.star, color: Colors.amber, size: 20),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Deskripsi Produk',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              product.description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onAdd();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: eigerBrandColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Tambah ke Keranjang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final EigerProduct product;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            product.imageUrl,
            height: 52,
            width: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(216, 74, 28, 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(product.icon, color: eigerBrandColor, size: 28),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              product.price,
              style: const TextStyle(
                color: eigerBrandColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  onPressed: onDecrease,
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: eigerBrandColor,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: eigerBrandColor,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ProfileOption({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: eigerBrandColor),
        title: Text(label),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.black45,
        ),
      ),
    );
  }
}

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TrackingStep(
        title: 'Pesanan Dibuat',
        subtitle: 'Pembayaran berhasil dan pesanan sedang dipersiapkan.',
        isCompleted: true,
      ),
      _TrackingStep(
        title: 'Sedang Diproses',
        subtitle: 'Tim kami sedang menyiapkan paket untuk pengiriman.',
        isCompleted: true,
      ),
      _TrackingStep(
        title: 'Dikirim',
        subtitle: 'Kurir sedang dalam perjalanan ke alamat Anda.',
        isCompleted: false,
        isCurrent: true,
      ),
      _TrackingStep(
        title: 'Sampai Tujuan',
        subtitle: 'Pesanan akan diterima setelah kurir sampai di tempat.',
        isCompleted: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Pemantauan Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No. Pesanan',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'EGR-20260626-001',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, color: eigerBrandColor),
                      const SizedBox(width: 8),
                      Text(
                        'Estimasi tiba: 1-2 hari kerja',
                        style: TextStyle(
                          color: eigerBrandColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Status Pengiriman',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final step = steps[index];
                final isActive = step.isCurrent;
                final isDone = step.isCompleted;
                final iconColor = isDone || isActive
                    ? eigerBrandColor
                    : Colors.grey.shade400;
                final textColor = isDone || isActive
                    ? Colors.black87
                    : Colors.black54;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? const Color.fromRGBO(216, 74, 28, 0.25)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDone ? Icons.check_circle : Icons.local_shipping,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alamat Pengiriman',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Jl. Merdeka No. 88, Yogyakarta'),
                    SizedBox(height: 4),
                    Text('Kontak: 0812-3456-7890'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingStep {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;

  const _TrackingStep({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class PaymentPage extends StatefulWidget {
  final List<Tuple> cartItems;
  final void Function(List<Tuple> cartItems, String paymentMethod) onPlaceOrder;

  const PaymentPage({
    required this.cartItems,
    required this.onPlaceOrder,
    super.key,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPayment = 'Transfer Bank';

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.cartItems.fold<int>(0, (sum, item) {
      final numericPrice = int.parse(
        item.product.price.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      return sum + (numericPrice * item.quantity);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih metode pembayaran',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Transfer Bank'),
              value: 'Transfer Bank',
              groupValue: _selectedPayment,
              onChanged: (value) => setState(() => _selectedPayment = value!),
            ),
            RadioListTile<String>(
              title: const Text('COD (Cash on Delivery)'),
              value: 'COD',
              groupValue: _selectedPayment,
              onChanged: (value) => setState(() => _selectedPayment = value!),
            ),
            RadioListTile<String>(
              title: const Text('E-Wallet'),
              value: 'E-Wallet',
              groupValue: _selectedPayment,
              onChanged: (value) => setState(() => _selectedPayment = value!),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ringkasan Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Metode: $_selectedPayment'),
                    const SizedBox(height: 8),
                    Text('Total: Rp ${totalPrice.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onPlaceOrder(widget.cartItems, _selectedPayment);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaymentConfirmationPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: eigerBrandColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Lanjutkan ke Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  final List<Order> orders;

  const OrderHistoryPage({required this.orders, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pemesanan')),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'Belum ada riwayat pemesanan.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(216, 74, 28, 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status,
                                style: const TextStyle(
                                  color: eigerBrandColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tanggal: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                        ),
                        const SizedBox(height: 4),
                        Text('Metode pembayaran: ${order.paymentMethod}'),
                        const SizedBox(height: 4),
                        Text(
                          'Total: Rp ${order.totalPrice.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Item: ${order.items.map((item) => '${item.quantity}x ${item.product.name}').join(', ')}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class PaymentConfirmationPage extends StatelessWidget {
  const PaymentConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pembayaran Berhasil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terima kasih. Silakan lanjutkan ke pengiriman dan konfirmasi pesanan Anda.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Status Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Pesanan Anda telah diterima dan akan diproses. Kami akan menghubungi Anda jika ada update.',
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: eigerBrandColor),
                    ),
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(color: eigerBrandColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrderTrackingPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: eigerBrandColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Lihat Pemantauan Pesanan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Tuple {
  final EigerProduct product;
  final int quantity;

  Tuple(this.product, this.quantity);
}
