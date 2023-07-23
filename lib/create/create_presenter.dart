import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttttttt/importer.dart';

class CreatePresenter extends StatefulWidget {
  const CreatePresenter({super.key});

  @override
  State<CreatePresenter> createState() => _CreatePresenterState();
}

class _CreatePresenterState extends State<CreatePresenter> {
  String _name = '';
  String _contact = '';
  String _address = '';
  String _type = '분뇨';
  DateTime? _date = DateTime.now();
  int _size = 0;
  int _cost = 0;
  String _numOfCar = '';

  List<String> _typeList = [
    '분뇨',
    '정화조',
    '오수처리시설',
  ];
  List<String> _numOfCarList = [
    '91루0799',
    '89보7775',
    '80마3320'
  ];

  @override
  Widget build(BuildContext context) {
    return CreateView(
      onTapSave: () => _onTapSave(),
      onTapTempSave: () => _onTapTempSave(),
      onTapCancel: () => _onTapCancel(),
      onTapPickDate: () => _onTapPickDate(),
    );
  }

  void _onTapSave() async {

    Fluttertoast.showToast(msg: '저장 되었습니다.');
  }

  void _onTapTempSave() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', 'kkkk');

    Fluttertoast.showToast(msg: '임시저장 되었습니다.');
    // print(prefs.getString('name'));
  }

  void _onTapCancel() {
    Get.back();
  }

  void _onTapPickDate() async {
    _date = await showRoundedDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.year,
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}
