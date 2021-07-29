import 'package:delivery_application/src/models/response_api.dart';
import 'package:delivery_application/src/models/user.dart';
import 'package:delivery_application/src/provider/users_provider.dart';
import 'package:delivery_application/src/utils/my_snackbar.dart';
import 'package:delivery_application/src/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class LoginController {
  //Teoria de Null Safety -> Ninguna variable puede ser null
  //Solución -> Colocar ? despues de BuildContext y del Future

  BuildContext context;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  UsersProvider usersProvider = new UsersProvider();
  SharedPref _sharedPref = new SharedPref();

  Future init(BuildContext context) async {
    this.context = context;
    await usersProvider.init(context);

    User user = User.fromJson(await _sharedPref.read('user') ?? {});

    if (user?.sessionToken != null) {
      if (user.roles.length > 1) {
        Navigator.pushNamedAndRemoveUntil(
            context, 'client/products/list', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, user.roles[0].route, (route) => false);
      }
    }
  }

  void goToRegisterPage() {
    Navigator.pushNamed(context, 'register');
  }

  void login() async {
    //El .trim() elimina espacios que coloque el user
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    ResponseApi responseApi = await usersProvider.login(email, password);

    if (responseApi.success) {
      User user = User.fromJson(responseApi.data);
      _sharedPref.save('user', user.toJson());

      print('Usuario logueado: ${user.toJson()}');

      if (user.roles.length > 1) {
        Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, user.roles[0].route, (route) => false);
      }
    } else {
      MySnackBar.show(context, responseApi.message);
    }
  }
}
