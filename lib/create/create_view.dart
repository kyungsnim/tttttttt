import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class CreateView extends StatefulWidget {
  String id;
  String name;
  String contact;
  String address;
  String addressDetail;
  DateTime date;
  String size;
  String cost;
  String numOfCar;
  String type;
  final numOfCarList;
  final typeList;
  Uint8List png1Bytes;
  Uint8List png2Bytes;
  bool? viewMode;
  TextEditingController nameController;
  TextEditingController contactController;
  TextEditingController addressDetailController;
  TextEditingController sizeController;
  TextEditingController costController;

  // Function onTapSave;
  Function onTapTempSave;
  Function onTapCancel;
  Function onTapPickDate;
  Function onTapSearchAddress;
  Function onChangedNumOfCar;
  Function onChangedType;
  Function onTapCalendar;
  Function onTapSignature;
  Function onTapDelete;

  CreateView(
      {required this.id,
      required this.name,
      required this.contact,
      required this.address,
      required this.addressDetail,
      required this.date,
      required this.size,
      required this.cost,
      required this.numOfCar,
      required this.type,
      required this.numOfCarList,
      required this.typeList,
      required this.png1Bytes,
      required this.png2Bytes,
      required this.nameController,
      required this.contactController,
      required this.addressDetailController,
      required this.sizeController,
      required this.costController,
      this.viewMode,
      // required this.onTapSave,
      required this.onTapTempSave,
      required this.onTapCancel,
      required this.onTapPickDate,
      required this.onTapSearchAddress,
      required this.onChangedNumOfCar,
      required this.onChangedType,
      required this.onTapCalendar,
      required this.onTapSignature,
      required this.onTapDelete,
      super.key});

  @override
  State<CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> {
  late pw.Document pdf;

  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
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
              _buildInputArea('성명(소유자•관리자)', 'text',
                  controller: widget.nameController),
              _buildInputArea('연락처(전화번호)', 'text',
                  controller: widget.contactController),
              _buildInputArea('주소(수거장소)', 'address'),
              _buildInputArea('상세주소', 'text',
                  controller: widget.addressDetailController),
              _buildInputArea('구분', 'select'),
              _buildInputArea('수거•확인일', 'calendar'),
              _buildInputArea('분뇨수거용량(톤, ㎥)', 'text',
                  controller: widget.sizeController),
              _buildInputArea('수수료 납부액(천원)', 'text',
                  controller: widget.costController),
              _buildInputArea('차량번호', 'select'),
              const SizedBox(height: 20),
              _buildExtraInfo(),
              _buildSignatureArea(
                  '분뇨수집운반업체', () => widget.onTapSignature('분뇨수집운반업체')),
              const SizedBox(height: 10),
              _buildSignatureArea('개인하수처리시설\n소유•관리자',
                  () => widget.onTapSignature('개인하수처리시설\n소유•관리자')),
              const SizedBox(height: 20),
              widget.viewMode!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buttonWidget(
                            '목록', Colors.grey, () => widget.onTapCancel()),
                        SizedBox(width: 10),
                        _buttonWidget(
                            '삭제', Colors.red, () => widget.onTapDelete()),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buttonWidget('저장', const Color(0xFF0005D0),
                            () => onTapSavePopup()),
                        _buttonWidget('임시저장', const Color(0xFF0005D0),
                            () => widget.onTapTempSave()),
                        _buttonWidget(
                            '취소', Colors.grey, () => widget.onTapCancel()),
                        _buttonWidget(
                            '삭제', Colors.red, () => widget.onTapDelete()),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void onTapSavePopup() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('저장하기'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '저장한 이후에는 수정이 불가합니다.\n저장하시겠습니까?',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buttonWidget('저장', const Color(0xFF0005D0), () {
                      onTapSave();
                      Get.back();
                    }),
                    const SizedBox(width: 20),
                    _buttonWidget(
                        '취소', Colors.grey, () => widget.onTapCancel()),
                  ],
                )
              ],
            ),
          );
        });
  }

  void onTapSave() async {
    final fontData =
        await rootBundle.load('assets/fonts/Pretendard-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    /// pdf 파일 만들기
    pdf = pw.Document();
    pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(
                  height: 30,
                ),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        '분뇨 수집•운반 수수료 확인서',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          font: ttf,
                        ),
                      ),
                    ]),
                pw.SizedBox(
                  height: 20,
                ),
                _buildPdfInputArea(
                    '성명(소유자•관리자)', widget.nameController.text, ttf),
                _buildPdfInputArea(
                    '연락처(전화번호)', widget.contactController.text, ttf),
                _buildPdfInputArea('주소(수거장소)', widget.address, ttf),
                _buildPdfInputArea(
                    '상세주소', widget.addressDetailController.text, ttf),
                _buildPdfInputArea('구분', widget.type, ttf),
                _buildPdfInputArea(
                    '수거•확인일',
                    '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
                    ttf),
                _buildPdfInputArea(
                    '분뇨수거용량(톤, ㎥)', '${widget.sizeController.text}(톤, ㎥)', ttf),
                _buildPdfInputArea(
                    '수수료 납부액(천원)', '${widget.costController.text}천원', ttf),
                _buildPdfInputArea('차량번호', widget.numOfCar, ttf),
                pw.SizedBox(height: 20),
                _buildPdfExtraInfo(ttf),
                _buildPdfSignatureArea('분뇨수집운반업체', ttf),
                _buildPdfSignatureArea('개인하수처리시설\n소유•관리자', ttf),
              ],
            );
          }),
    );

    final bytes = await pdf.save();
    final dir = Directory('/storage/emulated/0/Documents');
    String fileName = '';
    final prefs = await SharedPreferences.getInstance();

    String year = widget.date.year.toString();
    String month = widget.date.month < 10
        ? '0${widget.date.month}'
        : widget.date.month.toString();
    String day = widget.date.day < 10
        ? '0${widget.date.day}'
        : widget.date.day.toString();

    /// 수거일자 저장번호 불러오기
    int? lastPdfNum = prefs.getInt('$year$month$day');

    if (lastPdfNum == null) {
      /// 해당 수거일자 데이터가 없는 경우
      fileName = '$year$month${day}_1.pdf';
      prefs.setInt('$year$month$day', 1);
    } else {
      fileName = '$year$month${day}_${lastPdfNum + 1}.pdf';
      prefs.setInt('$year$month$day', 1);
    }

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    /// 엑셀 만들기
    // saveExcel();

    String saveYear = widget.date.year.toString();
    String saveMonth = widget.date.month < 10
        ? '0${widget.date.month}'
        : widget.date.month.toString();
    String saveDay = widget.date.day < 10
        ? '0${widget.date.day}'
        : widget.date.day.toString();

    String sign1 = String.fromCharCodes(widget.png1Bytes);
    String sign2 = String.fromCharCodes(widget.png2Bytes);

    List<String>? savedList = [];
    Map<String, String> savedMap = {};

    /// 확인서 목록용 리스트 저장
    savedList = prefs.getStringList('savedList');
    savedMap = {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'name': widget.nameController.text,
      'contact': widget.contactController.text.length == 11
          ? '${widget.contactController.text.substring(0, 3)}-${widget.contactController.text.substring(3, 7)}-${widget.contactController.text.substring(7, 11)}'
          : widget.contactController.text,
      'address': widget.address,
      'address_detail': widget.addressDetailController.text,
      'date': '$saveYear$saveMonth$saveDay',
      'size': widget.sizeController.text,
      'cost': widget.costController.text,
      'numOfCar': widget.numOfCar,
      'type': widget.type,
      'saveType': 'save',
      'sign1': sign1,
      'sign2': sign2,
    };

    if (savedList == null || savedList.isEmpty) {
      savedList = [];
      savedList.add(json.encode(savedMap));
      prefs.setStringList('savedList', savedList);
    } else {
      try {
        if (widget.id.isNotEmpty) {
          for (int i = 0; i < savedList.length; i++) {
            if (savedList[i].contains(widget.id)) {
              savedList.removeAt(i);
            }
          }
        }
        savedList.add(json.encode(savedMap));
        prefs.setStringList('savedList', savedList);
      } catch (r) {
        setState(() {
          errorMessage += 'saveList3!!! >>> $r\n';
        });
      }
    }

    setState(() {});

    if (errorMessage.isEmpty) {
      Fluttertoast.showToast(msg: '저장 되었습니다.');
      Get.back();
    }
  }

  void saveExcel() async {
    final dir = Directory('/storage/emulated/0/Documents');

    String year = widget.date.year.toString();
    String month = widget.date.month < 10
        ? '0${widget.date.month}'
        : widget.date.month.toString();
    File file = File('${dir.path}/$year$month.xlsx');

    try {
      /// 추가할 행 정리
      List<dynamic> addData = [
        widget.nameController.text,
        widget.contactController.text.length == 11
            ? '${widget.contactController.text.substring(0, 3)}-${widget.contactController.text.substring(3, 7)}-${widget.contactController.text.substring(7, 11)}'
            : widget.contactController.text,
        '${widget.address} ${widget.addressDetailController.text}',
        widget.type,
        '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
        '${widget.sizeController.text}(톤, ㎥)',
        '${widget.costController.text}천원',
        widget.numOfCar,
      ];

      /// 기존 월에 해당하는 엑셀이 있는 경우
      if (await file.exists()) {
        /// 파일 읽기
        var bytes = file.readAsBytesSync();

        /// 엑셀파일로 열기
        var excel = e.Excel.decodeBytes(bytes);

        /// Sheet1 선택
        e.Sheet sheetObject = excel['Sheet1'];

        /// 가장 마지막 입력 row 확인
        int maxRow = sheetObject.maxRows;

        /// 행 추가
        sheetObject.insertRowIterables(addData, maxRow);

        /// 파일에 결과 저장
        List<int>? result = excel.encode();
        File('${dir.path}/$year$month.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(result!);
      } else {
        /// 빈 엑셀파일 생성
        var excel = e.Excel.createExcel();

        /// Sheet1 선택
        e.Sheet sheetObject = excel['Sheet1'];

        /// 최상단 정보
        List<dynamic> raw = [
          "성명(소유자•관리자)".toString(),
          "연락처".toString(),
          "주소(수거장소)".toString(),
          "구분".toString(),
          "수거•확인일".toString(),
          "분뇨수거용량(톤, ㎥)".toString(),
          "수수료 납부액(천원)".toString(),
          "차량번호".toString(),
        ];

        /// 최상단 정보 및 행 추가
        sheetObject.insertRowIterables(raw, 0);
        sheetObject.insertRowIterables(addData, 1);

        /// 결과 저장
        List<int>? result = excel.encode();
        File('${dir.path}/$year$month.xlsx')
          ..createSync(recursive: true)
          ..writeAsBytesSync(result!);
        File('${dir.path}/$year$month.xlsx');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'excel!!! >>> $e';
      });
    }
  }

  pw.Widget _buildPdfInputArea(String title, String description, pw.Font ttf) {
    /// pdf 생성용 widget
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8.0),
      child: pw.Row(
        children: [
          pw.Flexible(
            flex: 3,
            child: pw.SizedBox(
              height: 32,
              child: pw.Container(
                // height: 30,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                  border: pw.Border(
                    left: pw.BorderSide(),
                    bottom: pw.BorderSide(),
                    top: pw.BorderSide(),
                    right: pw.BorderSide(),
                  ),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: ttf,
                  ),
                ),
              ),
            ),
          ),
          pw.Expanded(
              flex: 5,
              child: pw.SizedBox(
                height: 32,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 5),
                  alignment: pw.Alignment.centerLeft,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(),
                      top: pw.BorderSide(),
                      right: pw.BorderSide(),
                    ),
                  ),
                  child: pw.Text(
                    title == '연락처' && description.length == 11
                        ? '${description.substring(0, 3)}-${description.substring(3, 7)}-${description.substring(7, 11)}'
                        : description,
                    style: pw.TextStyle(
                      fontSize: 14,
                      font: ttf,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  pw.Widget _buildPdfExtraInfo(pw.Font ttf) {
    return pw.Column(
      children: [
        pw.Text(
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              height: 1.5,
              font: ttf,
              fontSize: 14,
            ),
            '위 기재 사항이 사실과 다름없음을 확인하고\n아래와 같이 서명합니다.\n* 수거업자 준수사항 위반 시 관련법에 따라 처분될 수 있음\n'),
        pw.Padding(
          padding: const pw.EdgeInsets.only(
            right: 16.0,
            top: 20,
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.RichText(
                textAlign: pw.TextAlign.right,
                text: pw.TextSpan(
                  text: '문의 : 영월군 환경위생과 ',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.black,
                    font: ttf,
                  ),
                  children: const [
                    pw.TextSpan(
                      text: 'Tel.370-2337',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 24.0),
          child: pw.Text(
            '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              font: ttf,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12, bottom: 24.0),
          child: pw.Text(
            '영월군수 귀하',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              font: ttf,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfSignatureArea(String title, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 28.0),
      child: pw.Row(
        children: [
          pw.Text(title,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 24,
                font: ttf,
              )),
          pw.Expanded(
            child: pw.Container(
              color: PdfColors.white,
              alignment: pw.Alignment.centerRight,
              child: pw.Stack(
                alignment: pw.Alignment.centerRight,
                children: [
                  if (title == '분뇨수집운반업체')
                    widget.png1Bytes.length != Uint8List(1).length
                        ? pw.Image(
                            pw.MemoryImage(
                              widget.png1Bytes,
                            ),
                            width: 150,
                            height: 80,
                          )
                        : pw.SizedBox(),
                  if (title != '분뇨수집운반업체')
                    widget.png2Bytes.length != Uint8List(1).length
                        ? pw.Image(
                            pw.MemoryImage(
                              widget.png2Bytes,
                            ),
                            width: 150,
                            height: 80,
                          )
                        : pw.SizedBox(),
                  pw.Text('(서명)',
                      style: pw.TextStyle(
                        fontSize: 16,
                        height: 2,
                        font: ttf,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonWidget(String title, Color color, Function onTap) {
    return TextButton(
      onPressed: () => onTap(),
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
      onTap: () {
        if (!widget.viewMode!) {
          onTap();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Row(
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                      widget.png1Bytes.length != Uint8List(1).length
                          ? Image.memory(
                              widget.png1Bytes,
                              width: 150,
                              height: 80,
                            )
                          : const SizedBox(),
                    if (title != '분뇨수집운반업체')
                      widget.png2Bytes.length != Uint8List(1).length
                          ? Image.memory(
                              widget.png2Bytes,
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
        Text(
            textAlign: TextAlign.center,
            style: const TextStyle(
              height: 1.5,
            ),
            '위 기재 사항이 사실과 다름없음을 확인하고\n아래와 같이 서명합니다.\n* 수거업자 준수사항 위반 시 관련법에 따라 처분될 수 있음\n$errorMessage'),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
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
          padding: const EdgeInsets.only(top: 24.0),
          child: Text(
            '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 24.0),
          child: Text(
            '영월군수 귀하',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
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
                    border: const Border(
                      bottom: BorderSide(),
                      top: BorderSide(),
                      right: BorderSide(),
                      left: BorderSide(),
                    ),
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
                      ? title == '분뇨수거용량(톤, ㎥)' || title == '수수료 납부액(천원)'
                          ? TextField(
                              readOnly: widget.viewMode!,
                              autofocus: true,
                              textInputAction: TextInputAction.next,
                              // focusNode: FocusNode(),
                              onSubmitted: (value) {
                                FocusNode().nextFocus();
                              },
                              controller: controller!,
                              decoration: InputDecoration(
                                hintText: title == '수수료 납부액(천원)'
                                    ? '천원단위 입력'
                                    : '소수점 첫째자리까지 입력 가능',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 5,
                                ),
                              ),
                              cursorColor: Colors.black,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                /// 연락처 입력일 때는 숫자와 하이픈만 사용 가능
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"^[0-9]{0,9}.{0,2}")),
                              ],
                            )
                          : title == '연락처(전화번호)'
                              ? TextField(
                                  readOnly: widget.viewMode!,
                                  autofocus: true,
                                  textInputAction: TextInputAction.next,
                                  // focusNode: FocusNode(),
                                  onSubmitted: (value) {
                                    FocusNode().nextFocus();
                                  },
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
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true),
                                  inputFormatters: [
                                    /// 연락처 입력일 때는 숫자와 하이픈만 사용 가능
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9.-]")),
                                  ],
                                )
                              : TextField(
                                  readOnly: widget.viewMode!,
                                  autofocus: true,
                                  textInputAction: TextInputAction.next,
                                  // focusNode: FocusNode(),
                                  onSubmitted: (value) {
                                    FocusNode().nextFocus();
                                  },
                                  controller: controller!,
                                  decoration: InputDecoration(
                                    hintText:
                                        title == '상세주소' ? '도로명 주소 입력' : '',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
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
                                if (!widget.viewMode!) {
                                  widget.onTapSearchAddress();
                                }
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                width: double.infinity,
                                color: Colors.yellowAccent.withOpacity(0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0),
                                  child: Text(
                                    widget.address,
                                    style: const TextStyle(
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
                                              const Text('분뇨'),
                                              Radio(
                                                activeColor:
                                                    const Color(0xFF0005D0),
                                                value: '분뇨',
                                                groupValue: widget.type,
                                                onChanged: (value) {
                                                  if (!widget.viewMode!) {
                                                    setState(() {
                                                      widget.type = value!;
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Text('정화'),
                                              Radio(
                                                activeColor:
                                                    const Color(0xFF0005D0),
                                                value: '정화조',
                                                groupValue: widget.type,
                                                onChanged: (value) {
                                                  if (!widget.viewMode!) {
                                                    setState(() {
                                                      widget.type = value!;
                                                    });
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Text('오수'),
                                              Radio(
                                                activeColor:
                                                    const Color(0xFF0005D0),
                                                value: '오수처리시설',
                                                groupValue: widget.type,
                                                onChanged: (String? value) {
                                                  if (!widget.viewMode!) {
                                                    setState(() {
                                                      widget.type = value!;
                                                    });
                                                  }
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
                                        onTap: () {
                                          if (!widget.viewMode!) {
                                            widget.onTapCalendar();
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                                '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일'),
                                            const Icon(
                                              Icons.calendar_month,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : type == 'select'
                                      ? title == '차량번호'
                                          ? widget.viewMode!
                                              ? Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  width: double.infinity,
                                                  color: Colors.yellowAccent
                                                      .withOpacity(0),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5,
                                                        vertical: 0),
                                                    child: Text(
                                                      widget.numOfCar,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5.0),
                                                    child:
                                                        DropdownButton<String>(
                                                      elevation: 8,
                                                      value: widget.numOfCar,
                                                      underline:
                                                          const SizedBox(),
                                                      isExpanded: true,
                                                      onChanged:
                                                          (String? value) {
                                                        if (!widget.viewMode!) {
                                                          widget
                                                              .onChangedNumOfCar(
                                                                  value);
                                                        }
                                                      },
                                                      items: widget.numOfCarList
                                                          .map<
                                                              DropdownMenuItem<
                                                                  String>>((String
                                                              value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                )
                                          : widget.viewMode!
                                              ? Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  width: double.infinity,
                                                  color: Colors.yellowAccent
                                                      .withOpacity(0),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5,
                                                        vertical: 0),
                                                    child: Text(
                                                      widget.type,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5.0),
                                                    child:
                                                        DropdownButton<String>(
                                                      elevation: 8,
                                                      value: widget.type,
                                                      underline:
                                                          const SizedBox(),
                                                      isExpanded: true,
                                                      onChanged:
                                                          (String? value) {
                                                        if (!widget.viewMode!) {
                                                          widget.onChangedType(
                                                              value);
                                                        }
                                                      },
                                                      items: widget.typeList.map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                )
                                      : const SizedBox(),
                ),
              )),
        ],
      ),
    );
  }
}
