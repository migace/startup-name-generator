import 'package:flutter/widgets.dart';
import 'package:my_app/sql_helper.dart';
import 'package:my_app/startupNamesModel.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white, foregroundColor: Colors.black),
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = TextStyle(fontSize: 18);

  List<Map<String, dynamic>> items = [];

  void getInitialData() async {
    final data = await SQLHelper.getItems("startupNames");

    items = data;
  }

  @override
  Widget build(BuildContext context) {
    getInitialData();

    void _pushSaved() {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        final tiles = items.map((item) {
          return ListTile(
              title: Text(
            item['name'],
            style: _biggerFont,
          ));
        });

        return Scaffold(
            appBar: AppBar(
              title: Text("Saved suggestions"),
            ),
            body: tiles.isNotEmpty
                ? ListView(
                    children:
                        ListTile.divideTiles(context: context, tiles: tiles)
                            .toList())
                : Center(child: Text("No saved suggestions")));
      }));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Startup Name Generator"),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushSaved,
              tooltip: "Saved Suggestions",
            )
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, i) {
            if (i.isOdd) return Divider();

            final index = i ~/ 2;

            if (index >= _suggestions.length) {
              _suggestions.addAll(generateWordPairs().take(10));
            }

            final alreadySaved = _saved.contains(_suggestions[index]);

            return ListTile(
              title: Text(_suggestions[index].asPascalCase, style: _biggerFont),
              trailing: Icon(
                alreadySaved ? Icons.favorite : Icons.favorite_border,
                color: alreadySaved ? Colors.red : null,
                semanticLabel: alreadySaved ? "Remove from saved" : "Save",
              ),
              onTap: () async {
                print(items);
                var startupName =
                    StartupName(name: _suggestions[index].asPascalCase);

                if (alreadySaved) {
                  await SQLHelper.remove("startupNames", items[index]['id']);
                } else {
                  await SQLHelper.insert("startupNames", startupName);
                }

                setState(() {
                  if (alreadySaved) {
                    _saved.remove(_suggestions[index]);
                  } else {
                    _saved.add(_suggestions[index]);
                  }
                });
              },
            );
          },
        ));
  }
}
