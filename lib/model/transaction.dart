import 'cart.dart';

class Transaction {
  int id;
  String customer_name;
  String table_number;
  int quantity;
  String status;
  int total;
  List<Cart> carts;

  Transaction(
      {required this.id,
      required this.customer_name,
      required this.table_number,
      required this.quantity,
      required this.status,
      required this.total,
        required this.carts
      });
}
