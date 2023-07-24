import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:kpostal/kpostal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
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
  String _addressDetail = '';
  String _type = '분뇨';
  DateTime? _date = DateTime.now();
  String _size = '';
  String _cost = '';
  String _numOfCar = '91루0799';
  Uint8List? _png1Bytes;
  Uint8List? _png2Bytes;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _addressDetailController = TextEditingController();
  TextEditingController _sizeController = TextEditingController();
  TextEditingController _costController = TextEditingController();
  final SignatureController _sign1Controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );
  final SignatureController _sign2Controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  List<String> _typeList = [
    '분뇨',
    '정화조',
    '오수처리시설',
  ];
  List<String> _numOfCarList = ['91루0799', '89보7775', '80마3320'];

  @override
  Widget build(BuildContext context) {
    return CreateView(
      name: _name,
      contact: _contact,
      address: _address,
      addressDetail: _addressDetail,
      type: _type,
      typeList: _typeList,
      date: _date!,
      size: _size,
      cost: _cost,
      numOfCar: _numOfCar,
      numOfCarList: _numOfCarList,
      nameController: _nameController,
      contactController: _contactController,
      addressDetailController: _addressDetailController,
      sizeController: _sizeController,
      costController: _costController,
      png1Bytes: _png1Bytes ?? Uint8List(1),
      png2Bytes: _png2Bytes ?? Uint8List(1),
      onTapSave: () => _onTapSave(),
      onTapTempSave: () => _onTapTempSave(),
      onTapCancel: () => _onTapCancel(),
      onTapPickDate: () => _onTapPickDate(),
      onTapSearchAddress: () => _onTapSearchAddress(),
      onChangedNumOfCar: (value) => _onChangedNumOfCar(value),
      onTapCalendar: () => _onTapCalendar(),
      onTapSignature: (title) => _onTapSignature(title),
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

  void _onTapSearchAddress() async {
    await Get.to(() => KpostalView(
          useLocalServer: true,
          localPort: 1024,
          callback: (Kpostal result) {
            setState(() {
              _address = result.address;
            });
          },
        ));
    print(_address);
  }

  void _onChangedNumOfCar(value) {
    setState(() {
      _numOfCar = value;
    });
  }

  void _onTapCalendar() async {
    DateTime? newDate = await showRoundedDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      borderRadius: 8,
      height: 400,
    );

    if (newDate != null) {
      setState(() {
        _date = newDate;
      });
    }
  }

  void _onTapSignature(String title) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('서명'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 0.5),
                  ),
                  child: Signature(
                    controller: title == '분뇨수집운반업체' ? _sign1Controller : _sign2Controller,
                    width: 200,
                    height: 100,
                    backgroundColor: Colors.white,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text('확인'),
                      onPressed: () async {
                        if (title == '분뇨수집운반업체') {
                          Uint8List? bytes = await _sign1Controller.toPngBytes(
                              width: 200, height: 100);
                          setState(() {
                            _png1Bytes = bytes;
                          });
                          _sign1Controller.clear();
                        } else {
                          Uint8List? bytes = await _sign2Controller.toPngBytes(
                              width: 200, height: 100);
                          setState(() {
                            _png2Bytes = bytes;
                          });
                          _sign2Controller.clear();
                        }
                        Get.back();
                      },
                    ),
                    TextButton(
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      onPressed: () {
                        if (title == '분뇨수집운반업체') {
                          _sign1Controller.clear();
                        } else {
                          _sign2Controller.clear();
                        }
                        Get.back();
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }
}
