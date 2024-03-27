// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  PlatformFile? file;

  DateTime currentTime = DateTime.now();

  addData(String input, String language, int speaker) async {
    FirebaseFirestore.instance.collection("audio_data").doc(file!.name).update({
      "selecLang": language,
      "speakerNum": speaker,
      "uploadTime": currentTime, // 현재 시간을 업로드 시간으로 설정
    }).then(
      (value) {
        print("데이터가 전송되었습니다!");
      },
    );
  }

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
            const SizedBox(height: 20),
            const Text(
              ">> 서버에 올릴 음성 파일을 선택하세요",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
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
                  file = result.files.first;
                  print('파일 이름 : ${file!.name}');
                  print('파일 경로 : ${file!.path}');
                  // 업로드 작업 생성!!
                  await uploadFile(file!);

                  // 파일 재생인데 지금은 불필요 해서 주석 처리.
                  // openFile(file);
                } else {
                  // 파일 선택 취소
                }
              },
              child: const Text("음성 파일 선택"),
            ),
            const SizedBox(height: 40),
            const Text(
              ">> 언어와 화자수를 입력하세요",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 20,
                    ),
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
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    // 음성 파일 경로 가져오기
                    FirebaseStorage storage = FirebaseStorage.instance;
                    final ref = storage.ref("input");
                    final listResult = await ref.list();

                    // 최근 업로드한 음성 파일 경로 얻기
                    final recentFileRef = listResult.items.first;
                    final recentFileURL = await recentFileRef.getDownloadURL();
                    print("최근 파일 경로: $recentFileURL");

                    // 텍스트 필드에서 숫자 가져오기
                    int speakerNum = int.parse(speakerNumController.text);

                    addData(recentFileURL, selectedLanguage, speakerNum);

                    // 선택한 언어와 숫자 출력
                    print('선택한 언어: $selectedLanguage');
                    print('입력한 숫자: $speakerNum');
                  },
                  child: const Text("전송"),
                ),
              ],
            ),
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

    //Task task = ref.putFile(File(file.path!));
    TaskSnapshot snapshot = await ref.putFile(File(file.path!));

    // 업로드 완료
    //await task.whenComplete(() => print("업로드 성공!!!!!"));

    // 업로드 이후 Firestore에 파일 이름 추가
    // 업로드 완료 후 Firestore에 파일 정보 추가
    String downloadURL = await snapshot.ref.getDownloadURL();
    addFileInfoToFirestore(fileName, downloadURL);

    print("업로드 성공!!!!!");
  }

  void addFileInfoToFirestore(String fileName, String downloadURL) {
    FirebaseFirestore.instance.collection("audio_data").doc(fileName).set({
      "fileName": fileName,
      "downloadURL": downloadURL,
      // 추가적으로 필요한 정보가 있으면 여기에 추가할 수 있습니다.
    }).then((value) {
      print("파일 정보가 Firestore에 추가되었습니다.");
    }).catchError((error) {
      print("Firestore에 파일 정보를 추가하는 중 오류 발생: $error");
    });
  }
}
