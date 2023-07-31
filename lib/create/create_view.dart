import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:excel/excel.dart' as e;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateView extends StatefulWidget {
  String name;
  String contact;
  String address;
  String addressDetail;
  DateTime date;
  String size;
  String cost;
  String numOfCar;
  final numOfCarList;
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
  Function onTapCalendar;
  Function onTapSignature;

  CreateView(
      {required this.name,
      required this.contact,
      required this.address,
      required this.addressDetail,
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
      this.viewMode,
      // required this.onTapSave,
      required this.onTapTempSave,
      required this.onTapCancel,
      required this.onTapPickDate,
      required this.onTapSearchAddress,
      required this.onChangedNumOfCar,
      required this.onTapCalendar,
      required this.onTapSignature,
      super.key});

  @override
  State<CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> {
  late pw.Document pdf;
  String _type = '분뇨';

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
              _buildInputArea('연락처', 'text',
                  controller: widget.contactController),
              _buildInputArea('주소(수거장소)', 'address'),
              _buildInputArea('상세주소', 'text',
                  controller: widget.addressDetailController),
              _buildInputArea('구분', 'type'),
              _buildInputArea('수거•확인일', 'calendar'),
              _buildInputArea('분뇨수거용량(L)', 'text',
                  controller: widget.sizeController),
              _buildInputArea('수수료 납부금액', 'text',
                  controller: widget.costController),
              _buildInputArea('차량번호', 'select'),
              const SizedBox(height: 20),
              _buildExtraInfo(),
              _buildSignatureArea(
                  '분뇨수집운반업체', () => widget.onTapSignature('분뇨수집운반업체')),
              const SizedBox(height: 10),
              _buildSignatureArea('개인하수처리시설\n소유자',
                  () => widget.onTapSignature('개인하수처리시설\n소유자')),
              const SizedBox(height: 20),
              widget.viewMode!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buttonWidget(
                            '목록', Colors.grey, () => widget.onTapCancel()),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buttonWidget(
                            '저장', Color(0xFF0005D0), () => onTapSavePopup()),
                        _buttonWidget(
                            '임시저장',
                            Color(0xFF0005D0),
                            () => widget.onTapTempSave(
                                  _type,
                                )),
                        _buttonWidget(
                            '취소', Colors.grey, () => widget.onTapCancel()),
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
            title: Text('저장하기'),
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
                    _buttonWidget('저장', Color(0xFF0005D0), () {
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
                _buildPdfInputArea('연락처', widget.contactController.text, ttf),
                _buildPdfInputArea('주소(수거장소)', widget.address, ttf),
                _buildPdfInputArea(
                    '상세주소', widget.addressDetailController.text, ttf),
                _buildPdfInputArea('구분', _type, ttf),
                _buildPdfInputArea(
                    '수거•확인일',
                    '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
                    ttf),
                _buildPdfInputArea(
                    '분뇨수거용량(L)', '${widget.sizeController.text}L', ttf),
                _buildPdfInputArea(
                    '수수료 납부금액', '${widget.costController.text}원', ttf),
                _buildPdfInputArea('차량번호', widget.numOfCar, ttf),
                pw.SizedBox(height: 20),
                _buildPdfExtraInfo(ttf),
                _buildPdfSignatureArea('분뇨수집운반업체', ttf),
                _buildPdfSignatureArea('개인하수처리시설\n소유자', ttf),
              ],
            );
          }),
    );

    final bytes = await pdf.save();
    final dir = Directory('/storage/emulated/0/Documents');
    String year = DateTime.now().year.toString();
    String month = DateTime.now().month < 10
        ? '0${DateTime.now().month}'
        : DateTime.now().month.toString();
    String day = DateTime.now().day < 10
        ? '0${DateTime.now().day}'
        : DateTime.now().day.toString();
    final prefs = await SharedPreferences.getInstance();

    int? todayPdfNum = prefs.getInt('todayPdfNum');
    String? lastPdfNumDate = prefs.getString('todayPdfNumDate');
    String fileName = '';

    if (lastPdfNumDate == null) {
      /// 최초 저장시
      fileName = '$year$month${day}_1.pdf';
      prefs.setInt('todayPdfNum', 1);
      prefs.setString('todayPdfNumDate', '$year$month$day');
      debugPrint('>>> 최초 저장');
    } else {
      /// 마지막 저장일이 오늘인 경우 num만 올려줌
      if (lastPdfNumDate == '$year$month$day') {
        fileName = '$year$month${day}_${todayPdfNum! + 1}.pdf';
        prefs.setInt('todayPdfNum', todayPdfNum + 1);
        debugPrint('>>> 오늘 ${todayPdfNum + 1}번째 저장');
      } else if (lastPdfNumDate.compareTo('$year$month$day') < 0) {
        /// 마지막 저장일이 오늘보다 전인 경우
        fileName = '$year$month${day}_1.pdf';
        prefs.setInt('todayPdfNum', 1);
        prefs.setString('todayPdfNumDate', '$year$month$day');
        debugPrint('>>> 오늘 최초 저장');
      }
    }

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    /// 엑셀 만들기
    saveExcel();

    /// 임시저장 데이터 삭제
    await prefs.remove('name');
    await prefs.remove('contact');
    await prefs.remove('address');
    await prefs.remove('address_detail');
    await prefs.remove('type');
    await prefs.remove('date');
    await prefs.remove('size');
    await prefs.remove('cost');
    await prefs.remove('numOfCar');

    String saveYear = widget.date.year.toString();
    String saveMonth = widget.date.month < 10
        ? '0${widget.date.month}'
        : widget.date.month.toString();
    String saveDay = widget.date.day < 10
        ? '0${widget.date.day}'
        : widget.date.day.toString();

    /// 확인서 목록용 리스트 저장
    List<String>? savedList = prefs.getStringList('savedList');
    Map<String, String> savedMap = {
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
    };

    if (savedList == null) {
      savedList = [];
      savedList.add(json.encode(savedMap));
      prefs.setStringList('savedList', savedList);
    } else {
      savedList.add(json.encode(savedMap));
      prefs.setStringList('savedList', savedList);
    }
    setState(() {});
    Fluttertoast.showToast(msg: '저장 되었습니다.');
    Get.back();
  }

  void saveExcel() async {
    final dir = Directory('/storage/emulated/0/Documents');

    String year = DateTime.now().year.toString();
    String month = DateTime.now().month < 10
        ? '0${DateTime.now().month}'
        : DateTime.now().month.toString();
    File file = File('${dir.path}/$year$month.xlsx');

    /// 추가할 행 정리
    List<dynamic> addData = [
      widget.nameController.text,
      widget.contactController.text.length == 11
          ? '${widget.contactController.text.substring(0, 3)}-${widget.contactController.text.substring(3, 7)}-${widget.contactController.text.substring(7, 11)}'
          : widget.contactController.text,
      '${widget.address} ${widget.addressDetailController.text}',
      _type,
      '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
      '${widget.sizeController.text}L',
      '${widget.costController.text}원',
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
        "분뇨수거용량(L)".toString(),
        "수수료 납부금액".toString(),
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
          padding: const pw.EdgeInsets.symmetric(vertical: 24.0),
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
        const Text(
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.5,
            ),
            '위 기재 사항이 사실과 다름없음을 확인하고\n아래와 같이 서명합니다.\n* 수거업자 준수사항 위반 시 관련법에 따라 처분될 수 있음\n'),
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
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
            textAlign: TextAlign.center,
            style: const TextStyle(
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
                      ? title == '분뇨수거용량(L)' || title == '수수료 납부금액'
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
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                /// 연락처 입력일 때는 숫자와 하이픈만 사용 가능
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9]")),
                              ],
                            )
                          : title == '연락처'
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
                                                groupValue: _type,
                                                onChanged: (value) {
                                                  if (!widget.viewMode!) {
                                                    setState(() {
                                                      _type = value!;
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
                                                groupValue: _type,
                                                onChanged: (value) {
                                                  if (!widget.viewMode!) {
                                                    setState(() {
                                                      _type = value!;
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
                                                groupValue: _type,
                                                onChanged: (String? value) {
                                                  if (!widget.viewMode!) {
                                                    setState(() {
                                                      _type = value!;
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
                                      ? widget.viewMode!
                                          ? Container(
                                              alignment: Alignment.centerLeft,
                                              width: double.infinity,
                                              color: Colors.yellowAccent
                                                  .withOpacity(0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5.0),
                                                child: DropdownButton<String>(
                                                  elevation: 8,
                                                  value: widget.numOfCar,
                                                  underline: const SizedBox(),
                                                  isExpanded: true,
                                                  onChanged: (String? value) {
                                                    if (!widget.viewMode!) {
                                                      widget.onChangedNumOfCar(
                                                          value);
                                                    }
                                                  },
                                                  items: widget.numOfCarList
                                                      .map<
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
