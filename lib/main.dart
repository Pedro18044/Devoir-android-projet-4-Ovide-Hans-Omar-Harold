import 'package:flutter/material.dart';
import 'stockage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EBoutikoo',
      theme: ThemeData(useMaterial3: true),
      home: const ProductsScreen(),
    );
  }
}

class Product {
  final String name;
  final String imageLink; // se sa n ap sove nan stockage
  final bool isAsset;

  const Product({
    required this.name,
    required this.imageLink,
    required this.isAsset,
  });
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  // ✅ Ou ka mete assets tou. Sou Zapp, network link yo pi fasil pou teste.
  static const products = <Product>[
    // Assets (mete imaj yo nan assets/images/ epi mete menm non yo isit)
    // Product(name: 'Savon 1', imageLink: 'assets/images/savon1.png', isAsset: true),
    // Product(name: 'Savon 2', imageLink: 'assets/images/savon2.png', isAsset: true),

    // Network (sa mache dirèk sou Zapp)
    Product(name: 'Pwodwi 1', imageLink: 'https://picsum.photos/id/1060/600/600', isAsset: false),
    Product(name: 'Pwodwi 2', imageLink: 'https://picsum.photos/id/1080/600/600', isAsset: false),
    Product(name: 'Pwodwi 3', imageLink: 'https://picsum.photos/id/1025/600/600', isAsset: false),
    Product(name: 'Pwodwi 4', imageLink: 'https://picsum.photos/id/100/600/600', isAsset: false),
    Product(name: 'Pwodwi 5', imageLink: 'https://picsum.photos/id/103/600/600', isAsset: false),
    Product(name: 'Pwodwi 6', imageLink: 'https://picsum.photos/id/237/600/600', isAsset: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EBoutikoo'),
        actions: [
          IconButton(
            tooltip: 'Lis Achte',
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuyListScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, i) {
          final p = products[i];
          return _ProductCard(product: p);
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final image = product.isAsset
        ? Image.asset(product.imageLink, fit: BoxFit.cover)
        : Image.network(product.imageLink, fit: BoxFit.cover);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x22000000),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: image,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Achte'),
              onPressed: () async {
                // ✅ DEVWA: anrejistre lyen imaj la nan stokaj lokal
                await stockage.write(product.imageLink);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ajoute nan Lis Achte')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BuyListScreen extends StatefulWidget {
  const BuyListScreen({super.key});

  @override
  State<BuyListScreen> createState() => _BuyListScreenState();
}

class _BuyListScreenState extends State<BuyListScreen> {
  late Future<List<String>> futureLinks;

  @override
  void initState() {
    super.initState();
    futureLinks = stockage.readAll(); // ✅ DEVWA
  }

  bool _isNetwork(String s) => s.startsWith('http');

  Future<void> _reload() async {
    setState(() {
      futureLinks = stockage.readAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lis Achte'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: futureLinks,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final links = snap.data ?? [];

          if (links.isEmpty) {
            return const Center(child: Text('Lis la vid.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: links.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final link = links[i];

              final thumb = _isNetwork(link)
                  ? Image.network(link, width: 56, height: 56, fit: BoxFit.cover)
                  : Image.asset(link, width: 56, height: 56, fit: BoxFit.cover);

              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: thumb,
                ),
                title: Text(
                  link,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
