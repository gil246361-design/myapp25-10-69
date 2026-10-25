import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'firebase_options.dart';
import 'firestore_diary.dart';
import 'login_page.dart';
import 'online_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyMovie',
      theme: buildCinemaTheme(),
      themeMode: ThemeMode.dark,
      darkTheme: buildCinemaTheme(),
      scrollBehavior: const NoGlowScrollBehavior(),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MovieGenre {
  final String name;
  final IconData icon;
  final Color color;

  const MovieGenre(this.name, this.icon, this.color);
}

const List<MovieGenre> movieGenres = [
  MovieGenre('แอ็คชัน', Icons.local_fire_department, Color(0xFFE53935)),
  MovieGenre('ดราม่า', Icons.theater_comedy, Color(0xFF8E24AA)),
  MovieGenre('สยองขวัญ', Icons.nightlight_round, Color(0xFF5E35B1)),
  MovieGenre('ตลก', Icons.sentiment_very_satisfied, Color(0xFFFFB300)),
  MovieGenre('โรแมนติก', Icons.favorite, Color(0xFFD81B60)),
  MovieGenre('ไซไฟ', Icons.rocket_launch, Color(0xFF1E88E5)),
  MovieGenre('แฟนตาซี', Icons.auto_awesome, Color(0xFF00ACC1)),
  MovieGenre('แอนิเมชัน', Icons.brush, Color(0xFF43A047)),
];

MovieGenre? findGenre(String name) {
  for (final g in movieGenres) {
    if (g.name == name) return g;
  }
  return null;
}

MovieGenre genreOf(String name) => findGenre(name) ?? movieGenres.first;

const List<String> watchStatuses = ['อยากดู', 'กำลังดู', 'ดูจบแล้ว'];
const List<String> watchKinds = ['หนัง', 'ซีรีส์'];
const List<String> platforms = [
  '',
  'Netflix',
  'Disney+',
  'Prime Video',
  'HBO Max',
  'Viu',
  'WeTV',
  'YouTube',
  'โรงภาพยนตร์',
  'อื่นๆ',
];

int _toInt(dynamic v) {
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

String _validStatus(dynamic v) {
  final s = v?.toString() ?? '';
  return watchStatuses.contains(s) ? s : watchStatuses.first;
}

class WatchItem {
  final int? id;
  final String? remoteId;
  final String title;
  final String content;
  final String date;
  final int point;
  final String status;
  final bool isFavorite;
  final String genre;
  final String kind;
  final String platform;
  final int watchedEp;
  final int totalEp;

  const WatchItem({
    this.id,
    this.remoteId,
    required this.title,
    this.content = '',
    this.date = '',
    this.point = 0,
    this.status = 'อยากดู',
    this.isFavorite = false,
    this.genre = '',
    this.kind = 'หนัง',
    this.platform = '',
    this.watchedEp = 0,
    this.totalEp = 0,
  });

  WatchItem copyWith({bool? isFavorite}) {
    return WatchItem(
      id: id,
      remoteId: remoteId,
      title: title,
      content: content,
      date: date,
      point: point,
      status: status,
      isFavorite: isFavorite ?? this.isFavorite,
      genre: genre,
      kind: kind,
      platform: platform,
      watchedEp: watchedEp,
      totalEp: totalEp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'point': point,
      'status': status,
      'isFavorite': isFavorite ? 1 : 0,
      'genre': genre,
      'platform': platform,
    };
  }

  factory WatchItem.fromMap(Map<String, dynamic> m) {
    return WatchItem(
      id: m['id'] as int?,
      title: m['title'] as String? ?? '',
      content: m['content'] as String? ?? '',
      date: m['date'] as String? ?? '',
      point: _toInt(m['point']),
      status: _validStatus(m['status']),
      isFavorite: m['isFavorite'] == 1,
      genre: m['genre'] as String? ?? '',
      kind: 'หนัง',
      platform: m['platform'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'date': date,
      'point': point,
      'status': status,
      'isFavorite': isFavorite,
      'genre': genre,
      'kind': kind,
      'platform': platform,
      'watchedEp': watchedEp,
      'totalEp': totalEp,
    };
  }

  factory WatchItem.fromFirestore(String docId, Map<String, dynamic> d) {
    final p = (d['platform'] ?? '').toString();
    return WatchItem(
      remoteId: docId,
      title: (d['title'] ?? '').toString(),
      content: (d['content'] ?? '').toString(),
      date: (d['date'] ?? '').toString(),
      point: _toInt(d['point']),
      status: _validStatus(d['status']),
      isFavorite: (d['isFavorite'] ?? d['isImportant']) == true,
      genre: (d['genre'] ?? d['type'] ?? '').toString(),
      kind: d['kind'] == 'ซีรีส์' ? 'ซีรีส์' : 'หนัง',
      platform: platforms.contains(p) ? p : '',
      watchedEp: _toInt(d['watchedEp']),
      totalEp: _toInt(d['totalEp']),
    );
  }

  factory WatchItem.fromApi(Map<String, dynamic> m) {
    final rawId = m['id'] ?? m['_id'];
    return WatchItem(
      remoteId: rawId?.toString(),
      title: m['title']?.toString() ?? '',
      content: m['content']?.toString() ?? '',
      date: m['date']?.toString() ?? '',
      status: _validStatus(m['mood']),
      kind: 'ซีรีส์',
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    MoviePage(),
    SeriesPage(),
    CloudPage(),
    AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: cinemaBar,
        selectedItemColor: cinemaGold,
        unselectedItemColor: Colors.white54,
        enableFeedback: false,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'หนัง'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'ซีรีส์'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'หนัง/ซีรีส์'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'เกี่ยวกับ'),
        ],
      ),
    );
  }
}

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  List<WatchItem> _items = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  String _genre = 'ทั้งหมด';
  String _status = 'ทั้งหมด';
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final data = await DatabaseHelper.getAll();
    if (!mounted) return;
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _openAddPage() async {
    final result = await Navigator.push<WatchItem>(
      context,
      MaterialPageRoute(builder: (_) => const WatchFormPage(lockedKind: 'หนัง')),
    );
    if (result == null) return;
    await DatabaseHelper.insert(result);
    await _loadItems();
  }

  Future<void> _openEditPage(WatchItem item) async {
    final result = await Navigator.push<WatchItem>(
      context,
      MaterialPageRoute(builder: (_) => WatchFormPage(existing: item, lockedKind: 'หนัง')),
    );
    if (result == null) return;
    await DatabaseHelper.update(result);
    await _loadItems();
  }

  Future<void> _delete(WatchItem item) async {
    final ok = await confirmDelete(context, item.title, 'เครื่องนี้');
    if (!ok || item.id == null) return;
    await DatabaseHelper.delete(item.id!);
    await _loadItems();
  }

  Future<void> _toggleFavorite(WatchItem item) async {
    await DatabaseHelper.update(item.copyWith(isFavorite: !item.isFavorite));
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final shown = _items.where((item) {
      final matchesQuery = item.title.toLowerCase().contains(query) || item.content.toLowerCase().contains(query);
      final matchesGenre = _genre == 'ทั้งหมด' || item.genre == _genre;
      final matchesStatus = _status == 'ทั้งหมด' || item.status == _status;
      final matchesFavorite = !_favoritesOnly || item.isFavorite;
      return matchesQuery && matchesGenre && matchesStatus && matchesFavorite;
    }).toList();

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator(color: cinemaGold));
    } else if (_items.isEmpty) {
      body = const CinemaMessage(
        icon: Icons.local_movies,
        title: 'ยังไม่มีหนังที่อยากดู',
        subtitle: 'กดปุ่ม "เพิ่มหนัง" เพื่อจดเรื่องแรกที่อยากดู',
      );
    } else if (shown.isEmpty) {
      body = const CinemaMessage(
        icon: Icons.search_off,
        title: 'ไม่พบหนังที่ตรงกับการค้นหา',
        subtitle: 'ลองเปลี่ยนคำค้นหาหรือตัวกรอง',
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 90),
        itemCount: shown.length,
        itemBuilder: (context, i) {
          final item = shown[i];
          return WatchCard(
            item: item,
            index: i,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailPage(item: item)),
            ),
            onFavorite: () => _toggleFavorite(item),
            onEdit: () => _openEditPage(item),
            onDelete: () => _delete(item),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: cinemaTitle(Icons.theaters, 'หนังที่อยากดู (${_items.length})'),
        bottom: FilterHeader(
          controller: _searchController,
          hint: 'ค้นหาชื่อหนังหรือเรื่องย่อ...',
          genre: _genre,
          favoritesOnly: _favoritesOnly,
          onSearchChanged: () => setState(() {}),
          onGenreChanged: (v) => setState(() => _genre = v),
          onFavoritesChanged: (v) => setState(() => _favoritesOnly = v),
        ),
        actions: [
          IconButton(
            tooltip: 'สถิติ',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => showStatsSheet(context, 'สถิติหนังของฉัน', _items),
          ),
        ],
      ),
      body: Column(
        children: [
          ChoiceRow(
            options: const ['ทั้งหมด', ...watchStatuses],
            selected: _status,
            onSelected: (v) => setState(() => _status = v),
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPage,
        backgroundColor: cinemaGold,
        foregroundColor: cinemaBar,
        icon: const Icon(Icons.movie_creation),
        label: const Text('เพิ่มหนัง', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final WatchItem item;

  const DetailPage({super.key, required this.item});

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 15))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final genre = item.genre.isEmpty ? null : genreOf(item.genre);
    final accent = genre?.color ?? statusColor(item.status);
    final hasProgress = item.kind == 'ซีรีส์' && item.totalEp > 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.55), cinemaBg],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cinemaBg.withValues(alpha: 0.5),
                      boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
                    ),
                    child: Icon(genre?.icon ?? Icons.tv, size: 90, color: cinemaGold),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      WatchTag(icon: item.kind == 'ซีรีส์' ? Icons.tv : Icons.movie, text: item.kind, color: Colors.white70),
                      WatchTag(icon: statusIcon(item.status), text: item.status, color: statusColor(item.status)),
                      if (item.point > 0) WatchTag(icon: Icons.star, text: '${item.point} / 10', color: cinemaGold),
                      if (genre != null) WatchTag(text: genre.name, color: genre.color),
                      if (item.isFavorite) const WatchTag(icon: Icons.favorite, text: 'รายการโปรด', color: Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (item.date.isNotEmpty)
                    _infoRow(Icons.calendar_month, item.status == 'ดูจบแล้ว' ? 'ดูจบเมื่อ ${item.date}' : 'ตั้งใจดูวันที่ ${item.date}'),
                  if (item.platform.isNotEmpty) _infoRow(Icons.live_tv, 'ดูได้ที่ ${item.platform}'),
                  if (hasProgress) ...[
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (item.watchedEp / item.totalEp).clamp(0.0, 1.0),
                        minHeight: 8,
                        color: cinemaGold,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('ดูถึงตอนที่ ${item.watchedEp} จากทั้งหมด ${item.totalEp} ตอน', style: const TextStyle(color: Colors.white54)),
                  ],
                  const SizedBox(height: 24),
                  const Text('เรื่องย่อ / เหตุผลที่อยากดู', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cinemaGold)),
                  const SizedBox(height: 12),
                  Text(
                    item.content.isEmpty ? 'ไม่มีรายละเอียด' : item.content,
                    style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.white70),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับ')),
      body: Center(
        child: SingleChildScrollView(
          child: FadeSlideIn(
            index: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cinemaCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cinemaGold.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: cinemaGold.withValues(alpha: 0.1)),
                    child: const Icon(Icons.movie_creation, size: 70, color: cinemaGold),
                  ),
                  const SizedBox(height: 24),
                  const Text('My Movie', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  const Text('รายการหนัง/ซีรีส์ที่อยากดู', style: TextStyle(fontSize: 16, color: Colors.white60)),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text('สร้างโดย', style: TextStyle(fontSize: 16, color: Colors.white54)),
                  const SizedBox(height: 8),
                  const Text('watcharaphon', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: cinemaGold)),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('เข้าสู่ระบบเป็น $email', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: cinemaRed, side: const BorderSide(color: cinemaRed)),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    icon: const Icon(Icons.logout),
                    label: const Text('ออกจากระบบ'),
                  ),
                  const SizedBox(height: 16),
                  const Text('ข้อมูลซีรีส์จาก TVmaze.com', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
