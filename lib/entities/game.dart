import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:tuple/tuple.dart';

class Game {
  final String id;
  final String name;
  final String thumbnailUrl;
  final double priceRegular;
  final double priceLowest;
  final String date;
  final String publisher;
  final String agerating;
  final String excerpt;
  final Color textColor;
  final Color backgroundColor;
  final ImageProvider image;

  Game({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.priceRegular,
    required this.priceLowest,
    required this.date,
    required this.publisher,
    required this.agerating,
    required this.excerpt,
    required this.textColor,
    required this.backgroundColor,
    required this.image,
  });

  static Future<List<Game>> fromFullJson(
      List<dynamic> jsonGames, bool colorful) async {
    final List<Game> games = [];

    Color textColor = Colors.black;
    Color backgroundColor = Colors.white;
    ImageProvider imageProvider = MemoryImage(kTransparentImage);

    await Future.forEach(jsonGames, (dynamic game) async {
      imageProvider = CachedNetworkImageProvider(game['image_url_sq_s']);
      if (colorful) {
        final palette = await Game.getImagePalette(imageProvider);
        if (palette.item1 != null && palette.item2 != null) {
          textColor = palette.item2;
          backgroundColor = palette.item1;
        }
      }
      games.add(Game(
        id: game['fs_id'], // "1883227"
        name: game['title'], // "Cyber Shadow"
        thumbnailUrl: game.containsKey('image_url_sq_s')
            ? game['image_url_sq_s']
            : '', // https://...
        priceRegular: game.containsKey('price_regular_f')
            ? game['price_regular_f']
            : 0, // 19.99
        priceLowest: game.containsKey('price_lowest_f')
            ? game['price_lowest_f']
            : 0, // 19.99
        date: game.containsKey('pretty_date_s')
            ? game['pretty_date_s']
            : '', // "26-01-2021"
        publisher: game.containsKey('publisher')
            ? game['publisher']
            : '', // "Yacht Club Games"
        agerating: game.containsKey('pretty_agerating_s')
            ? game['pretty_agerating_s']
            : '', // "PEGI 7"
        excerpt: game.containsKey('excerpt') ? game['excerpt'] : '', // ...
        textColor: textColor,
        backgroundColor: backgroundColor,
        image: imageProvider,
      ));
    });

    return games;
  }

  static Future<Tuple2> getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);

    return Tuple2(paletteGenerator.dominantColor?.color,
        paletteGenerator.dominantColor?.bodyTextColor);
  }
}
