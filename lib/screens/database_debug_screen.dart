import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class DatabaseDebugScreen extends StatefulWidget {
  const DatabaseDebugScreen({super.key});

  @override
  State<DatabaseDebugScreen> createState() => _DatabaseDebugScreenState();
}

class _DatabaseDebugScreenState extends State<DatabaseDebugScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final products = await _dbHelper.getAllProducts();
      if (!mounted) return;
      setState(() => _products = products);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _seedDatabase() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await _dbHelper.deleteAllProducts();
      
      final sampleProducts = [
        {
          'id': 'p1',
          'name': 'Trocadero Azteca 2.0',
          'category': 'Sandal',
          'price': 'Rp 142.350',
          'oldPrice': 'Rp 219.000',
          'description': 'Sandal outdoor ringan dengan sol anti slip dan bantalan lembut untuk aktivitas sehari-hari.',
          'rating': 5,
        },
        {
          'id': 'p2',
          'name': 'Kinkajou 3.5',
          'category': 'Sandal',
          'price': 'Rp 148.850',
          'oldPrice': 'Rp 229.000',
          'description': 'Sandal hiking breathable dengan desain modern dan ketahanan air ringan.',
          'rating': 4,
        },
        {
          'id': 'p3',
          'name': 'Safar Low Cut',
          'category': 'Sepatu',
          'price': 'Rp 148.850',
          'oldPrice': 'Rp 229.000',
          'description': 'Sepatu gunung low cut dengan bantalan nyaman dan traksi kuat untuk permukaan berbatu.',
          'rating': 5,
        },
      ];

      for (var product in sampleProducts) {
        await _dbHelper.insertProduct(product);
      }

      await _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database seeded dengan 3 produk sample')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding database: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearDatabase() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus semua data?'),
        content: const Text('Ini akan menghapus semua produk dari database.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              if (!mounted) return;
              setState(() => _isLoading = true);
              try {
                await _dbHelper.deleteAllProducts();
                await _loadProducts();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Semua data telah dihapus')),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              } finally {
                if (!mounted) return;
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
        backgroundColor: const Color(0xFFd84a1c),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total Produk: ${_products.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _seedDatabase,
                        icon: const Icon(Icons.add),
                        label: const Text('Seed Database'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _loadProducts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _clearDatabase,
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus Semua Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _products.isEmpty
                      ? const Center(
                          child: Text('Tidak ada data'),
                        )
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(product['name']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${product['id']} | Kategori: ${product['category']}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Harga: ${product['price']} | Rating: ${product['rating']}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                )
              ],
            ),
    );
  }
}


