import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kpostal/kpostal.dart';
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
      body: Column(
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
          Container(
            padding: const EdgeInsets.only(right: 20),
            width: double.infinity,
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () async {
                await Get.to(() => CreatePresenter());
                final prefs = await SharedPreferences.getInstance();

                setState(() {
                  _savedList = prefs.getStringList('savedList');
                  _savedList ??= [];
                });
              }, //widget.onTapCreate(),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF0005D0))),
              child: const Text(
                '신규 확인서 작성',
                style: TextStyle(color: Colors.white),
              ),
            ),
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
                              _buildSavedListTitle('번호', 1),
                              _buildSavedListTitle('날짜', 2),
                              _buildSavedListTitle('소유자', 2),
                              _buildSavedListTitle('수거장소', 3),
                              _buildSavedListTitle('용량', 1),
                              _buildSavedListTitle('비용', 2),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Get.height * 0.6,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  // physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  reverse: true,
                                  itemCount: _savedList!.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    Map<String, dynamic> data =
                                        json.decode(_savedList![index]);
                                    return GestureDetector(
                                      onTap: () => Get.to(() => CreatePresenter(
                                            name: '${data['name']}',
                                            contact: '${data['contact']}',
                                            address: '${data['address']}',
                                            addressDetail:
                                                '${data['address_detail']}',
                                            date:
                                                '${data['date'].substring(0, 4)}-${data['date'].substring(4, 6)}-${data['date'].substring(6, 8)}',
                                            size: '${data['size']}',
                                            cost: '${data['cost']}',
                                            viewMode: true,
                                          )),
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color:
                                              const Color(0x000005d0).withOpacity(0.05),
                                        ),
                                        child: Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildSavedListDescription(
                                                '${index + 1}', 1),
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
                        ),
                      ],
                    ),
          // TextButton(
          //   child: Text('삭제 테스트'),
          //   onPressed: () async {
          //     final prefs = await SharedPreferences.getInstance();
          //     prefs.remove('savedList');
          //   },
          // )
        ],
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
