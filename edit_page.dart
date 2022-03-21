import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:runverse_fire/pages/section5/list_page.dart';

///
/// ページ部分
///
class WordEditPage extends StatefulWidget {
  const WordEditPage({Key? key}) : super(key: key);

  @override
  _WordEditPageState createState() => _WordEditPageState();
}

class _WordEditPageState extends State<WordEditPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments! as editArguments;
    int id = args.id;
    String word = args.word;
    String mean = args.mean;
    String documentId = args.documentId;

    // 英単語の入力
    final _englishWordController = TextEditingController(text: word);
    String _englishText = word;
    void _handleEnglishText(String e) {
      setState(() {
        _englishText = e;
      });
    }

    // 日本語の入力
    final _japaneseWordController = TextEditingController(text: mean);
    String _japaneseText = mean;
    void _handleJapaneseText(String e) {
      setState(() {
        _japaneseText = e;
      });
    }

    _editWord() async {
      // 空白の場合の処理（ TODO: ダイアログにしたい ）
      if (_englishText == '' || _japaneseText == '') {
        return print('データを入力してください');
      }

      /// 単語があるか検索
      List<DocumentSnapshot> wordData = [];
      var snapshot =
          await FirebaseFirestore.instance.collection('EnglishWordTest').where('word', isEqualTo: _englishText).where('id', isNotEqualTo: id).get();

      setState(() {
        wordData = snapshot.docs;
      });

      if (wordData.isEmpty) {
        await FirebaseFirestore.instance
            .collection('EnglishWordTest')
            .doc(documentId)
            .update({"id": id, "word": _englishText, "mean": _japaneseText});
        setState(() {
          _englishText = '';
          _japaneseText = '';
        });
        _englishWordController.clear();
        _japaneseWordController.clear();
      } else {
        /// モーダルを出す
        return await showDialog<void>(
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
                    _englishWordController.clear();
                    _japaneseWordController.clear();
                  },
                ),
              ],
            );
          },
        );
      }
    }

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('単語編集'),
      ),
      body: Container(
        width: size.width,
        padding: const EdgeInsets.all(20),
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
                    controller: _englishWordController,
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
                    controller: _japaneseWordController,
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
                  _editWord();
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
