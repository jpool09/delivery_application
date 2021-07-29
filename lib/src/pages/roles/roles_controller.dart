import 'package:delivery_application/src/models/user.dart';
import 'package:delivery_application/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class RolesController {
  BuildContext context;
  Function refresh;

  User user;
  SharedPref sharedPref = new SharedPref();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    //Obtener usuario de sesion
    user = User.fromJson(await sharedPref.read('user'));
    refresh();
  }

  void goToPage(String route) {
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }
}
