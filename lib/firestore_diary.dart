import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'main.dart';
import 'online_page.dart';

class CloudPage extends StatefulWidget {
  const CloudPage({super.key});

  @override
  State<CloudPage> createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<WatchItem>> _stream;
  String _genre = 'ทั้งหมด';
  String _kind = 'ทั้งหมด';
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _stream = FirestoreService.watchMyItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final result = await Navigator.push<WatchItem>(
      context,
      MaterialPageRoute(builder: (_) => const WatchFormPage()),
    );
    if (result == null) return;
    await FirestoreService.add(result);
  }

  Future<void> _edit(WatchItem item) async {
    final id = item.remoteId;
    if (id == null) return;
    final result = await Navigator.push<WatchItem>(
      context,
      MaterialPageRoute(builder: (_) => WatchFormPage(existing: item)),
    );
    if (result == null) return;
    await FirestoreService.update(id, result);
  }

  Future<void> _delete(WatchItem item) async {
    final id = item.remoteId;
    if (id == null) return;
    final ok = await confirmDelete(context, item.title, 'Cloud');
    if (!ok) return;
    await FirestoreService.delete(id);
  }

  Future<void> _toggleFavorite(WatchItem item) async {
    final id = item.remoteId;
    if (id == null) return;
    await FirestoreService.update(
      id,
      item.copyWith(isFavorite: !item.isFavorite),
    );
  }

  Widget _body(AsyncSnapshot<List<WatchItem>> snapshot, List<WatchItem> items) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: cinemaGold));
    }
    if (snapshot.hasError) {
      return CinemaMessage(
        icon: Icons.cloud_off,
        title: 'โหลดข้อมูลจาก Cloud ไม่ได้',
        subtitle: '${snapshot.error}',
      );
    }
    if (items.isEmpty) {
      return const CinemaMessage(
        icon: Icons.cloud_upload,
        title: 'ยังไม่มีหนัง/ซีรีส์บน Cloud',
        subtitle:
            'กดปุ่ม "เพิ่มบน Cloud" เพื่อเก็บรายการที่อยากดูไว้ในบัญชีของคุณ',
      );
    }
    final query = _searchController.text.trim().toLowerCase();
    final shown = items.where((item) {
      final matchesQuery =
          item.title.toLowerCase().contains(query) ||
          item.content.toLowerCase().contains(query);
      final matchesGenre = _genre == 'ทั้งหมด' || item.genre == _genre;
      final matchesKind = _kind == 'ทั้งหมด' || item.kind == _kind;
      final matchesFavorite = !_favoritesOnly || item.isFavorite;
      return matchesQuery && matchesGenre && matchesKind && matchesFavorite;
    }).toList();
    if (shown.isEmpty) {
      return const CinemaMessage(
        icon: Icons.search_off,
        title: 'ไม่พบรายการที่ตรงกับการค้นหา',
        subtitle: 'ลองเปลี่ยนคำค้นหาหรือตัวกรอง',
      );
    }
    return ListView.builder(
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
          onEdit: () => _edit(item),
          onDelete: () => _delete(item),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WatchItem>>(
      stream: _stream,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        return Scaffold(
          appBar: AppBar(
            title: cinemaTitle(Icons.cloud, 'หนัง/ซีรีส์ (${items.length})'),
            bottom: FilterHeader(
              controller: _searchController,
              hint: 'ค้นหาชื่อหรือเรื่องย่อบน Cloud...',
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
                onPressed: () =>
                    showStatsSheet(context, 'สถิติหนัง/ซีรีส์', items),
              ),
              IconButton(
                tooltip: 'ออกจากระบบ',
                icon: const Icon(Icons.logout),
                onPressed: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
          body: Column(
            children: [
              ChoiceRow(
                options: const ['ทั้งหมด', ...watchKinds],
                selected: _kind,
                onSelected: (v) => setState(() => _kind = v),
              ),
              Expanded(child: _body(snapshot, items)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _add,
            backgroundColor: cinemaGold,
            foregroundColor: cinemaBar,
            icon: const Icon(Icons.cloud_upload),
            label: const Text(
              'เพิ่มบน Cloud',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
