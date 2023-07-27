import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttttttt/importer.dart';

class HomePresenter extends StatefulWidget {
  const HomePresenter({super.key});

  @override
  State<HomePresenter> createState() => _HomePresenterState();
}

class _HomePresenterState extends State<HomePresenter> {

  @override
  void initState() {
    permissionRequest();
    super.initState();
  }

  permissionRequest() async {
    await Permission.manageExternalStorage.request();
  }
  @override
  Widget build(BuildContext context) {
    return HomeView();
  }
}
