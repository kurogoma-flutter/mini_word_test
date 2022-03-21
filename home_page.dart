import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Navigatorで受け渡す値（input_page.dart)
// startNo: 範囲の開始
// endNo : 範囲の終了位置
class TestRangeArguments {
  final int startNo;
  final int endNo;

  TestRangeArguments(this.startNo, this.endNo);
}

class Section5 extends StatefulWidget {
  const Section5({Key? key}) : super(key: key);

  @override
  _Section5State createState() => _Section5State();
}

class _Section5State extends State<Section5> {
  // 開始Noの入力
  final _startNoController = TextEditingController();
  String _startNoText = '1';
  void _handleStartNoText(String e) {
    setState(() {
      _startNoText = e;
    });
  }

  // 終了Noの入力
  final _endNoController = TextEditingController();
  String _endNoText = '5';
  void _handleEndNoText(String e) {
    setState(() {
      _endNoText = e;
    });
  }

  late int _lastId; // collectionの中で最新のID取得
  _getLastId() async {
    /// IDの一番大きい値を取得
    List<DocumentSnapshot> wordList = [];
    var snapshotId = await FirebaseFirestore.instance.collection('EnglishWordTest').orderBy('id', descending: true).limit(1).get();
    setState(() {
      wordList = snapshotId.docs;
    });
    _lastId = wordList[0]['id'];
  }

  _getTestRange({int startNo = 0, int endNo = 0}) {
    // 未入力エラー処理
    if (startNo <= 0 || endNo <= 0) {
      return _alertDialog('範囲を入力してください。');
    }
    // データ範囲チェック
    if (endNo > _lastId) {
      return _alertDialog('データの範囲を超えています。');
    }
    if (endNo - startNo < 5 || endNo < 5) {
      return _alertDialog('5問以上の範囲を選択してください。');
    }
    // 通常処理
    return Navigator.pushNamed(
      context,
      '/section5-test',
      arguments: TestRangeArguments(startNo, endNo),
    );
  }

  _alertDialog(String message) async {
    return await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('入力エラー'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                return Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getLastId();
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
        title: const Text('英単語テスト'),
      ),
      body: Container(
        width: size.width,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: size.width * 0.6,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    "/section5-test",
                    arguments: TestRangeArguments(1, _lastId),
                  );
                },
                child: const Text(
                  '全範囲でテスト',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 20, left: 40, right: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.black87)),
                        child: TextField(
                          controller: _startNoController,
                          enabled: true,
                          // 入力数
                          maxLength: 3,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: Colors.black),
                          obscureText: false,
                          maxLines: 1,
                          onChanged: _handleStartNoText,
                        ),
                      ),
                      const Text(
                        '~',
                        style: TextStyle(fontSize: 40),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(border: Border.all(color: Colors.black87)),
                        child: TextField(
                          controller: _endNoController,
                          enabled: true,
                          // 入力数
                          maxLength: 3,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: Colors.black),
                          obscureText: false,
                          maxLines: 1,
                          onChanged: _handleEndNoText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.6,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                      onPrimary: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      if (double.tryParse(_startNoText) != null && double.tryParse(_endNoText) != null) {
                        _getTestRange(startNo: int.parse(_startNoText), endNo: int.parse(_endNoText));
                      } else {
                        _alertDialog('範囲には数字を選択してください。');
                      }
                    },
                    child: const Text(
                      '範囲指定でテスト',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: size.width * 0.6,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepOrangeAccent,
                  onPrimary: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/section5-input");
                },
                child: const Text(
                  '単語を追加',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(
              width: size.width * 0.6,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink,
                  onPrimary: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/section5-list");
                },
                child: const Text(
                  '一覧を確認',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
