import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:e_flop/ui/search_bar.dart';
import 'package:e_flop/ui/game_list.dart';

void main() {
  runApp(EFlopApp());
}

class EFlopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eFlop',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EFlopHomePage(),
    );
  }
}

class EFlopHomePage extends StatefulWidget {
  EFlopHomePage({Key? key}) : super(key: key);
  @override
  _EFlopHomePageState createState() => _EFlopHomePageState();
}

class _EFlopHomePageState extends State<EFlopHomePage> {
  GlobalKey<GameListState> _keyGameList = GlobalKey();
  bool _inSearch = false;
  bool _onlyDiscounts = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_inSearch) ...{
              SearchBar(
                onChanged: (value) {
                  _keyGameList.currentState?.updateSearchTerm(value);
                },
              ),
            },
            Expanded(
                child: RefreshIndicator(
              onRefresh: () => Future.sync(
                () => _keyGameList.currentState?.refreshPagedList(),
              ),
              child: GameList(key: _keyGameList),
            )),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: new Row(
          children: <Widget>[
            IconButton(
              tooltip: 'Buscador',
              color: _inSearch ? Colors.white : Colors.grey,
              iconSize: 32.0,
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _inSearch = !_inSearch;
                  if (!_inSearch) {
                    _keyGameList.currentState?.updateSearchTerm('');
                  }
                });
              },
            ),
            Spacer(),
            Text('Solo ofertas',
                style: TextStyle(
                    color: _onlyDiscounts ? Colors.white : Colors.grey,
                    fontSize: 16.0)),
            Switch(
              value: _onlyDiscounts,
              onChanged: (value) {
                setState(() {
                  _onlyDiscounts = value;
                });
                _keyGameList.currentState?.updateDiscount(_onlyDiscounts);
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.green[200],
              inactiveTrackColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
