import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cafe_authentic_space/constant/api_url.dart';
import 'package:cafe_authentic_space/model/cart.dart';
import 'package:cafe_authentic_space/model/menu.dart';
import 'package:cafe_authentic_space/model/transaction.dart';
import 'package:cafe_authentic_space/provider/cart_provider.dart';
import 'package:cafe_authentic_space/provider/transaction_provider.dart';
import 'package:cafe_authentic_space/screen/menu_detail_screen.dart';
import 'package:cafe_authentic_space/type/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';


class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  static const String route = "/invoice";

  @override
  State<StatefulWidget> createState() {
    return _InvoiceScreen();
  }
}

class _InvoiceScreen extends State<InvoiceScreen> {
  final customer_name = TextEditingController();
  final table_number = TextEditingController();

  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => showAlert(context));
  }

  void showAlert(BuildContext context){
    final args = ModalRoute.of(context)!.settings.arguments as Transaction;
    print(args.total);

    if(args.status == 'pending'){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text('Terimakasih tealah memesan di Cafe Authentic Space. Silahkan bayar ke kasir untuk melakukan pembayaran, agar pesanan anda diproses'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Konfirmasi'),
            ),
          ],
        ),
      );
    }
  }


  Future<http.Response> postRequest (body) async {
    //encode Map to JSON
    print(Uri.parse("${API_BASE_URL}/transactions"));
    var response = await http.post(Uri.parse("${API_BASE_URL}/transactions"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body
    );

    print("${response.statusCode}");
    print("${response.body}");
    return response;
  }


  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Transaction;
    print(args.carts);
    

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 98, 235, 12),
        title: Text("Cafe Authentic Space"),
      ),
      body: SafeArea(
          top: true,
          child: Card(
            color: Colors.white,
            // Padding(
            //   padding: EdgeInsets.all(6),
            //   child: Text("Riwayat Hasil Pesanan"),
            // ),
            child: Padding(
                padding: EdgeInsetsDirectional.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Hai"),
                        Text(DateFormat("dd-MM-yyyy").format(now)),
                      ],
                    ),
                    Text(args.customer_name!),
                    Text("Pesanan anda akan "),
                    Text("Dengan keterangan sebagai berikut :"),
                    Text("No Meja : ${args.table_number!}"),
                    Divider(),
                    Expanded(
                      child: args.carts.isEmpty
                          ? Center(
                              child: Text(
                                'Kamu belum memilih menu.',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            )
                          : ListView.builder(
                              itemCount: args.carts.length,
                              itemBuilder: (context, index) {
                                final cart = args.carts[index];
                                return InkWell(
                                    onTap: () {},
                                    child: Container(
                                        child: Column(children: [
                                      Container(
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  child: Padding(
                                                      padding: EdgeInsets.all(0),
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
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    cart.menu.name!,
                                                                  ),
                                                                  Text(
                                                                      " x${cart.quantity.toString()!}"),
                                                                ],
                                                              ),
                                                              Text(
                                                                  "Rp. ${cart.menu.price.toString()}"),
                                                            ],
                                                          )
                                                        ],
                                                      )))
                                            ]),
                                      ),
                                    ])));
                              },
                            ),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total"),
                        Text("Rp. ${args.total.toString()}"),
                      ],
                    ),
                  ],
                )),
          )),
      bottomNavigationBar: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.carts.isEmpty) return Text("");
              return ElevatedButton(
                onPressed: () async {
                  final transactionProvider =
                      Provider.of<TransactionProvider>(context, listen: false);

                  final List<Cart> carts = cartProvider.carts
                      .map(
                          (item) => Cart(menu: item.menu, quantity: item.quantity, note: item.note))
                      .toList();

                  final storage = new FlutterSecureStorage();
                  final token = await storage.read(key: "token");

                  var menus = args.carts.map((menu) {
                    return {
                        // Transaction Menu
                        "menu_id": menu.menu.id,
                        "quantity": menu.quantity,
                        "note": menu.note.text != "" ?  menu.note.text : "-"
                    };
                  }).toList();

                  var transaction = {
                    "customer_name": args.customer_name,
                    "table_number": args.table_number,
                    "quantity": args.quantity,
                    "total": args.total,
                    "token": token,
                    "menus": menus
                  };

                  var body = json.encode(transaction);

                  postRequest(body);
                  // transactionProvider.addToTransaction(Transaction(
                  //     id: 1,
                  //     customer_name: args.customer_name!,
                  //     table_number: args.table_number!,
                  //     quantity: cartProvider.cartCount,
                  //     status: "NEW",
                  //     total: cartProvider.totalPrice,
                  //     carts: carts));

                  Navigator.pushNamedAndRemoveUntil(
                      context, InvoiceScreen.route, ModalRoute.withName("/"),
                      arguments: Transaction(
                          id: 1,
                          customer_name: args.customer_name!,
                          table_number: args.table_number!,
                          quantity: cartProvider.cartCount,
                          status: "pending",
                          total: cartProvider.totalPrice,
                          carts: carts));
                  cartProvider.clearCart();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: cartProvider.cartCount > 1
                          ? Text("Konfirmasi | Rp. ${cartProvider.totalPrice}")
                          : Text("Pesanan"),
                    ),
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

class DialogExample extends StatelessWidget {
  const DialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const Text('AlertDialog description'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      child: const Text('Show Dialog'),
    );
  }
}
