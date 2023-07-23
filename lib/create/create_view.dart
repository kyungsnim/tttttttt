import 'package:flutter/material.dart';

class CreateView extends StatelessWidget {
  Function onTapSave;
  Function onTapTempSave;
  Function onTapCancel;
  Function onTapPickDate;

  CreateView({
    required this.onTapSave,
    required this.onTapTempSave,
    required this.onTapCancel,
    required this.onTapPickDate,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        const Text(
          '분뇨 수집•운반 수수료 확인서 목록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Flexible(flex: 1, child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.all(),
              ),
              alignment: Alignment.center,
              child: Text('성명'),
            )),
            Flexible(flex: 1, child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(),
                  top: BorderSide(),
                  right: BorderSide(),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                ),
                // cursorHeight: 5,
                scrollPadding: EdgeInsets.zero,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buttonWidget('저장', Colors.blue, () => onTapSave()),
            _buttonWidget('임시저장', Colors.blue, () => onTapTempSave()),
            _buttonWidget('취소', Colors.grey, () => onTapCancel()),
          ],
        ),
      ],
    ));
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
}
