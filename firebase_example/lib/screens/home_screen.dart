// ignore_for_file: avoid_print

import 'dart:io';

import 'package:file_picker/file_picker.dart';
// import 'package:firebase_example/services/database_service.dart';
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
  String selectedLanguage = '한국어'; // 기본 선택 언어

  TextEditingController speakerNumController =
      TextEditingController(); // 텍스트 필드 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Audio File"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add');
              },
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.black,
              ))
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "서버에 올릴 음성 파일을 선택하세요",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
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
                  await uploadFile(file);

                  // 파일 재생인데 지금은 불필요 해서 주석 처리.
                  // openFile(file);
                } else {
                  // 파일 선택 취소
                }
              },
              child: const Text("음성 파일 선택"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void openFile(PlatformFile file) {
    OpenFile.open(file.path!);
  }

  Future<void> uploadFile(PlatformFile file) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref("input/${file.name}");

    // 파일 이름 중복 체크
    String fileName = file.name;
    int count = 1;
    try {
      while (true) {
        await ref.getDownloadURL(); // 파일이 존재하는지 확인
        // 파일이 존재하면 파일 이름 변경
        fileName =
            '${file.name.split('.').first}($count).${file.name.split('.').last}';
        ref = storage.ref("input/$fileName");
        count++;
      }
    } catch (e) {
      // 파일이 존재하지 않을 때 예외 처리
      print("파일이 존재하지 않습니다.");
    }

    Task task = ref.putFile(File(file.path!));

    // 업로드 완료
    await task.whenComplete(() => print("업로드 성공!!!!!"));
  }
}
