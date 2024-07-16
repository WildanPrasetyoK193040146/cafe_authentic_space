import 'package:flutter/material.dart';
import 'menu.dart';

class Cart {
  final Menu menu;
  int quantity;

  TextEditingController note;

  Cart({required this.menu, required this.quantity, required this.note});
}