import 'dart:convert';
import 'dart:ui';

import 'package:cafe_authentic_space/model/cart.dart';
import 'package:cafe_authentic_space/model/menu.dart';
import 'package:cafe_authentic_space/model/transaction.dart';
import 'package:cafe_authentic_space/provider/transaction_provider.dart';
import 'package:cafe_authentic_space/screen/invoice_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constant/api_url.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  static const String route = "/order_history";

  @override
  State<StatefulWidget> createState() {
    return _OrderHistoryScreen();
  }
}

class _OrderHistoryScreen extends State<OrderHistoryScreen> {
  final customer_name = TextEditingController();
  final table_number = TextEditingController();

  List order_histories = [];

  Future<void> fetchHistory() async {
    final storage = new FlutterSecureStorage();
    final token = await storage.read(key: "token");

    final response = await http.get(Uri.parse('${API_BASE_URL}/transactions?token=${token}'));

    print(response.statusCode);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body.toString());
      List<dynamic> data = res['data'];

      order_histories = data;
    }
  }

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
          child: RefreshIndicator(
            onRefresh: () async {
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            child: FutureBuilder(
              future: fetchHistory(),
              builder: (context, snapshot) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(left: 8, top: 8, right: 8),
                        child: Column(
                          children: [
                            Text("Riwayat Jajan kamu",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        )),
                    Expanded(
                      child: Padding(
                          padding: EdgeInsetsDirectional.all(0),
                          child: Consumer<TransactionProvider>(
                            builder: (context, cartProvider, child) {
                              final List<Transaction> transactions = cartProvider.transactions;

                              if (order_histories.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Kamu belum jajan.',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: order_histories.length,
                                itemBuilder: (context, index) {
                                  final order_history = order_histories[index];
                                  return InkWell(
                                      onTap: () {

                                        // print(order_history['transaction_menu'][0]['menu']);
                                        List<Cart> carts =
                                            order_history['transaction_menu'].map<Cart>((menu) {
                                              print(menu['menu']['id']);
                                              final data = Menu(id: menu['menu']['id'], name: menu['menu']['name'], price: menu['menu']['price'], image: BASE_URL + menu['menu']['image']);
                                          return Cart(menu: data, quantity: menu['quantity'], note: TextEditingController(text: menu['note']));
                                        }).toList();

                                        Transaction transaction = Transaction(id: order_history['id'],
                                            customer_name: order_history['customer_name'],
                                            table_number: order_history['table_number'],
                                            quantity: order_history['quantity'],
                                            status: order_history['status'],
                                            total: order_history['total'],
                                            carts: carts);

                                        Navigator.pushNamed(context, InvoiceScreen.route,
                                            arguments: transaction);
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(3),
                                          child: Column(children: [
                                            Card(
                                              child: Container(
                                                child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
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
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .start,
                                                                        children: [
                                                                          Text(
                                                                              order_history[
                                                                                  'customer_name'],
                                                                              style: TextStyle(
                                                                                  fontWeight:
                                                                                      FontWeight
                                                                                          .bold,
                                                                                  fontSize: 18)),
                                                                          Text(
                                                                              "Status : ${order_history['status']} |  No Meja : ${order_history['table_number']}")
                                                                        ],
                                                                      ),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .start,
                                                                        children: [
                                                                          Text(
                                                                            "Rp. ${order_history['total']}",
                                                                            style: TextStyle(
                                                                                fontSize: 18),
                                                                          ),
                                                                          Text(
                                                                              "Jumlah: ${order_history['quantity']}")
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  // Text("Catatan : ${cart.note.text}")
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
                );
              },
            ),
          ),
          //BotNav
          // bottomNavigationBar: Stack(
          //   alignment: AlignmentDirectional.center,
          //   children: [
          //     Consumer<CartProvider>(
          //       builder: (context, cartProvider, child) {
          //         if (cartProvider.carts.isEmpty) return Text("");
          //         return ElevatedButton(
          //           onPressed: () {
          //             showModalBottomSheet<void>(
          //               backgroundColor: Colors.white,
          //               isScrollControlled: true,
          //               context: context,
          //               builder: (BuildContext context) {
          //                 return SingleChildScrollView(
          //                     child: Container(
          //                         padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          //                         child: Container(
          //                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          //                           child: Wrap(
          //                             spacing: 60,
          //                             children: [
          //                               Container(height: 10),
          //                               const Text(
          //                                 "Silahkan isi Nama dan No Meja",
          //                                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          //                               ),
          //                               Container(height: 10),
          //                               Column(
          //                                 crossAxisAlignment: CrossAxisAlignment.start,
          //                                 children: [
          //                                   Text("Nama"),
          //                                   TextField(
          //                                     controller: customer_name,
          //                                     decoration: const InputDecoration(
          //                                       border: OutlineInputBorder(),
          //                                       hintText: 'Nama',
          //                                     ),
          //                                   ),
          //                                 ],
          //                               ),
          //                               Container(height: 5),
          //                               Column(
          //                                 crossAxisAlignment: CrossAxisAlignment.start,
          //                                 children: [
          //                                   Text("No Meja"),
          //                                   TextField(
          //                                     controller: table_number,
          //                                     decoration: const InputDecoration(
          //                                       border: OutlineInputBorder(),
          //                                       hintText: 'No Meja',
          //                                     ),
          //                                     keyboardType: TextInputType.number,
          //                                     inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          //                                   ),
          //                                 ],
          //                               ),
          //                               Container(height: 5),
          //                               SizedBox(
          //                                   width: double.infinity,
          //                                   child: ElevatedButton(
          //                                       onPressed: () {
          //                                         // Navigator.pushNamedAndRemoveUntil(context, InvoiceScreen.route, ModalRoute.withName("/"));
          //                                         Navigator.pushNamed(context, InvoiceScreen.route, arguments: Order(customer_name: customer_name.text, table_number: table_number.text));
          //                                       },
          //                                       child: Text("Konfirmasi")))
          //                             ],
          //                           ),
          //                         )));
          //               },
          //             );
          //           },
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Consumer<CartProvider>(
          //                 builder: (context, cartProvider, child) {
          //                   if (cartProvider.cartCount > 1) {
          //                     return Text("Pesan : Rp. ${cartProvider.totalPrice}");
          //                     return Badge(child: Text('Pesan'), label: Text(cartProvider.cartCount.toString()));
          //                   }
          //                   return Text('Pesan');
          //                   return Text("Pesanan | ${cartProvider.cartCount}");
          //                 },
          //               )
          //             ],
          //           ),
          //         );
          //       },
          //     )
          //   ],
          // ),
        ));
  }
}
