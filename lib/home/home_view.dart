import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttttttt/create/create_presenter.dart';
import 'package:excel/excel.dart' as e;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String>? _savedList;

  @override
  void initState() {
    loadSavedList();
    super.initState();
  }

  void loadSavedList() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _savedList = prefs.getStringList('savedList');
      _savedList ??= [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              '분뇨 수집•운반 수수료 확인서 목록',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(),
                Container(
                  height: 40,
                  padding: const EdgeInsets.only(right: 10),
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      saveExcel();
                    }, //widget.onTapCreate(),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.green)),
                    child: const Text(
                      '엑셀 일괄다운로드',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  padding: const EdgeInsets.only(right: 10),
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => loadSavedList(),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.grey)),
                    child: const Icon(
                      Icons.refresh,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () async {
                      Get.to(() => CreatePresenter())!.then((_) async {
                        final prefs = await SharedPreferences.getInstance();

                        setState(() {
                          _savedList = prefs.getStringList('savedList');
                          _savedList ??= [];
                        });
                      });
                    }, //widget.onTapCreate(),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF0005D0))),
                    child: const Text(
                      '신규 확인서 작성',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            _savedList == null
                ? const CircularProgressIndicator()
                : _savedList!.isEmpty
                    ? Center(
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: const Text('아직 저장된 데이터가 없습니다.')))
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade200,
                            ),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSavedListTitle('저장', 1),
                                _buildSavedListTitle('구분', 1),
                                _buildSavedListTitle('날짜', 2),
                                _buildSavedListTitle('소유자', 2),
                                _buildSavedListTitle('수거장소', 3),
                                _buildSavedListTitle('용량', 1),
                                _buildSavedListTitle('비용', 2),
                              ],
                            ),
                          ),
                          Flexible(
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              reverse: true,
                              itemCount: _savedList!.length,
                              itemBuilder: (BuildContext context, int index) {
                                Map<String, dynamic> data =
                                    json.decode(_savedList![index]);
                                return GestureDetector(
                                  onTap: () => Get.to(
                                    () => CreatePresenter(
                                      id: '${data['id'] ?? ''}',
                                      name: '${data['name']}',
                                      contact: '${data['contact']}',
                                      address: '${data['address']}',
                                      addressDetail:
                                          '${data['address_detail']}',
                                      date:
                                          '${data['date'].substring(0, 4)}-${data['date'].substring(4, 6)}-${data['date'].substring(6, 8)}',
                                      size: '${data['size']}',
                                      cost: '${data['cost']}',
                                      viewMode: data['saveType'] == 'save'
                                          ? true
                                          : false,
                                      numOfCar: '${data['numOfCar']}',
                                      type: '${data['type']}' ?? '분뇨',
                                      png1Bytes: data['sign1'] != null ? Uint8List.fromList(
                                          data['sign1'].codeUnits) : Uint8List(1),
                                      png2Bytes: data['sign2'] != null ? Uint8List.fromList(
                                          data['sign2'].codeUnits) : Uint8List(1),
                                    ),
                                  )!.then((_) async {
                                    final prefs = await SharedPreferences.getInstance();

                                    setState(() {
                                      _savedList = prefs.getStringList('savedList');
                                      _savedList ??= [];
                                    });
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: data['saveType'] == 'save'
                                          ? const Color(0x000005d0)
                                              .withOpacity(0.05)
                                          : Colors.redAccent.withOpacity(0.05),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildSavedListDescription(
                                            data['saveType'] == 'save'
                                                ? '저장'
                                                : '임시',
                                            1),
                                        _buildSavedListDescription(
                                            data['type'] != null ? '${data['type']}'.substring(0, 2)
                                            : '',
                                            1),
                                        _buildSavedListDescription(
                                            '${data['date']}', 2),
                                        _buildSavedListDescription(
                                            '${data['name']}', 2),
                                        _buildSavedListDescription(
                                            '${data['address']}'
                                                .replaceAll('강원도 영월군', ''),
                                            3),
                                        _buildSavedListDescription(
                                            '${data['size']}', 1),
                                        _buildSavedListDescription(
                                            '${data['cost']}', 2),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedListTitle(String title, int flex) {
    return Expanded(
        flex: flex,
        child: Container(
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )));
  }

  Widget _buildSavedListDescription(String title, int flex) {
    return Expanded(
        flex: flex,
        child: Container(alignment: Alignment.center, child: Text(title)));
  }

  void saveExcel() async {
    final dir = Directory('/storage/emulated/0/Documents');

    String year = DateTime.now().year.toString();
    String month = DateTime.now().month < 10
        ? '0${DateTime.now().month}'
        : DateTime.now().month.toString();
    File file = File('${dir.path}/$year$month.xlsx');

    try {
      /// 기존 월에 해당하는 엑셀이 있는 경우
      if (await file.exists()) {
        file.delete();
      }

      /// 빈 엑셀파일 생성
      var excel = e.Excel.createExcel();

      List<Map<String, String>> rowInfo = [];

      /// 시트 만들기
      for (int i = 0; i < _savedList!.length; i++) {

        Map<String, dynamic> data = json.decode(_savedList![i]);

        if (data['saveType'] == 'save') {

          String currentYearMonth = data['date'].substring(0, 6);
          e.Sheet sheetObject = excel[currentYearMonth];

          /// 최상단 정보
          List<dynamic> raw = [
            "성명(소유자•관리자)".toString(),
            "연락처(전화번호)".toString(),
            "주소(수거장소)".toString(),
            "구분".toString(),
            "수거•확인일".toString(),
            "분뇨수거용량(톤, ㎥)".toString(),
            "수수료 납부액(천원)".toString(),
            "차량번호".toString(),
          ];

          /// 최상단 정보 및 행 추가
          sheetObject.insertRowIterables(raw, 0);
          rowInfo.add({
            'yearMonth': currentYearMonth,
            'savedRow': '0',
          });
        }
      }

      /// 각 시트별로 데이터 넣기
      for (int i = 0; i < _savedList!.length; i++) {

        Map<String, dynamic> data = json.decode(_savedList![i]);

        if (data['saveType'] == 'save') {
          /// 추가할 행 정리
          List<dynamic> addData = [
            data['name'],
            data['contact'].length == 11
                ? '${data['contact'].substring(0, 3)}-${data['contact']
                .substring(3, 7)}-${data['contact'].substring(7, 11)}'
                : data['contact'],
            '${data['address']} ${data['addressDetail']}',
            data['type'],
            '${data['date'].substring(0, 4)}년 ${data['date'].substring(
                4, 6)}월 ${data['date'].substring(6, 8)}일',
            '${data['size']}',
            '${data['cost']}천원',
            data['numOfCar'],
          ];

          /// 해당 연월 시트에 데이터 쌓기
          for(int j = 0; j < rowInfo.length; j++) {
            if (data['date'].substring(0, 6) == rowInfo[j]['yearMonth']) {
              int savedRow = int.parse(rowInfo[j]['savedRow']!);
              excel[data['date'].substring(0, 6)].insertRowIterables(addData, ++savedRow);
              rowInfo[j] = {
                'yearMonth': data['date'].substring(0, 6),
                'savedRow': '$savedRow',
              };
            }
          }
          /// 디폴트 시트 설정 (가장 최신 시트가 열리게끔)
          excel.setDefaultSheet('${data['date'].substring(0, 6)}');
        }

        /// auto column width
        for (int j = 0; j < excel[data['date'].substring(0, 6)].maxCols; j++) {
          excel[data['date'].substring(0, 6)].setColAutoFit(j);
        }
      }

      /// Sheet1 시트 삭제처리
      excel.delete('Sheet1');

      /// 결과 저장
      List<int>? result = excel.encode();
      File('${dir.path}/$year$month.xlsx')
        ..createSync(recursive: true)
        ..writeAsBytesSync(result!);

    } catch (e) {
      setState(() {
        // errorMessage = 'excel!!! >>> $e';
      });
    }
  }
}
