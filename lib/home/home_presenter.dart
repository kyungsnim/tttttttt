import 'package:flutter/material.dart';
import 'package:tttttttt/importer.dart';

class HomePresenter extends StatefulWidget {
  const HomePresenter({super.key});

  @override
  State<HomePresenter> createState() => _HomePresenterState();
}

class _HomePresenterState extends State<HomePresenter> {
  @override
  Widget build(BuildContext context) {
    return HomeView();
  }
}
