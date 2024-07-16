import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../model/menu.dart';
import '../model/cart.dart';

class CartProvider extends ChangeNotifier {
  final List<Cart> _carts = [];

  List<Cart> get carts => _carts;

  void addToCart(Menu menu, int quantity, TextEditingController note,String selectedVariant) {
    var existingCart = _carts.firstWhereOrNull(
          (item) => item.menu.id == menu.id,
    );

    if (existingCart != null) {
      existingCart.quantity += quantity;
    } else {
      _carts.add(Cart(menu: menu, quantity: quantity, note: note,));
    }

    notifyListeners();

    print("Menu telah ditambahkan");
  }

  Cart getMenuById(int menuId){
    var existingCart = _carts.firstWhereOrNull(
          (item) => item.menu.id == menuId,
    );

    if (existingCart != null) {
      return _carts.firstWhere((element) => element.menu.id == menuId);
    } else {
      return Cart(menu: Menu(), quantity: 1, note: TextEditingController(text: ""));
    }

  }

  int getMenuQuantity(int productId) {
    int quantity = 0;
    for (Cart cart in _carts) {
      if (cart.menu.id == productId) {
        quantity += cart.quantity;
      }
    }
    return quantity;
  }

  int get cartCount {
    return _carts.fold(0, (sum, cart) => sum + cart.quantity);
  }

  int get totalPrice {
    return _carts.fold(
        0, (sum, cart) => sum + (cart.menu.price! * cart.quantity)
    );
  }

  void updateMenuCartQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _carts.length) {
      _carts[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  void increaseMenuCartQuantity(int index) {
    if (index >= 0 && index < _carts.length) {
      _carts[index].quantity++;
      notifyListeners();
    }
  }

  void clearCart() {
    _carts.clear();
    notifyListeners();
  }

  List<Cart> getCartItemsList() {
    return List<Cart>.from(_carts);
  }

}