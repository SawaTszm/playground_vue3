import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: "Namer App",
          theme: ThemeData(
              useMaterial3: true,
              colorScheme:
                  ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent)),
          home: MyHomePage(),
        ));
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // "WordPair"型(それ以外はエラーになる)
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = GeneratorFavoritePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            // SafeArea: ハードウェアノッチやステータスバーで隠れないエリア
            SafeArea(
              child: NavigationRail(
                // trueに変えるとアイコンの隣にラベルが表示されることを利用して、
                // widthが600以上の時だけラベルを表示する。
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            // Expanded: 取れるだけのスペースを取る"欲張り"なウィジェット。
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GeneratorFavoritePage extends StatelessWidget {
  const GeneratorFavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Center(
      child: ListView(
        children: [
          for (var favorite in favorites)
            Center(
              child: Card(
                color: theme.colorScheme.primary,
                child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      favorite.asLowerCase,
                      style: style,
                      semanticsLabel: favorite.asPascalCase,
                    )),
              ),
            ),
        ],
      ),
    );
  }
}

// Text(pair: pair);の行にカーソルを合わせた状態で⌘. → Extract Widget、BigCardとtypeしてEnter でWidgetとして抽出できる
// StatelessWidgetのところにカーソルを合わせて⌘.したら、convert StatefulWidget もできる。sugeeee
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // 現在のテーマをthemeに保存
    var theme = Theme.of(context);
    // theme.textThemeにアクセスすることでアプリのフォントテーマにアクセスできる
    // nullを許容してる変数(TextStyle?: displayMedium)をCasting away nullabilityするための"bank operator"が"!"
    // (displayMedium as TextStyle)と同義。
    // copyWith: 定義した変更を加えたTextStyleを返す。
    // ⌘⇧spaceで、関数の引数として渡せる値の完全なリストが見られる(!)
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // 注：Flutterでは、できる限り継承ではなく、合成を使います。ここでは、paddingがTextの属性である代わりに、ウィジェットになっているのです。
    // こうすることで、ウィジェットはその1つの責任に集中でき、開発者はUIをどのように構成するか、完全に自由にできるようになります。
    // 例えば、Paddingウィジェットを使って、テキスト、画像、ボタン、独自のカスタムウィジェット、またはアプリ全体をパッド化することができます。ウィジェットは、何を包んでいるかは気にしません。
    return Card(
      // 現在のテーマのcolorSchemeに沿って色を決定する(primary: メインカラー)
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          // スクリーンリーダー用とかに読み上げやすいPascalCaseにする
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

// 次、Theme and style から
