import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WordTestPage extends StatefulWidget {
  const WordTestPage({Key? key}) : super(key: key);

  @override
  _WordTestPageState createState() => _WordTestPageState();
}

class _WordTestPageState extends State<WordTestPage> {
  int questionCount = 1;
  int clearCount = 0;
  static const int testCount = 5; // 5問行う

  _checkResult({String data = '', String answer = ''}) async {
    var result = 0;
    if (data == '' || answer == '') {
      result = 1;
    }

    if (result == 1) {
      return await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('入力してください'),
            content: const Text('入力情報が不足しています。'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('ホームに戻る'),
                onPressed: () => Navigator.pushNamed(context, "/section5-home"),
              ),
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  return Navigator.of(context).pop(1);
                },
              ),
            ],
          );
        },
      );
    }

    if (result == 0) {
      // 正解カウント
      if (data == answer) {
        setState(() {
          clearCount++;
        });
      }

      // 正誤判定処理
      if (questionCount < testCount) {
        await showDialog<int>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(data == answer ? '正解！！' : '不正解...'),
              content: Text(data == answer ? '続けますか？' : '正解は${testDataList[questionCount - 1]['word']}でした'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('ホームに戻る'),
                  onPressed: () => Navigator.pushNamed(context, "/section5-home"),
                ),
                ElevatedButton(
                  child: const Text('次へ'),
                  onPressed: () {
                    setState(() {
                      questionCount++;
                      _answerController.clear();
                    });
                    Navigator.of(context).pop(1);
                  },
                ),
              ],
            );
          },
        );
      } else {
        var result = await showDialog<int>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('結果発表！'),
              content: Text('正答 $clearCount/5'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(1),
                ),
              ],
            );
          },
        );
        if (result == 1) {
          Navigator.pushNamed(context, "/section5-home");
        }
      }
    }
  }

  final _answerController = TextEditingController();
  String _answerText = '';
  void _handleAnswerText(String e) {
    setState(() {
      _answerText = e;
    });
  }

  List<DocumentSnapshot> testDataList = [];
  _getTestDataList() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('EnglishWordTest')
        .where('id', isGreaterThanOrEqualTo: 1)
        .where('id', isLessThanOrEqualTo: 11)
        .get();

    setState(() {
      testDataList = snapshot.docs;
    });
    testDataList.shuffle();
  }

  @override
  void initState() {
    super.initState();
    _getTestDataList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('単語テスト'),
      ),
      body: Container(
        width: size.width,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '第${questionCount.toString()}問',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 100),
            Text(
              testDataList[questionCount - 1]['mean'],
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 100),
            Column(
              children: [
                const Text(
                  '解 答',
                  style: TextStyle(fontSize: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _answerController,
                    enabled: true,
                    // 入力数
                    maxLength: 50,
                    decoration: const InputDecoration(
                      counterText: '',
                    ),
                    style: const TextStyle(color: Colors.red),
                    obscureText: false,
                    maxLines: 1,
                    onChanged: _handleAnswerText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            SizedBox(
              height: 60,
              width: size.width * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  _checkResult(data: testDataList[questionCount - 1]['word'], answer: _answerText);
                  print(clearCount);
                  print(testDataList[questionCount - 1]['word']);
                  print(_answerText);
                },
                child: const Text(
                  'Check !',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
