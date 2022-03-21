import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Navigatorで受け渡す値（input_page.dart)
// startNo: 範囲の開始
// endNo : 範囲の終了位置
class editArguments {
  final int id;
  final String word;
  final String mean;
  final String documentId;

  editArguments(this.id, this.word, this.mean, this.documentId);
}

class WordListPage extends StatefulWidget {
  const WordListPage({Key? key}) : super(key: key);

  @override
  _WordListPageState createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  _confirmDeleteDialog(String documentId) async {
    var result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('削除確認'),
          content: const Text('削除してもよろしいですか？'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(0),
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(1),
            ),
          ],
        );
      },
    );
    if (result == 1) {
      await FirebaseFirestore.instance.collection('EnglishWordTest').doc(documentId).delete();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  final Stream<QuerySnapshot> _wordsStream = FirebaseFirestore.instance.collection('EnglishWordTest').orderBy('id', descending: false).snapshots();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('単語一覧'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _wordsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text(
              'ERROR!! Something went wrong',
              style: TextStyle(fontSize: 30),
            ));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text(
                "Loading...",
                style: TextStyle(fontSize: 30),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black45),
                  ),
                  child: ListTile(
                    leading: Text(data['id'].toString()),
                    title: Text(
                      data['word'] ?? 'データがありません',
                      style: TextStyle(fontSize: 24),
                    ),
                    subtitle: Text(data['mean'] ?? 'データがありません'),
                    trailing: Wrap(
                      children: <Widget>[
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/section5-edit',
                              arguments: editArguments(data['id'], data['word'], data['mean'], document.id),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          iconSize: 28,
                        ),
                        IconButton(
                          onPressed: () {
                            _confirmDeleteDialog(document.id);
                          },
                          icon: const Icon(Icons.delete_forever),
                          iconSize: 28,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
