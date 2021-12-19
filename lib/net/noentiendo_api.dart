import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_flop/entities/game.dart';

class NoentiendoApi {
  static Future<List<Game>> fetchGameList(
    int rows,
    int start,
    String searchTerm,
    bool onlyDiscount,
  ) async {
    final apiUrl =
        _ApiUrlBuilder.gameList(rows, start, searchTerm, onlyDiscount);
    final response = await http.get(Uri.parse(apiUrl));
    final parsed = jsonDecode(response.body)['response']['docs']
        .cast<Map<String, dynamic>>();
    return await Game.formFullJson(parsed, true);
  }
}

class _ApiUrlBuilder {
  static const _baseUrl = 'https://searching.nintendo-europe.com/es/select';

  static const _trickyUrl =
      '&fq=type%3AGAME%20AND%20((playable_on_txt%3A%22HAC%22)%20AND%20(dates_released_dts%3A%5B*%20TO%20NOW%5D%20AND%20nsuid_txt%3A*))%20AND%20sorting_title%3A*%20AND%20*%3A*';

  static const _trickyUrlDiscount =
      '&fq=type%3AGAME%20AND%20((playable_on_txt%3A%22HAC%22)%20AND%20(dates_released_dts%3A%5B*%20TO%20NOW%5D%20AND%20nsuid_txt%3A*)%20AND%20(price_has_discount_b%3A%22true%22))%20AND%20sorting_title%3A*%20AND%20*%3A*';

  static String gameList(
    int rows,
    int start,
    String searchTerm,
    bool onlyDiscount,
  ) =>
      '$_baseUrl?'
      '${_buildSearchTermQuery(searchTerm)}'
      '${_buildDiscountQuery(onlyDiscount)}'
      '&sort=date_from%20desc'
      '&wt=json'
      '&rows=$rows'
      '&start=$start';

  static String _buildSearchTermQuery(String searchTerm) =>
      searchTerm.isEmpty == false
          ? 'q=${searchTerm.replaceAll(' ', '+')}'
          : 'q=*';

  static String _buildDiscountQuery(bool discount) =>
      discount == false ? _trickyUrl : _trickyUrlDiscount;
}
