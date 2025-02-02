import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:productexpire/controllors/app_controller.dart';
import 'package:productexpire/models/product_model.dart';
import 'package:productexpire/models/user_model.dart';

class MyService {
  Future<void> processDeleteProduct(
      {required String docIdProductDelete}) async {
    AppController appController = Get.put(AppController());
    var user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('product')
        .doc(docIdProductDelete)
        .delete()
        .then((value) {
      readAllProductExpire();
    });
  }

  Future<void> findUserModels() async {
    AppController appController = Get.put(AppController());
    var user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get()
        .then((value) {
      UserModel model = UserModel.fromMap(value.data()!);
      appController.userModels.add(model);
    });
  }

  Future<void> readAllProductExpire() async {
    AppController appController = Get.put(AppController());
    var user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .collection('product')
        .orderBy('timeExpire')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        if (appController.productModels.isNotEmpty) {
          appController.productModels.clear();
        }

        if (appController.nonExprieProductModels.isNotEmpty) {
          appController.nonExprieProductModels.clear();
          appController.docIdNonExpireProducts.clear();
        }

        for (var element in value.docs) {
          ProductModel productModel = ProductModel.fromMap(element.data());
          if (productModel.timeExpire.toDate().isBefore(DateTime.now())) {
            print('##11feb Product Expire');
            appController.productModels.add(productModel);
          } else {
            print('##11feb Product Now Expire');
            appController.nonExprieProductModels.add(productModel);
            appController.docIdNonExpireProducts.add(element.id);
          }
        }
      }
    });
  }

  String dateToString({required DateTime dateTime}) {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    return dateFormat.format(dateTime);
  }
}
