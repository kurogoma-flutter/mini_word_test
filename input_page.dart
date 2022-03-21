import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

///
/// ページ部分
///
class WordInputPage extends StatefulWidget {
  const WordInputPage({Key? key}) : super(key: key);

  @override
  _WordInputPageState createState() => _WordInputPageState();
}

class _WordInputPageState extends State<WordInputPage> {
  // 英単語の入力
  final _englishController = TextEditingController();
  String _englishText = '';
  void _handleEnglishText(String e) {
    setState(() {
      _englishText = e;
    });
  }

  // 日本語の入力
  final _japaneseController = TextEditingController();
  String _japaneseText = '';
  void _handleJapaneseText(String e) {
    setState(() {
      _japaneseText = e;
    });
  }

  _storeNewWord() async {
    // 空白の場合の処理（ TODO: ダイアログにしたい ）
    if (_englishText == '' || _japaneseText == '') {
      return print('データを入力してください');
    }

    /// IDの一番大きい値を取得
    List<DocumentSnapshot> wordList = [];
    int _lastId; // collectionの中で最新のID取得
    var snapshotId = await FirebaseFirestore.instance.collection('EnglishWordTest').orderBy('id', descending: true).limit(1).get();
    setState(() {
      wordList = snapshotId.docs;
    });
    _lastId = wordList[0]['id'];
    int id = _lastId + 1; // 登録するID

    /// 単語があるか検索
    List<DocumentSnapshot> wordData = [];
    var snapshot = await FirebaseFirestore.instance.collection('EnglishWordTest').where('word', isEqualTo: _englishText).get();
    setState(() {
      wordData = snapshot.docs;
    });

    if (wordData.isEmpty) {
      await FirebaseFirestore.instance.collection('EnglishWordTest').add({"id": id, "word": _englishText, "mean": _japaneseText});
      setState(() {
        _englishText = '';
        _japaneseText = '';
      });
      _englishController.clear();
      _japaneseController.clear();
    } else {
      /// モーダルを出す
      return await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('登録エラー'),
            content: Text('その単語はすでにID${wordData[0]['id']}で使用されています。'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _englishText = '';
                    _japaneseText = '';
                  });
                  _englishController.clear();
                  _japaneseController.clear();
                },
              ),
            ],
          );
        },
      );
    }
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
        title: const Text('新規単語追加'),
      ),
      body: Container(
        width: size.width,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Column(
              children: [
                const Text(
                  '英 単 語',
                  style: TextStyle(fontSize: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _englishController,
                    enabled: true,
                    // 入力数
                    maxLength: 50,
                    decoration: const InputDecoration(
                      counterText: '',
                    ),
                    style: const TextStyle(color: Colors.red),
                    obscureText: false,
                    maxLines: 1,
                    onChanged: _handleEnglishText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                const Text(
                  '日 本 語 訳',
                  style: TextStyle(fontSize: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _japaneseController,
                    enabled: true,
                    // 入力数
                    maxLength: 50,
                    decoration: const InputDecoration(
                      counterText: '',
                    ),
                    style: const TextStyle(color: Colors.red),
                    obscureText: false,
                    maxLines: 1,
                    onChanged: _handleJapaneseText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            SizedBox(
              height: 80,
              width: size.width * 0.55,
              child: ElevatedButton(
                onPressed: () {
                  _storeNewWord();
                },
                child: const Text(
                  '新規単語追加',
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
