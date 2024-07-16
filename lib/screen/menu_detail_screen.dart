import 'package:cached_network_image/cached_network_image.dart';
import 'package:cafe_authentic_space/model/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/menu.dart';
import '../provider/cart_provider.dart';

class MenuDetailScreen extends StatefulWidget {
  const MenuDetailScreen({super.key});

  static const String route = "/menu_detail";

  @override
  State<StatefulWidget> createState() {
    return _MenuDetailScreen();
  }
}

class _MenuDetailScreen extends State<MenuDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);
    final args = ModalRoute.of(context)!.settings.arguments as Menu;

    Cart cart = cartProvider.getMenuById(args.id!);
    print(args.name);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 98, 235, 12),
          title: Text("Cafe Authentic Space"),
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                      child: Hero(
                          tag: "Menu",
                          child: ClipRect(
                            child: CachedNetworkImage(
                              imageUrl: args.image!,
                              width: double.infinity,
                              height: 430,
                              fit: BoxFit.cover,
                            ),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                      child: Text(
                        args.name!,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
                      child: Text(
                        "Rp. ${args.price.toString()!}",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 8),
                      child: Container(
                        height: 120,
                        child: TextField(
                          onTapOutside: (PointerDownEvent event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          maxLines: 120,
                          keyboardType: TextInputType.multiline,
                          controller: cart.note,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Silahkan tambahkan catatan',
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                                icon: Icon(Icons.remove)),
                            Text(quantity.toString()),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                                icon: Icon(Icons.add))
                          ],
                        ),
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                child: ElevatedButton(
                                    onPressed: () {
                                      // print("Jumlah : ${quantity}, Catatan : ${_note.text}");
                                      Provider.of<CartProvider>(context, listen: false)
                                          .addToCart(args, quantity, cart.note, "");
                                      Navigator.pop(context);
                                    },
                                    child: Text("Tambahkan ke Pesanan"))))
                      ],
                    )
                  ],
                ),
              )),
            ],
          ),
        ));
  }
}
