import 'package:firebase_example/services/database_service.dart';
import 'package:flutter/material.dart';

class AddData extends StatefulWidget {
  const AddData({super.key});

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  final DatabaseService _databaseService = DatabaseService();

  String selectedLanguage = '한국어'; // 기본 선택 언어

  TextEditingController speakerNumController =
      TextEditingController(); // 텍스트 필드 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Data"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedLanguage,
              items: <String>['한국어', '영어'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: TextField(
                        controller: speakerNumController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '화자 수를 입력하세요',
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    onPressed: () {
                      // 텍스트 필드에서 숫자 가져오기
                      String number = speakerNumController.text;
                      // 선택한 언어와 숫자 출력
                      print('선택한 언어: $selectedLanguage');
                      print('입력한 숫자: $number');
                      // 여기에 필요한 로직 추가

                      // speakerNum 값을 정수로 변환
                      int speakerNum =
                          int.tryParse(number) ?? 0; // 정수로 변환할 수 없는 경우 0으로 설정

                      // Firebase에 데이터 저장
                      _databaseService.saveAudioInfo(
                        inputPath: "", // 파일 업로드 후의 경로를 여기에 대입
                        selecLang: selectedLanguage,
                        speakerNum: speakerNum,
                      );
                    },
                    child: const Text("전송"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
