import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String postCode = '-';
  String address = '-';
  String latitude = '-';
  String longitude = '-';
  String kakaoLatitude = '-';
  String kakaoLongitude = '-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Text('postCode',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('result: ${this.postCode}'),
                  Text('address',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('result: ${this.address}'),
                  Text('LatLng', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'latitude: ${this.latitude} / longitude: ${this.longitude}'),
                  Text('through KAKAO Geocoder',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'latitude: ${this.kakaoLatitude} / longitude: ${this.kakaoLongitude}'),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KpostalView(
                      useLocalServer: true,
                      localPort: 1024,
                      // kakaoKey: '{Add your KAKAO DEVELOPERS JS KEY}',
                      callback: (Kpostal result) {
                        setState(() {
                          this.postCode = result.postCode;
                          this.address = result.address;
                          this.latitude = result.latitude.toString();
                          this.longitude = result.longitude.toString();
                          this.kakaoLatitude = result.kakaoLatitude.toString();
                          this.kakaoLongitude = result.kakaoLongitude.toString();
                        });
                      },
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
              child: Text(
                'Search Address',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
