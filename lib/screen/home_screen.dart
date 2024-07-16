import 'dart:convert';

import 'package:cafe_authentic_space/constant/api_url.dart';
import 'package:cafe_authentic_space/screen/cart_screen.dart';
import 'package:cafe_authentic_space/screen/order_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../model/menu.dart';
import '../provider/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String route = "/";

  @override
  State<StatefulWidget> createState() {
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> {
  int currentPageIndex = 0;

  List<Menu> menus = [];

  // List menus = [];

  List<String> list = <String>[
    'Tampilkan Semua',
    'Makanan Berat',
    'Makanan Ringan',
    'Minuman Kopi',
    'Minuman Non Kopi'
  ];

  String dropdownValue = "Tampilkan Semua";

  Future<void> fetchAlbum({category = "Tampilkan Semua"}) async {
    if (category == "Tampilkan Semua") {
      category = "";
    }
    final response = await http.get(Uri.parse('${API_BASE_URL}/menus?category=${category}'));
    print('${API_BASE_URL}/menus?category=${category}');
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("Request");
      var res = jsonDecode(response.body.toString());


      List<dynamic> data = res['data'];
      // print(data);
      List<Menu> menuList = data.map((json) {
        return Menu(
                id: json['id'],
                name: json['name'],
                price: json['price'],
                image: BASE_URL + json['image']);
      }).toList();

      setState(() {
        menus = menuList;
      });
    }
  }



  void generateToken() async {
    final storage = new FlutterSecureStorage();
    final token = await storage.read(key: "token");

    if(token == null){
      await storage.write(key: "token", value: Uuid().v4());
      print("Token Generated");
    }else{
      print("Token Ok " + token);
    }

  }

  @override
  void initState() {
    super.initState();
    fetchAlbum();
    generateToken();
  }

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);

    // menus.add(Menu(id: 200,name: 'kopi', price: 12000, image: ""  ));
    print("MASMAS ${menus}");

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 98, 235, 12),
        title: Text("Cafe Authentic Space"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, OrderHistoryScreen.route);
              },
              child: Icon(Icons.book_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(
          top: true,
          child: RefreshIndicator(
            onRefresh: () async {
              fetchAlbum();
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Color.fromARGB(255, 98, 235, 12),
                          ),
                          onChanged: (String? value) async {
                            // This is called when the user selects an item.
                            // setState(() async {
                            await fetchAlbum(category: value);
                            dropdownValue = value!;
                            // });
                          },
                          items: list.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                       menus.isEmpty ? Container( padding: EdgeInsets.only(top: 200),child: Center(
                         child: Text(
                           'Menu belum tersedia.',
                           style: Theme.of(context).textTheme.titleLarge,
                         ),
                       )) : GridView.builder(
                            itemCount: menus.length,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 2 / 2.5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12),
                            itemBuilder: (context, index) {
                              final menu = menus[index];
                              return InkWell(
                                  // key: Key(menu.id.toString()),
                                  onTap: () {
                                    Navigator.pushNamed(context, "/menu_detail", arguments: menu);
                                  },
                                  child: Card(
                                    // decoration: BoxDecoration(
                                    //     borderRadius: BorderRadius.circular(6),
                                    //     color: Colors.white),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6)),
                                          child: CachedNetworkImage(
                                            imageUrl: menu.image!,
                                            width: double.infinity,
                                            height: 150,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) {
                                              return const Center(
                                                  child: CircularProgressIndicator());
                                            },
                                            errorWidget: (context, url, error) =>
                                                const Icon(Icons.error),
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsetsDirectional.only(start: 6, top: 6),
                                            child: Text(
                                              menu.name!,
                                              style: TextStyle(
                                                color: Color(0xFF101213),
                                                fontSize: 16,
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )),
                                        Padding(
                                          padding: EdgeInsetsDirectional.only(start: 6),
                                          child: Text(
                                            "Rp. ${menu.price.toString()!}",
                                            style: TextStyle(
                                              color: Color(0xFF101213),
                                              // fontSize: 18,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ));
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
      bottomNavigationBar: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    if (cartProvider.cartCount > 0) {
                      return Badge(
                          child: Text('Pesan'), label: Text(cartProvider.cartCount.toString()));
                    }
                    return Text('Pesan');
                    return Text("Pesanan | ${cartProvider.cartCount}");
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
