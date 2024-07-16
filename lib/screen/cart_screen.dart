import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cafe_authentic_space/model/cart.dart';
import 'package:cafe_authentic_space/model/transaction.dart';
import 'package:cafe_authentic_space/provider/cart_provider.dart';
import 'package:cafe_authentic_space/screen/invoice_screen.dart';
import 'package:cafe_authentic_space/screen/menu_detail_screen.dart';
import 'package:cafe_authentic_space/type/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  static const String route = "/cart";

  @override
  State<StatefulWidget> createState() {
    return _CartScreen();
  }
}

class _CartScreen extends State<CartScreen> {
  final customer_name = TextEditingController();
  final table_number = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 98, 235, 12),
        title: Text("Cafe Authentic Space"),
      ),
      body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.only(left: 8, top: 8, right: 8),
                  child: Column(
                    children: [
                      Text("Pesanan kamu",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  )),
              Expanded(
                child: Padding(
                    padding: EdgeInsetsDirectional.all(0),
                    child: Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        final List<Cart> carts = cartProvider.carts;

                        if (carts.isEmpty) {
                          return Center(
                            child: Text(
                              'Kamu belum memilih menu.',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: carts.length,
                          itemBuilder: (context, index) {
                            final cart = carts[index];
                            return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, MenuDetailScreen.route,
                                      arguments: cart.menu);
                                },
                                child: Container(
                                    padding: EdgeInsets.all(3),
                                    child: Column(children: [
                                      Card(
                                        child: Container(
                                          child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(8),
                                                      topLeft: Radius.circular(8)),
                                                  child: CachedNetworkImage(
                                                    imageUrl: cart.menu.image!,
                                                    fit: BoxFit.cover,
                                                    width: 120,
                                                    height: 120,
                                                    placeholder: (context, url) => const Center(
                                                        child: CircularProgressIndicator()),
                                                    errorWidget: (context, url, error) =>
                                                        const Icon(Icons.error),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Padding(
                                                        padding: EdgeInsets.all(6),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment.start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(cart.menu.name!,
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 18)),
                                                                Text(
                                                                  "Rp. ${cart.menu.price.toString()}",
                                                                  style: TextStyle(fontSize: 16),
                                                                ),
                                                              ],
                                                            ),
                                                            Text("x ${cart.quantity}"),
                                                            Text("Catatan : ${cart.note.text}")
                                                          ],
                                                        )))
                                              ]),
                                        ),
                                        color: Colors.white,
                                      ),
                                    ])));
                          },
                        );
                      },
                    )),
              )
            ],
          )),
      bottomNavigationBar: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.carts.isEmpty) return Text("");
              return ElevatedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    backgroundColor: Colors.white,
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return SingleChildScrollView(
                          child: Container(
                              padding:
                                  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                child: Wrap(
                                  spacing: 60,
                                  children: [
                                    Container(height: 10),
                                    const Text(
                                      "Silahkan isi Nama dan No Meja",
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                                    ),
                                    Container(height: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Nama"),
                                        TextField(
                                          controller: customer_name,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'Nama',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(height: 5),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("No Meja"),
                                        TextField(
                                          controller: table_number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: 'No Meja',
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(height: 5),
                                    SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              // Navigator.pushNamedAndRemoveUntil(context, InvoiceScreen.route, ModalRoute.withName("/"));
                                              Navigator.pushNamed(context, InvoiceScreen.route,
                                                  arguments: Transaction(
                                                      id: 1,
                                                      customer_name: customer_name.text,
                                                      table_number: table_number.text,
                                                      quantity: cartProvider.cartCount,
                                                      status: "new",
                                                      total: cartProvider.totalPrice,
                                                      carts: cartProvider.carts
                                                  ),
                                              );
                                            },
                                            child: Text("Konfirmasi")))
                                  ],
                                ),
                              )));
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        if (cartProvider.cartCount > 1) {
                          return Text("Pesan | Rp. ${cartProvider.totalPrice}");
                          return Badge(
                              child: Text('Pesan'), label: Text(cartProvider.cartCount.toString()));
                        }
                        return Text('Pesan');
                        return Text("Pesanan | ${cartProvider.cartCount}");
                      },
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
