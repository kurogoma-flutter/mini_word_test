# mini_word_test
ちょっとした単語テストアプリです

# 画面及び主要機能
## home_page.dart
### 画面
<img width="300" src="https://user-images.githubusercontent.com/67848399/159216354-be166414-a102-448e-ba4e-df175c0a9dc6.png">

### 仕様
- 全範囲でテストボタン => `test_page.dart`に、最小値「１」、最大値「collection内での最大値」をargumentで渡す
```dart
onPressed: () {
  Navigator.pushNamed(
    context,
    "/section5-test",
    arguments: TestRangeArguments(1, _lastId),
  );
},
```
argumentsで複数の値を渡したかったので以下を設定
```dart
class TestRangeArguments {
  final int startNo;
  final int endNo;

  TestRangeArguments(this.startNo, this.endNo);
}
```
- 範囲指定でテストボタン => `test_page.dart`に選択した最小値と最大値を渡して遷移
バリデーションは一旦以下で簡易的に実装
1. テストは5問以上なので5問以上の範囲になるよう指定
2. テスト範囲がデータ量を超えないよう制限

```dart
  _getTestRange({int startNo = 0, int endNo = 0}) {
    // 未入力エラー処理
    if (startNo <= 0 || endNo <= 0) {
      return _alertDialog('範囲を入力してください。');
    }
    // データ範囲チェック
    if (endNo > _lastId) {
      return _alertDialog('データの範囲を超えています。');
    }
    if (startNo - endNo < 5 || endNo < 5) {
      return _alertDialog('5問以上の範囲を選択してください。');
    }
    // 通常処理
    return Navigator.pushNamed(
      context,
      '/section5-test',
      arguments: TestRangeArguments(startNo, endNo),
    );
  }
```

## input_page.dart
基本以下のリポジトリと同様のことをしているので割愛
https://github.com/kurogoma-flutter/store_new_word

<img width="300" src="https://user-images.githubusercontent.com/67848399/159217668-3c607dd3-b435-4995-965e-e7dea15e3de4.png">

## list_page.dart
以前以下のリポジトリでシンプルにMap表示をしたので、今回はStreamBuilderとsnapshotを用いて
リアルタイム取得を実装
https://github.com/kurogoma-flutter/firebase_list

<img width="300" src="https://user-images.githubusercontent.com/67848399/159218519-44a16d6e-8577-4301-a9ce-070d7c086b00.png">

### snapshot取得
```dart
final Stream<QuerySnapshot> _wordsStream = FirebaseFirestore.instance.collection('EnglishWordTest')
                                                                     .orderBy('id', descending: false).snapshots();
```
### StreamBuilder
```dart
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
```
### 仕様
- 編集ボタン => 編集ページへ遷移（とりあえずリストと合致するテキストが表示されているだけ。処理は今後実装）
- 削除ボタン => 以下の確認ダイアログでOKを押したら削除
```dart
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
```
## test_page.dart
### 正解時
<img width="300" src="https://user-images.githubusercontent.com/67848399/159221178-342f870b-117c-43f3-9b76-c19d8cb58192.png">

### 不正解時
<img width="300" src="https://user-images.githubusercontent.com/67848399/159221172-64d3f1df-9dc4-4ee5-9987-ac107cf1e90c.png">

### 終了後
<img width="300" src="https://user-images.githubusercontent.com/67848399/159221146-24a8e7b0-5c8c-42b8-b4e9-c9ae6274c34c.png">

### テストデータの取得
argumentで渡された値で範囲検索する
```dart
  List<DocumentSnapshot> testDataList = [];
  _getTestDataList(BuildContext context) async {
    final args = ModalRoute.of(context)!.settings.arguments as TestRangeArguments;

    var snapshot = await FirebaseFirestore.instance
        .collection('EnglishWordTest')
        .where('id', isGreaterThanOrEqualTo: args.startNo)
        .where('id', isLessThanOrEqualTo: args.endNo)
        .get();

    setState(() {
      testDataList = snapshot.docs;
    });
    testDataList.shuffle();
  }
```

### 正誤判定
ユーザーが入力したデータと、裏で持っているデータが一致したらOKとする
```dart
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
```

## FlutterのStateのライフライクル
初期読み込み = `initState()`って思っていたのですが、FlutterのStateのライフサイクルは以下が正しい。
1. createState
2. initState
3. didChangeDependencies
<br>

上記の `2. initState` が読み込まれるとようやっと `context`が使えるようになる。<br>
よって、contextを含むメソッドを初期読み込みしたい場合は`didChangeDependencies`を用いる。

```dart
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getTestDataList(context);
  }
```
