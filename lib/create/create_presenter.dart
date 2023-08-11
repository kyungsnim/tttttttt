import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:tttttttt/importer.dart';

class CreatePresenter extends StatefulWidget {
  String? id;
  String? name;
  String? contact;
  String? address;
  String? addressDetail;
  String? date;
  String? size;
  String? cost;
  bool? viewMode;
  String? numOfCar;
  String? type;
  Uint8List? png1Bytes;
  Uint8List? png2Bytes;

  CreatePresenter({
    this.id,
    this.name,
    this.contact,
    this.address,
    this.addressDetail,
    this.date,
    this.size,
    this.cost,
    this.viewMode,
    this.numOfCar,
    this.type,
    this.png1Bytes,
    this.png2Bytes,
    super.key});

  @override
  State<CreatePresenter> createState() => _CreatePresenterState();
}

class _CreatePresenterState extends State<CreatePresenter> {
  String _id = '';
  String _name = '';
  String _contact = '';
  String _address = '';
  String _addressDetail = '';
    DateTime? _date = DateTime.now();
  String _size = '';
  String _cost = '';
  String _numOfCar = '91루0799';
  String _type = '분뇨';
  Uint8List? _png1Bytes;
  Uint8List? _png2Bytes;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _addressDetailController = TextEditingController();
  TextEditingController _sizeController = TextEditingController();
  TextEditingController _costController = TextEditingController();
  final TextEditingController _typeAheadController = TextEditingController();
  List<String> _suggestionAddress = [];
  final List<String> _addressList = [
    '강원도 영월군 영월읍 거운리',
    '강원도 영월군 영월읍 덕포리',
    '강원도 영월군 영월읍 문산리',
    '강원도 영월군 영월읍 방절리',
    '강원도 영월군 영월읍 삼옥리',
    '강원도 영월군 영월읍 영흥리',
    '강원도 영월군 영월읍 하송리',
    '강원도 영월군 영월읍 팔괴리',
    '강원도 영월군 영월읍 흥월리',
    '강원도 영월군 상동읍 구래리',
    '강원도 영월군 상동읍 내덕리',
    '강원도 영월군 산솔면 녹전리',
    '강원도 영월군 산솔면 연상리',
    '강원도 영월군 산솔면 이목리',
    '강원도 영월군 산솔면 직동리',
    '강원도 영월군 산솔면 화목리',
    '강원도 영월군 김삿갓면 각동리',
    '강원도 영월군 김삿갓면 내리',
    '강원도 영월군 김삿갓면 대야리',
    '강원도 영월군 김삿갓면 예밀리',
    '강원도 영월군 김삿갓면 옥동리',
    '강원도 영월군 김삿갓면 와석리',
    '강원도 영월군 김삿갓면 와룡리',
    '강원도 영월군 김삿갓면 주문리',
    '강원도 영월군 김삿갓면 진별리',
    '강원도 영월군 북면 공기리',
    '강원도 영월군 북면 덕상리',
    '강원도 영월군 북면 마차리',
    '강원도 영월군 북면 문곡리',
    '강원도 영월군 북면 연덕리',
    '강원도 영월군 남면 연당리',
    '강원도 영월군 남면 창원리',
    '강원도 영월군 남면 토쿄리',
    '강원도 영월군 남면 조전리',
    '강원도 영월군 남면 광천리',
    '강원도 영월군 남면 북쌍리',
    '강원도 영월군 한반도면 광전리',
    '강원도 영월군 한반도면 신천리',
    '강원도 영월군 한반도면 쌍용리',
    '강원도 영월군 한반도면 옹정리',
    '강원도 영월군 한반도면 후탄리',
    '강원도 영월군 주천면 금마리',
    '강원도 영월군 주천면 도천리',
    '강원도 영월군 주천면 신일리',
    '강원도 영월군 주천면 용석리',
    '강원도 영월군 주천면 주천리',
    '강원도 영월군 주천면 판운리',
    '강원도 영월군 무릉도원면 도원리',
    '강원도 영월군 무릉도원면 두산리',
    '강원도 영월군 무릉도원면 무릉리',
    '강원도 영월군 무릉도원면 법흥리',
    '강원도 영월군 무릉도원면 운학리',
  ];
  final SignatureController _sign1Controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );
  final SignatureController _sign2Controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );
  final List<String> _numOfCarList = ['91루0799', '89보7775', '80마3320'];
  final List<String> _typeList = ['분뇨', '정화조', '오수처리시설'];

  @override
  void initState() {
    super.initState();

    _initTempData();
  }

  /// 임시저장 데이터 있는 경우 불러오기
  void _initTempData() async {
    setState(() {
      /// 메인화면 확인서 목록에서 넘어온 경우 초기값 셋팅해주기
      _id = widget.id ?? '';
      _nameController.text = widget.name ?? '';
      _contactController.text = widget.contact ?? '';
      _address = widget.address ?? '';
      _addressDetailController.text = widget.addressDetail ?? '';
      _date = DateTime.parse(widget.date ?? DateTime.now().toString());
      _sizeController.text = widget.size ?? '';
      _costController.text = widget.cost ?? '';
      _type = widget.type ?? '분뇨';
      _numOfCar = widget.numOfCar ?? '91루0799';
      _png1Bytes = widget.png1Bytes ?? Uint8List(1);
      _png2Bytes = widget.png2Bytes ?? Uint8List(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CreateView(
      id: _id,
      name: _name,
      contact: _contact,
      address: _address,
      addressDetail: _addressDetail,
      date: _date!,
      size: _size,
      cost: _cost,
      numOfCar: _numOfCar,
      numOfCarList: _numOfCarList,
      typeList: _typeList,
      nameController: _nameController,
      contactController: _contactController,
      addressDetailController: _addressDetailController,
      sizeController: _sizeController,
      costController: _costController,
      png1Bytes: _png1Bytes ?? Uint8List(1),
      png2Bytes: _png2Bytes ?? Uint8List(1),
      type: _type,
      viewMode: widget.viewMode ?? false,
      onTapTempSave: () => _onTapTempSave(),
      onTapCancel: () => _onTapCancel(),
      onTapPickDate: () => _onTapPickDate(),
      onTapSearchAddress: () => _onTapSearchAddress(),
      onChangedNumOfCar: (value) => _onChangedNumOfCar(value),
      onChangedType: (value) => _onChangedType(value),
      onTapCalendar: () => _onTapCalendar(),
      onTapSignature: (title) => _onTapSignature(title),
    );
  }

  void _onTapTempSave() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String saveYear = _date!.year.toString();
    String saveMonth = _date!.month < 10
        ? '0${_date!.month}'
        : _date!.month.toString();
    String saveDay = _date!.day < 10
        ? '0${_date!.day}'
        : _date!.day.toString();

    /// 확인서 목록용 리스트 저장
    List<String>? savedList = prefs.getStringList('savedList');
    Map<String, String> savedMap = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'name': _nameController.text,
      'contact': _contactController.text.length == 11
          ? '${_contactController.text.substring(0, 3)}-${_contactController.text.substring(3, 7)}-${_contactController.text.substring(7, 11)}'
          : _contactController.text,
      'address': _address,
      'address_detail': _addressDetailController.text,
      'date': '$saveYear$saveMonth$saveDay',
      'size': _sizeController.text,
      'cost': _costController.text,
      'numOfCar': _numOfCar,
      'type': _type,
      'saveType': 'tmp',
      'sign1': String.fromCharCodes(_png1Bytes ?? Uint8List(1)),
      'sign2': String.fromCharCodes(_png2Bytes ?? Uint8List(1)),
    };

    if (savedList == null) {
      savedList = [];
      savedList.add(json.encode(savedMap));
      prefs.setStringList('savedList', savedList);
    } else {

      /// 기존에 임시저장했던 데이터가 있다면 그건 삭제처리
      if (_id.isNotEmpty) {
        for (int i = 0; i < savedList.length; i++) {
          if (savedList[i].contains(_id)) {
            savedList.removeAt(i);
          }
        }
      }

      savedList.add(json.encode(savedMap));
      prefs.setStringList('savedList', savedList);
    }

    Fluttertoast.showToast(msg: '임시저장 되었습니다.');
    Get.back();
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
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _onTapSearchAddress() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('주소'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TypeAheadFormField(
                noItemsFoundBuilder:(context){
                  return const ListTile(
                    title: Text("검색 결과 없음", style: TextStyle(color: Color(0xffc8c8c8), fontWeight: FontWeight.w600, fontSize: 18),),
                  );
                },
                textFieldConfiguration: TextFieldConfiguration(
                  style: const TextStyle(color: Color(0xff333333), fontWeight: FontWeight.w500, fontSize: 18),
                  autofocus: true,
                  onChanged: (String val){
                    setState(() {
                      _suggestionAddress = [];
                      _searchSchool(val);
                      // .then((value) {
                      //   if (value != null) value.forEach((item) => _suggestionAddress.add("$item"));
                      // });
                    });
                  },
                  controller: _typeAheadController,
                  decoration: InputDecoration(
                    hintText: "해당리를 검색하여 선택합니다.",
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 16),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xffdedede), width: 2),),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xfffa5f00), width: 2),),
                  ),
                ),
                suggestionsCallback: (pattern) {
                  return _suggestionAddress;
                },
                itemBuilder: (context, suggestion) {
                  List<String> school = suggestion.toString().split("/");
                  if(school.length>=2){
                    return ListTile(
                      title: Text(school[0], style: const TextStyle(color: Color(0xff333333), fontWeight: FontWeight.w500, fontSize: 18),),
                      subtitle: Text(school[1], style: const TextStyle(color: Color(0xff8d8d8d), fontWeight: FontWeight.w400, fontSize: 14),),
                    );
                  }
                  return ListTile(
                    title: Text(suggestion.toString()),
                  );
                },
                transitionBuilder: (context, suggestionsBox, controller) {
                  return suggestionsBox;
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _address = suggestion;
                  });
                  Get.back();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return '주소를 입력해주세요.';
                  }
                  return null;
                },
                onSaved: (value) {},
              ),
            ],
          ),
        );
      }
    );
  }

  _searchSchool(String val) {
    for(int i = 0; i < _addressList.length; i++) {
      if (_addressList[i].contains(val)) {
        _suggestionAddress.add(_addressList[i]);
      }
    }
  }

  void _onChangedNumOfCar(value) {
    setState(() {
      _numOfCar = value;
    });
  }

  void _onChangedType(value) {
    setState(() {
      _type = value;
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
                      child: const Text(
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
                        FocusManager.instance.primaryFocus?.unfocus();
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
