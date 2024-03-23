// ignore_for_file: avoid_print

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_example/services/database_service.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();

  String selectedLanguage = '한국어'; // 기본 선택 언어

  TextEditingController speakerNumController =
      TextEditingController(); // 텍스트 필드 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Picker"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // 음성 파일 가져오기
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                );
                if (result != null) {
                  // 선택한 파일 처리
                  final file = result.files.first;
                  print('파일 이름 : ${file.name}');
                  print('파일 경로 : ${file.path}');
                  // 업로드 작업 생성!!
                  // UploadTask는 Firestore에 올리는 건가
                  FirebaseStorage storage = FirebaseStorage.instance;
                  Reference ref = storage.ref("input/${file.name}");
                  Task task = ref.putFile(File(file.path!));

                  // 업로드 완료
                  await task.whenComplete(() => print("업로드 성공!!!!"));

                  // 파일 재생인데 지금은 불필요 해서 주석 처리.
                  // openFile(file);
                } else {
                  // 파일 선택 취소
                }
              },
              child: const Text("음성 파일 선택"),
            ),
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

  Future<void> uploadFile(String? filePath, String fileName) async {
    // Firebase Storage 인스턴스 생성
    final storage = FirebaseStorage.instance;

    // 파일 참조 만들기
    final ref = storage.ref().child(fileName);

    // 파일 업로드
    final task = ref.putFile(File(filePath!));

    // 업로드 진행률 모니터링 (옵션)
    task.snapshotEvents.listen((snapshot) {
      print('Progress: ${snapshot.bytesTransferred} / ${snapshot.totalBytes}');
    });

    // 업로드 완료
    await task.whenComplete(() => print('Upload complete'));
  }

  void openFile(PlatformFile file) {
    OpenFile.open(file.path!);
  }
}
