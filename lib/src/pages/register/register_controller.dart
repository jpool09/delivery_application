import 'dart:convert';
import 'dart:io';

import 'package:delivery_application/src/models/response_api.dart';
import 'package:delivery_application/src/models/user.dart';
import 'package:delivery_application/src/provider/users_provider.dart';
import 'package:delivery_application/src/utils/my_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterController {
  BuildContext context;
  TextEditingController emailController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController lastnameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  UsersProvider usersProvider = new UsersProvider();

  PickedFile pickedFile;
  File imageFile;
  Function refresh;

  Future init(BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;
    usersProvider.init(context);
  }

  void register() async {
    String email = emailController.text.trim();
    String name = nameController.text;
    String lastname = lastnameController.text;
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty ||
        name.isEmpty ||
        lastname.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      MySnackBar.show(context, 'Debes llenar todos los campos');
      return;
    }

    if (confirmPassword != password) {
      MySnackBar.show(context, 'Las contraseñas no coinciden');
      return;
    }

    if (password.length < 6) {
      MySnackBar.show(context, 'La contraseña debe ser mayor a 6 caracteres');
      return;
    }

    if (imageFile == null) {
      MySnackBar.show(context, 'Selecciona una imagen');
      return;
    }

    User user = new User(
      email: email,
      name: name,
      lastname: lastname,
      phone: phone,
      password: password,
    );

    Stream stream = await usersProvider.createWithImage(user, imageFile);
    stream.listen((res) {
      // ResponseApi responseApi = await usersProvider.create(user);
      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));
      
      print('Respuesta: ${responseApi.toJson()}');

      MySnackBar.show(context, responseApi.message);

      if (responseApi.success) {
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacementNamed(context, 'login');
        });
      }
    });
  }

  Future selectImage(ImageSource imageSource) async {
    pickedFile = await ImagePicker().getImage(source: imageSource);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }

    Navigator.pop(context);
    refresh();
  }

  void showAlertDialog() {
    Widget galleryButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.gallery);
        },
        child: Text('Galeria'));

    Widget cameraButton = ElevatedButton(
        onPressed: () {
          selectImage(ImageSource.camera);
        },
        child: Text('Camara'));

    AlertDialog alertDialog = AlertDialog(
      title: Text('Selecciona tu imagen'),
      actions: [galleryButton, cameraButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  void back() {
    Navigator.pop(context);
  }
}
