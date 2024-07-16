import 'package:cafe_authentic_space/model/transaction.dart';
import 'package:collection/collection.dart';

import 'package:flutter/widgets.dart';

class TransactionProvider extends ChangeNotifier{
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  void addToTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();

    print("Menu telah ditambahkan");
  }
}