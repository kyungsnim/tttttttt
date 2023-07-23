import 'package:flutter/material.dart';

class FindPostView extends StatelessWidget {
  String postCode;
  String address;
  String latitude;
  String longitude;
  Function onTapSearch;

  FindPostView({
    required this.postCode,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.onTapSearch,
    super.key});

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
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                onTapSearch();
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
