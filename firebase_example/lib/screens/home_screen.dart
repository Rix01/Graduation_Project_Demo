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
            Text(
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
