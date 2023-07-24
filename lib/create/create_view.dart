import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class CreateView extends StatelessWidget {
  String name;
  String contact;
  String address;
  String addressDetail;
  String type;
  List<String> typeList;
  DateTime date;
  String size;
  String cost;
  String numOfCar;
  final numOfCarList;
  Uint8List png1Bytes;
  Uint8List png2Bytes;
  TextEditingController nameController;
  TextEditingController contactController;
  TextEditingController addressDetailController;
  TextEditingController sizeController;
  TextEditingController costController;
  Function onTapSave;
  Function onTapTempSave;
  Function onTapCancel;
  Function onTapPickDate;
  Function onTapSearchAddress;
  Function onChangedNumOfCar;
  Function onTapCalendar;
  // Function onTapSignature;

  CreateView(
      {required this.name,
      required this.contact,
      required this.address,
      required this.addressDetail,
      required this.type,
      required this.typeList,
      required this.date,
      required this.size,
      required this.cost,
      required this.numOfCar,
      required this.numOfCarList,
      required this.png1Bytes,
      required this.png2Bytes,
      required this.nameController,
      required this.contactController,
      required this.addressDetailController,
      required this.sizeController,
      required this.costController,
      required this.onTapSave,
      required this.onTapTempSave,
      required this.onTapCancel,
      required this.onTapPickDate,
      required this.onTapSearchAddress,
      required this.onChangedNumOfCar,
      required this.onTapCalendar,
      // required this.onTapSignature,
      super.key});

  final pdf = pw.Document();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              '분뇨 수집•운반 수수료 확인서',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            _buildInputArea('성명(소유자•관리자)', 'text', controller: nameController),
            _buildInputArea('연락처', 'text', controller: contactController),
            _buildInputArea('주소(수거장소)', 'address'),
            _buildInputArea('상세주소', 'text',
                controller: addressDetailController),
            _buildInputArea('구분', 'type'),
            _buildInputArea('수거•확인일', 'calendar'),
            _buildInputArea('분뇨수거용량(L)', 'text', controller: sizeController),
            _buildInputArea('수수료 납부금액', 'text', controller: costController),
            _buildInputArea('차량번호', 'select'),
            SizedBox(height: 20),
            _buildExtraInfo(),
            _buildSignatureArea('분뇨수집운반업체', () => onTapSignature('분뇨수집운반업체')),
            SizedBox(height: 10),
            _buildSignatureArea(
                '개인하수처리시설\n소유자', () => onTapSignature('개인하수처리시설\n소유자')),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buttonWidget('저장', Color(0xFF0005D0), () => onTapSave()),
                _buttonWidget('임시저장', Color(0xFF0005D0), () => onTapTempSave()),
                _buttonWidget('취소', Colors.grey, () => onTapCancel()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onTapSignature(String s) {
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(
              height: 50,
            ),
            pw.Text(
              '분뇨 수집•운반 수수료 확인서',
              style: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(
              height: 20,
            ),
            // _buildInputArea('성명(소유자•관리자)', 'text', controller: nameController),
            // _buildInputArea('연락처', 'text', controller: contactController),
            // _buildInputArea('주소(수거장소)', 'address'),
            // _buildInputArea('상세주소', 'text',
            //     controller: addressDetailController),
            // _buildInputArea('구분', 'type'),
            // _buildInputArea('수거•확인일', 'calendar'),
            // _buildInputArea('분뇨수거용량(L)', 'text', controller: sizeController),
            // _buildInputArea('수수료 납부금액', 'text', controller: costController),
            // _buildInputArea('차량번호', 'select'),
            // pw.SizedBox(height: 20),
            // _buildExtraInfo(),
            // _buildSignatureArea('분뇨수집운반업체', () => onTapSignature('분뇨수집운반업체')),
            // pw.SizedBox(height: 10),
            // _buildSignatureArea(
            //     '개인하수처리시설\n소유자', () => onTapSignature('개인하수처리시설\n소유자')),
            // pw.SizedBox(height: 20),
            // pw.Row(
            //   mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            //   children: [
            //     _buttonWidget('저장', Color(0xFF0005D0), () => onTapSave()),
            //     _buttonWidget('임시저장', Color(0xFF0005D0), () => onTapTempSave()),
            //     _buttonWidget('취소', Colors.grey, () => onTapCancel()),
            //   ],
            // ),
          ],
        );
      }
    ),
    );

    Share.shareXFiles([XFile(pdf)]);
  }

  Widget _buttonWidget(String title, Color color, Function onTap) {
    return TextButton(
      onPressed: () => onTap(), // onTapCreate(),
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(color)),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSignatureArea(String title, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.0),
        child: Row(
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                )),
            Expanded(
              child: Container(
                color: Colors.grey.shade100,
                alignment: Alignment.centerRight,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    if (title == '분뇨수집운반업체')
                      png1Bytes.length != Uint8List(1).length
                          ? Image.memory(
                              png1Bytes,
                              width: 150,
                              height: 80,
                            )
                          : const SizedBox(),
                    if (title != '분뇨수집운반업체')
                      png2Bytes.length != Uint8List(1).length
                          ? Image.memory(
                              png2Bytes,
                              width: 150,
                              height: 80,
                            )
                          : const SizedBox(),
                    const Text('(서명)',
                        style: TextStyle(
                          fontSize: 16,
                          height: 2,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraInfo() {
    return Column(
      children: [
        const Text(
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.5,
            ),
            '위 기재 사항이 사실과 다름없음을 확인하고\n아래와 같이 서명합니다.\n* 수거업자 준수사항 위반 시 관련법에 따라 처분될 수 있음\n'),
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              RichText(
                textAlign: TextAlign.end,
                text: const TextSpan(
                  text: '문의 : 영월군 환경위생과 ☎ ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '370-2337',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            '${date.year}년 ${date.month}월 ${date.day}일',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea(String title, String type,
      {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
              flex: 3,
              child: SizedBox(
                height: 32,
                child: Container(
                  // height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    border: Border.all(),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              )),
          Flexible(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(),
                    top: BorderSide(),
                    right: BorderSide(),
                  ),
                ),
                // alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 30,
                  child: type == 'text'
                      ? TextField(
                          controller: controller!,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 5,
                            ),
                          ),
                          cursorColor: Colors.black,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        )
                      : type == 'address'
                          ? GestureDetector(
                              onTap: () {
                                onTapSearchAddress();
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: double.infinity,
                                color: Colors.yellowAccent.withOpacity(0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  child: Text(
                                    address,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : type == 'type'
                              ? Container(
                                  alignment: Alignment.centerLeft,
                                  // width: 200,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text('분뇨'),
                                              Radio(
                                                value: '분뇨',
                                                groupValue: typeList,
                                                onChanged: (value) {
                                                  type = value as String;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text('정화'),
                                              Radio(
                                                value: '정화조',
                                                groupValue: typeList,
                                                onChanged: (value) {
                                                  type = value as String;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text('오수'),
                                              Radio(
                                                value: '오수처리시설',
                                                groupValue: typeList,
                                                onChanged: (value) {
                                                  type = value as String;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : type == 'calendar'
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: GestureDetector(
                                        onTap: () => onTapCalendar(),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                                '${date.year}년 ${date.month}월 ${date.day}일'),
                                            Icon(
                                              Icons.calendar_month,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : type == 'select'
                                      ? SizedBox(
                                          width: double.infinity,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            child: DropdownButton<String>(
                                              elevation: 8,
                                              value: numOfCar,
                                              underline: SizedBox(),
                                              isExpanded: true,
                                              onChanged: (String? value) =>
                                                  onChangedNumOfCar(value),
                                              items: numOfCarList.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                ),
              )),
        ],
      ),
    );
  }
}
