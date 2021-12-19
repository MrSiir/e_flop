import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:e_flop/ui/game_list_item.dart';
import 'package:e_flop/net/noentiendo_api.dart';
import 'package:e_flop/entities/game.dart';

class GameList extends StatefulWidget {
  const GameList({Key? key}) : super(key: key);
  @override
  GameListState createState() => GameListState();
}

class GameListState extends State<GameList> {
  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  final PagingController<int, Game> _pagingController =
      PagingController(firstPageKey: 0, invisibleItemsThreshold: 2);

  static const _pageSize = 10;

  String _searchTerm = '';
  bool _onlyDiscount = false;

  Future<void> _fetchPage(int pageKey) async {
    try {
      print('_fetchPage(' + pageKey.toString() + ')');
      print('_searchTerm:' + _searchTerm);
      print('onlyDiscount:' + _onlyDiscount.toString());
      print('-------------------------------------');
      final newItems = await NoentiendoApi.fetchGameList(
          _pageSize, pageKey, _searchTerm, _onlyDiscount);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Game>(
      padding: const EdgeInsets.all(0),
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Game>(
          itemBuilder: (context, item, index) =>
              GameListItem(game: item, index: index)),
    );
  }

  void updateSearchTerm(String searchTerm) {
    if (searchTerm != _searchTerm) {
      setState(() {
        _searchTerm = searchTerm;
      });
      _pagingController.refresh();
    }
  }

  void updateDiscount(bool onlyDiscount) {
    if (onlyDiscount != _onlyDiscount) {
      setState(() {
        _onlyDiscount = onlyDiscount;
      });
      _pagingController.refresh();
    }
  }

  void refreshPagedList() {
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
