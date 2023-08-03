import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttttttt/create/create_presenter.dart';

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
                  padding: const EdgeInsets.only(right: 20),
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
}
