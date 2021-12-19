import 'package:flutter/material.dart';
import 'dart:async';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key, required this.onChanged}) : super(key: key);
  final ValueChanged<String> onChanged;
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  var _searchQuery = new TextEditingController();
  late Timer _debounce;

  @override
  void initState() {
    super.initState();
    _searchQuery.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    if (_debounce.isActive) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      widget.onChanged(_searchQuery.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: TextField(
        controller: _searchQuery,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 17),
          hintText: '¿Qué andas buscando?',
          suffixIcon: Icon(
            Icons.search,
            size: 24,
            color: Colors.black,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchQuery.removeListener(_onSearchChanged);
    _searchQuery.dispose();
    if (_debounce.isActive) _debounce.cancel();
    super.dispose();
  }
}
