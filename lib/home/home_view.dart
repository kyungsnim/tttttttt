import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';

class HomeView extends StatelessWidget {
  Function onTapCreate;

  HomeView({required this.onTapCreate, super.key});

  String postCode = '-';

  String address = '-';

  String latitude = '-';

  String longitude = '-';

  String kakaoLatitude = '-';

  String kakaoLongitude = '-';

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
              onPressed: () => onTapCreate(),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFF0005D0))),
              child: const Text(
                '신규 확인서 작성',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
