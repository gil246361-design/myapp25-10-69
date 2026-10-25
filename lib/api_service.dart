import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'main.dart';

class TvShow {
  final String name;
  final String premiered;
  final String summary;
  final double rating;
  final List<String> genres;
  final String network;

  TvShow({
    required this.name,
    required this.premiered,
    required this.summary,
    required this.rating,
    required this.genres,
    required this.network,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    final ratingMap = json['rating'];
    final net = json['network'] ?? json['webChannel'];
    final rawSummary = json['summary'] as String? ?? '';
    return TvShow(
      name: json['name'] as String? ?? 'ไม่ทราบชื่อ',
      premiered: json['premiered'] as String? ?? '-',
      summary: rawSummary.replaceAll(RegExp(r'<[^>]*>'), '').trim(),
      rating: ratingMap is Map && ratingMap['average'] is num
          ? (ratingMap['average'] as num).toDouble()
          : 0,
      genres: (json['genres'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      network: net is Map ? (net['name'] ?? '').toString() : '',
    );
  }
}

class ApiService {
  static const String studentId = '67011212099';
  static const String baseUrl =
      'https://thipwimon.comsciproject.net/mydiary/api.php/$studentId';

  static Map<String, dynamic> _body(WatchItem item) {
    return {
      'title': item.title,
      'content': item.content,
      'mood': item.status,
      'date': item.date,
    };
  }

  static Future<void> createSeries(WatchItem item) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_body(item)),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('เพิ่มไม่สำเร็จ (${response.statusCode})');
    }
  }

  static Future<List<WatchItem>> getSeries() async {
    final response = await http
        .get(Uri.parse(baseUrl))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200)
      throw Exception('โหลดไม่สำเร็จ (${response.statusCode})');
    final data = jsonDecode(response.body);
    if (data is! List) throw Exception('รูปแบบข้อมูลจาก server ไม่ถูกต้อง');
    return data
        .map((e) => WatchItem.fromApi(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<void> updateSeries(String id, WatchItem item) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_body(item)),
    );
    if (response.statusCode != 200)
      throw Exception('แก้ไขไม่สำเร็จ (${response.statusCode})');
  }

  static Future<void> deleteSeries(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200)
      throw Exception('ลบไม่สำเร็จ (${response.statusCode})');
  }

  static Future<List<TvShow>> fetchTvShows(String query) async {
    try {
      if (query.isEmpty) {
        final page = Random().nextInt(10);
        final response = await http
            .get(Uri.parse('https://api.tvmaze.com/shows?page=$page'))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode != 200) throw Exception('server error');
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .take(20)
            .map((e) => TvShow.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final url = Uri.parse(
        'https://api.tvmaze.com/search/shows?q=${Uri.encodeQueryComponent(query)}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) throw Exception('server error');
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map(
            (e) => TvShow.fromJson(
              (e as Map<String, dynamic>)['show'] as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('เชื่อมต่อไม่ได้ ตรวจสอบอินเทอร์เน็ต');
    }
  }
}
