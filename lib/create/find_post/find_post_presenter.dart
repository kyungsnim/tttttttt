import 'package:flutter/material.dart';
import 'package:tttttttt/importer.dart';
import 'package:kpostal/kpostal.dart';

class FindPostPresenter extends StatefulWidget {
  FindPostPresenter({super.key});

  @override
  State<FindPostPresenter> createState() => _FindPostPresenterState();
}

class _FindPostPresenterState extends State<FindPostPresenter> {
  String postCode = '-';
  String address = '-';
  String latitude = '-';
  String longitude = '-';

  @override
  Widget build(BuildContext context) {
    return FindPostView(
      postCode: postCode,
      address: address,
      latitude: latitude,
      longitude: longitude,
      onTapSearch: () => _onTapSearch(),
    );
  }

  _onTapSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KpostalView(
          useLocalServer: true,
          localPort: 1024,
          // kakaoKey: '{Add your KAKAO DEVELOPERS JS KEY}',
          callback: (Kpostal result) {
            setState(() {
              postCode = result.postCode;
              address = result.address;
              latitude = result.latitude.toString();
              longitude = result.longitude.toString();
            });
          },
        ),
      ),
    );
  }
}
