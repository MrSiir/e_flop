import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:e_flop/entities/game.dart';

class GameListItem extends StatefulWidget {
  const GameListItem({
    required this.game,
    required this.index,
    Key? key,
  }) : super(key: key);

  final Game game;
  final int index;

  @override
  _GameListItemState createState() => _GameListItemState();
}

class _GameListItemState extends State<GameListItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: widget.game.backgroundColor,
            ),
            child: Row(
              children: [
                Image(
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  image: widget.game.image,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.game.name,
                        style: TextStyle(
                            color: widget.game.textColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 0,
                      height: 3,
                    ),
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(3, 2, 3, 2),
                            color: Colors.black,
                            child: Text(
                                widget.game.priceLowest > 0
                                    ? widget.game.priceLowest.toString() + '€'
                                    : 'GRATUITO',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0))),
                        if (widget.game.priceRegular > 0 &&
                            widget.game.priceLowest <
                                widget.game.priceRegular) ...{
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                              padding: EdgeInsets.fromLTRB(3, 2, 3, 2),
                              color: Colors.red,
                              child: Text(
                                  widget.game.priceRegular.toString() + '€',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      decoration: TextDecoration.lineThrough))),
                        }
                      ],
                    ),
                    SizedBox(
                      width: 0,
                      height: 4,
                    ),
                    Text(
                        widget.game.date +
                            " | " +
                            widget.game.publisher +
                            //" | " +
                            //widget.game.agerating
                            '',
                        style: TextStyle(
                            color: widget.game.textColor, fontSize: 14.0)),
                  ],
                )),
              ],
            )),
      ],
    );
  }
}
