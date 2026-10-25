import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart';

const Color cinemaBg = Color(0xFF0E0E12);
const Color cinemaCard = Color(0xFF1B1B22);
const Color cinemaGold = Color(0xFFE8B84B);
const Color cinemaBar = Color(0xFF191016);
const Color cinemaRed = Color(0xFFE05353);

class NoGlowScrollBehavior extends MaterialScrollBehavior {
  const NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class SoftTransitionsBuilder extends PageTransitionsBuilder {
  const SoftTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}

ThemeData buildCinemaTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );
  return base.copyWith(
    scaffoldBackgroundColor: cinemaBg,
    canvasColor: cinemaBg,
    colorScheme: base.colorScheme.copyWith(
      primary: cinemaGold,
      onPrimary: cinemaBar,
      secondary: cinemaGold,
      surface: cinemaCard,
      error: cinemaRed,
    ),
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: SoftTransitionsBuilder(),
      TargetPlatform.iOS: SoftTransitionsBuilder(),
      TargetPlatform.windows: SoftTransitionsBuilder(),
      TargetPlatform.macOS: SoftTransitionsBuilder(),
      TargetPlatform.linux: SoftTransitionsBuilder(),
    }),
    appBarTheme: const AppBarTheme(
      backgroundColor: cinemaBar,
      foregroundColor: cinemaGold,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(color: cinemaGold, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    cardTheme: const CardThemeData(color: cinemaCard, surfaceTintColor: Colors.transparent, elevation: 0),
    dialogTheme: const DialogThemeData(backgroundColor: cinemaCard, surfaceTintColor: Colors.transparent),
    popupMenuTheme: const PopupMenuThemeData(color: cinemaCard, surfaceTintColor: Colors.transparent),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: cinemaCard, surfaceTintColor: Colors.transparent),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: cinemaCard,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cinemaCard,
      selectedColor: cinemaGold.withValues(alpha: 0.28),
      labelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: Colors.white24),
      checkmarkColor: cinemaGold,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cinemaCard,
      labelStyle: const TextStyle(color: Colors.white60),
      prefixIconColor: cinemaGold,
      border: border(Colors.white24),
      enabledBorder: border(Colors.white24),
      focusedBorder: border(cinemaGold),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(backgroundColor: cinemaGold, foregroundColor: cinemaBar),
    ),
  );
}

Color statusColor(String status) {
  switch (status) {
    case 'อยากดู':
      return const Color(0xFF42A5F5);
    case 'กำลังดู':
      return const Color(0xFFFFA726);
    default:
      return const Color(0xFF66BB6A);
  }
}

IconData statusIcon(String status) {
  switch (status) {
    case 'อยากดู':
      return Icons.bookmark_add;
    case 'กำลังดู':
      return Icons.play_circle;
    default:
      return Icons.check_circle;
  }
}

ShapeBorder cinemaCardShape(Color border) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: border.withValues(alpha: 0.5), width: 1),
    );

Widget cinemaTitle(IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: cinemaGold),
      const SizedBox(width: 8),
      Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
    ],
  );
}

Future<bool> confirmDelete(BuildContext context, String title, String place) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('ลบรายการ?', style: TextStyle(color: Colors.white)),
      content: Text('ต้องการลบ "$title" ออกจาก $place ใช่ไหม', style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('ยกเลิก', style: TextStyle(color: cinemaGold)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('ลบ', style: TextStyle(color: cinemaRed)),
        ),
      ],
    ),
  );
  return result == true;
}

class FadeSlideIn extends StatelessWidget {
  final int index;
  final Widget child;

  const FadeSlideIn({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final step = index > 8 ? 8 : index;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + step * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 24 * (1 - value)), child: child),
        );
      },
      child: child,
    );
  }
}

class CinemaMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const CinemaMessage({super.key, required this.icon, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.7 + 0.3 * value, child: child),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: cinemaGold.withValues(alpha: 0.08)),
                  child: Icon(icon, size: 72, color: cinemaGold),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 19, color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38)),
                ],
                if (action != null) ...[const SizedBox(height: 16), action!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FilterHeader extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final String hint;
  final String genre;
  final bool favoritesOnly;
  final VoidCallback onSearchChanged;
  final ValueChanged<String> onGenreChanged;
  final ValueChanged<bool> onFavoritesChanged;

  const FilterHeader({
    super.key,
    required this.controller,
    required this.hint,
    required this.genre,
    required this.favoritesOnly,
    required this.onSearchChanged,
    required this.onGenreChanged,
    required this.onFavoritesChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(116);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            onChanged: (_) => onSearchChanged(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: cinemaGold),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        controller.clear();
                        onSearchChanged();
                      },
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: genre,
                  isExpanded: true,
                  dropdownColor: cinemaCard,
                  style: const TextStyle(color: Colors.white),
                  underline: const SizedBox.shrink(),
                  items: ['ทั้งหมด', ...movieGenres.map((g) => g.name)]
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onGenreChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('รายการโปรด'),
                selected: favoritesOnly,
                avatar: const Icon(Icons.favorite, size: 17),
                onSelected: onFavoritesChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChoiceRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const ChoiceRow({super.key, required this.options, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final option = options[i];
          final isSelected = option == selected;
          return ChoiceChip(
            label: Text(option),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: cinemaGold,
            backgroundColor: cinemaCard,
            labelStyle: TextStyle(
              color: isSelected ? cinemaBar : Colors.white70,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (_) => onSelected(option),
          );
        },
      ),
    );
  }
}

class WatchTag extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;

  const WatchTag({super.key, this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 3)],
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class WatchCard extends StatelessWidget {
  final WatchItem item;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WatchCard({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
    this.onFavorite,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final genre = item.genre.isEmpty ? null : genreOf(item.genre);
    final accent = genre?.color ?? statusColor(item.status);
    final info = [item.kind, item.platform, item.date].where((s) => s.isNotEmpty).join(' • ');
    final hasProgress = item.kind == 'ซีรีส์' && item.totalEp > 0;

    return FadeSlideIn(
      index: index,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: cinemaCardShape(accent),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Icon(genre?.icon ?? Icons.tv, color: accent, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (item.point > 0) WatchTag(icon: Icons.star, text: '${item.point}/10', color: cinemaGold),
                          WatchTag(icon: statusIcon(item.status), text: item.status, color: statusColor(item.status)),
                          if (genre != null) WatchTag(text: genre.name, color: genre.color),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (info.isNotEmpty)
                        Text(info, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      if (hasProgress) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (item.watchedEp / item.totalEp).clamp(0.0, 1.0),
                            minHeight: 5,
                            color: cinemaGold,
                            backgroundColor: Colors.white12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('ตอนที่ ${item.watchedEp}/${item.totalEp}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onFavorite != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: item.isFavorite ? Colors.redAccent : Colors.white54,
                        ),
                        onPressed: onFavorite,
                      ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white54),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('แก้ไข', style: TextStyle(color: Colors.white))),
                        PopupMenuItem(value: 'delete', child: Text('ลบ', style: TextStyle(color: Colors.redAccent))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showStatsSheet(BuildContext context, String title, List<WatchItem> items) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => StatsView(title: title, items: items),
  );
}

class StatsView extends StatelessWidget {
  final String title;
  final List<WatchItem> items;

  const StatsView({super.key, required this.title, required this.items});

  Widget _box(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = items.length;
    final watched = items.where((i) => i.status == 'ดูจบแล้ว').length;
    final favorites = items.where((i) => i.isFavorite).length;
    final rated = items.where((i) => i.point > 0).toList();
    final average = rated.isEmpty ? 0.0 : rated.fold<int>(0, (sum, i) => sum + i.point) / rated.length;

    final counts = <String, int>{};
    for (final i in items) {
      final name = i.genre.isEmpty ? 'ไม่ระบุแนว' : genreOf(i.genre).name;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = counts.values.fold<int>(1, (m, v) => v > m ? v : m);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: cinemaGold),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: cinemaGold, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('ยังไม่มีข้อมูลสำหรับสรุป', style: TextStyle(color: Colors.white54))),
              )
            else ...[
              Row(
                children: [
                  _box('ทั้งหมด', '$total', Icons.movie, cinemaGold),
                  const SizedBox(width: 8),
                  _box('ดูจบแล้ว', '$watched', Icons.check_circle, const Color(0xFF66BB6A)),
                  const SizedBox(width: 8),
                  _box('โปรด', '$favorites', Icons.favorite, Colors.redAccent),
                  const SizedBox(width: 8),
                  _box('คะแนนเฉลี่ย', average.toStringAsFixed(1), Icons.star, const Color(0xFFFFA726)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('แยกตามแนว', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...entries.map((e) {
                final genre = findGenre(e.key);
                final color = genre?.color ?? Colors.white54;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(genre?.icon ?? Icons.movie, color: color, size: 18),
                      const SizedBox(width: 8),
                      SizedBox(width: 78, child: Text(e.key, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: e.value / maxCount),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) => LinearProgressIndicator(
                              value: value,
                              minHeight: 10,
                              color: color,
                              backgroundColor: Colors.white12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${e.value}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class WatchFormPage extends StatefulWidget {
  final WatchItem? existing;
  final String? lockedKind;
  final bool simple;

  const WatchFormPage({
    super.key,
    this.existing,
    this.lockedKind,
    this.simple = false,
  });

  @override
  State<WatchFormPage> createState() => _WatchFormPageState();
}

class _WatchFormPageState extends State<WatchFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _watchedController = TextEditingController();
  final _totalController = TextEditingController();

  String _genre = movieGenres.first.name;
  String _status = watchStatuses.first;
  String _platform = '';
  String _kind = 'หนัง';
  double _point = 0;
  DateTime _date = DateTime.now();
  bool _favorite = false;

  bool get _isEdit => widget.existing != null;
  bool get _isSeries => _kind == 'ซีรีส์';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kind = widget.lockedKind ?? e?.kind ?? 'หนัง';
    if (e != null) {
      _titleController.text = e.title;
      _contentController.text = e.content;
      _genre = genreOf(e.genre).name;
      _status = e.status;
      _platform = e.platform;
      _point = e.point.toDouble();
      _date = DateTime.tryParse(e.date) ?? DateTime.now();
      _favorite = e.isFavorite;
      if (e.watchedEp > 0) _watchedController.text = '${e.watchedEp}';
      if (e.totalEp > 0) _totalController.text = '${e.totalEp}';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _watchedController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  String get _heading {
    if (_isEdit) return 'แก้ไขรายการที่อยากดู';
    if (widget.lockedKind == null) return 'เพิ่มรายการที่อยากดู';
    return _isSeries ? 'เพิ่มซีรีส์ที่อยากดู' : 'เพิ่มหนังที่อยากดู';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final e = widget.existing;
    final total = int.tryParse(_totalController.text.trim()) ?? 0;
    var watched = int.tryParse(_watchedController.text.trim()) ?? 0;
    if (total > 0 && watched > total) watched = total;
    if (_status == 'ดูจบแล้ว' && total > 0) watched = total;
    Navigator.pop(
      context,
      WatchItem(
        id: e?.id,
        remoteId: e?.remoteId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        date: _date.toString().substring(0, 10),
        point: widget.simple ? 0 : _point.round(),
        status: _status,
        isFavorite: _favorite,
        genre: widget.simple ? '' : _genre,
        kind: _kind,
        platform: widget.simple ? '' : _platform,
        watchedEp: _isSeries && !widget.simple ? watched : 0,
        totalEp: _isSeries && !widget.simple ? total : 0,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: const TextStyle(color: cinemaGold, fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  ButtonStyle get _segmentStyle => SegmentedButton.styleFrom(
        backgroundColor: cinemaCard,
        foregroundColor: Colors.white70,
        selectedBackgroundColor: cinemaGold,
        selectedForegroundColor: cinemaBar,
        side: const BorderSide(color: Colors.white24),
      );

  @override
  Widget build(BuildContext context) {
    final dateText = _date.toString().substring(0, 10);
    final pointLabel = _status == 'ดูจบแล้ว' ? 'คะแนนหลังดู' : 'ความอยากดู';

    return Scaffold(
      appBar: AppBar(title: Text(_heading)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            if (widget.lockedKind == null) ...[
              _label('ประเภท'),
              SegmentedButton<String>(
                segments: watchKinds
                    .map((k) => ButtonSegment<String>(
                          value: k,
                          label: Text(k),
                          icon: Icon(k == 'หนัง' ? Icons.movie : Icons.tv),
                        ))
                    .toList(),
                selected: {_kind},
                showSelectedIcon: false,
                style: _segmentStyle,
                onSelectionChanged: (v) => setState(() => _kind = v.first),
              ),
            ],
            _label('ข้อมูลเรื่อง'),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: _isSeries ? 'ชื่อซีรีส์' : 'ชื่อหนัง',
                prefixIcon: Icon(_isSeries ? Icons.tv : Icons.movie),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อเรื่อง' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'เรื่องย่อ / เหตุผลที่อยากดู',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกเรื่องย่อหรือเหตุผล' : null,
            ),
            if (!widget.simple) ...[
              _label('แนวและช่องทางรับชม'),
              DropdownButtonFormField<String>(
                initialValue: _genre,
                decoration: const InputDecoration(labelText: 'แนว', prefixIcon: Icon(Icons.local_movies)),
                items: movieGenres
                    .map((g) => DropdownMenuItem<String>(
                          value: g.name,
                          child: Row(children: [Icon(g.icon, color: g.color, size: 20), const SizedBox(width: 8), Text(g.name)]),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _genre = v);
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _platform,
                decoration: const InputDecoration(labelText: 'ดูได้ที่', prefixIcon: Icon(Icons.live_tv)),
                items: platforms
                    .map((p) => DropdownMenuItem<String>(value: p, child: Text(p.isEmpty ? 'ไม่ระบุ' : p)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _platform = v);
                },
              ),
            ],
            _label('สถานะการดู'),
            SegmentedButton<String>(
              segments: watchStatuses.map((s) => ButtonSegment<String>(value: s, label: Text(s))).toList(),
              selected: {_status},
              showSelectedIcon: false,
              style: _segmentStyle,
              onSelectionChanged: (v) => setState(() => _status = v.first),
            ),
            if (_isSeries && !widget.simple) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _watchedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ดูถึงตอนที่', prefixIcon: Icon(Icons.play_arrow)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _totalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ทั้งหมดกี่ตอน', prefixIcon: Icon(Icons.format_list_numbered)),
                    ),
                  ),
                ],
              ),
            ],
            if (!widget.simple) ...[
              _label('$pointLabel: ${_point.round()}/10'),
              Slider(
                value: _point,
                min: 0,
                max: 10,
                divisions: 10,
                label: '${_point.round()}',
                onChanged: (v) => setState(() => _point = v),
              ),
            ],
            _label(_status == 'ดูจบแล้ว' ? 'วันที่ดูจบ' : 'วันที่ตั้งใจดู'),
            Card(
              shape: cinemaCardShape(Colors.white24),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: cinemaGold),
                title: Text(dateText),
                trailing: const Icon(Icons.edit_calendar, color: cinemaGold),
                onTap: _selectDate,
              ),
            ),
            if (!widget.simple)
              SwitchListTile(
                activeTrackColor: cinemaGold,
                title: const Text('เพิ่มในรายการโปรด', style: TextStyle(color: Colors.white)),
                value: _favorite,
                onChanged: (v) => setState(() => _favorite = v),
              ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _save,
                icon: Icon(_isEdit ? Icons.save : Icons.bookmark_add),
                label: Text(
                  _isEdit ? 'บันทึกการแก้ไข' : 'เพิ่มในรายการ',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  late Future<List<WatchItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getSeries();
  }

  void _reload() {
    setState(() {
      _future = ApiService.getSeries();
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorText(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<void> _add() async {
    final result = await Navigator.push<WatchItem>(
      context,
      MaterialPageRoute(builder: (_) => const WatchFormPage(lockedKind: 'ซีรีส์', simple: true)),
    );
    if (result == null) return;
    try {
      await ApiService.createSeries(result);
      if (!mounted) return;
      _reload();
      _toast('เพิ่มซีรีส์สำเร็จ');
    } catch (e) {
      if (!mounted) return;
      _toast(_errorText(e));
    }
  }

  Future<void> _edit(WatchItem item) async {
    final id = item.remoteId;
    if (id == null) return;
    final result = await Navigator.push<WatchItem>(
      context,
      MaterialPageRoute(builder: (_) => WatchFormPage(existing: item, lockedKind: 'ซีรีส์', simple: true)),
    );
    if (result == null) return;
    try {
      await ApiService.updateSeries(id, result);
      if (!mounted) return;
      _reload();
      _toast('แก้ไขซีรีส์สำเร็จ');
    } catch (e) {
      if (!mounted) return;
      _toast(_errorText(e));
    }
  }

  Future<void> _delete(WatchItem item) async {
    final id = item.remoteId;
    if (id == null) return;
    final ok = await confirmDelete(context, item.title, 'server');
    if (!ok) return;
    try {
      await ApiService.deleteSeries(id);
      if (!mounted) return;
      _reload();
      _toast('ลบซีรีส์สำเร็จ');
    } catch (e) {
      if (!mounted) return;
      _toast(_errorText(e));
    }
  }

  Future<void> _openSearch() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const TvSearchPage()));
    if (!mounted) return;
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: cinemaTitle(Icons.tv, 'ซีรีส์ที่อยากดู'),
        actions: [
          IconButton(tooltip: 'ค้นหาซีรีส์จากเน็ต', icon: const Icon(Icons.travel_explore), onPressed: _openSearch),
          IconButton(tooltip: 'โหลดใหม่', icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      body: FutureBuilder<List<WatchItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: cinemaGold));
          }
          if (snapshot.hasError) {
            return CinemaMessage(
              icon: Icons.cloud_off,
              title: 'โหลดรายการซีรีส์ไม่ได้',
              subtitle: _errorText(snapshot.error!),
              action: FilledButton.icon(onPressed: _reload, icon: const Icon(Icons.refresh), label: const Text('ลองใหม่')),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const CinemaMessage(
              icon: Icons.tv,
              title: 'ยังไม่มีซีรีส์ที่อยากดู',
              subtitle: 'กดปุ่ม "เพิ่มซีรีส์" หรือค้นหาซีรีส์จากอินเทอร์เน็ตด้วยไอคอนด้านบน',
            );
          }
          return RefreshIndicator(
            color: cinemaGold,
            backgroundColor: cinemaCard,
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return WatchCard(
                  item: item,
                  index: i,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailPage(item: item)),
                  ),
                  onEdit: () => _edit(item),
                  onDelete: () => _delete(item),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: cinemaGold,
        foregroundColor: cinemaBar,
        icon: const Icon(Icons.add_to_queue),
        label: const Text('เพิ่มซีรีส์', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class TvSearchPage extends StatefulWidget {
  const TvSearchPage({super.key});

  @override
  State<TvSearchPage> createState() => _TvSearchPageState();
}

class _TvSearchPageState extends State<TvSearchPage> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<TvShow>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchTvShows('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    setState(() {
      _future = ApiService.fetchTvShows(_controller.text.trim());
    });
  }

  Future<void> _save(TvShow show) async {
    final summary = show.summary.isEmpty ? 'ซีรีส์จาก TVmaze' : show.summary;
    final item = WatchItem(
      title: show.name,
      content: summary.length > 400 ? summary.substring(0, 400) : summary,
      date: DateTime.now().toString().substring(0, 10),
      kind: 'ซีรีส์',
    );
    try {
      await ApiService.createSeries(item);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เพิ่ม "${show.name}" ในรายการแล้ว')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Widget _showCard(TvShow show, int index) {
    return FadeSlideIn(
      index: index,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: cinemaCardShape(cinemaGold),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: cinemaGold.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.tv, color: cinemaGold, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(show.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (show.rating > 0) WatchTag(icon: Icons.star, text: show.rating.toStringAsFixed(1), color: cinemaGold),
                            if (show.premiered != '-') WatchTag(icon: Icons.calendar_month, text: show.premiered, color: Colors.white70),
                            if (show.network.isNotEmpty) WatchTag(icon: Icons.live_tv, text: show.network, color: const Color(0xFF42A5F5)),
                          ],
                        ),
                        if (show.genres.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(show.genres.join(' • '), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          show.summary.isEmpty ? 'ไม่มีเรื่องย่อ' : show.summary,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _save(show),
                  icon: const Icon(Icons.bookmark_add),
                  label: const Text('เพิ่มในรายการอยากดู', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: cinemaTitle(Icons.travel_explore, 'ซีรีส์จากอินเทอร์เน็ต'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อซีรีส์ (ภาษาอังกฤษ) เว้นว่างเพื่อสุ่ม',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: cinemaGold),
                suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward, color: cinemaGold), onPressed: _search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<TvShow>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: cinemaGold));
          }
          if (snapshot.hasError) {
            return CinemaMessage(
              icon: Icons.cloud_off,
              title: 'โหลดข้อมูลซีรีส์ไม่ได้',
              subtitle: snapshot.error.toString().replaceFirst('Exception: ', ''),
              action: FilledButton.icon(onPressed: _search, icon: const Icon(Icons.refresh), label: const Text('ลองใหม่')),
            );
          }
          final shows = snapshot.data ?? [];
          if (shows.isEmpty) {
            return const CinemaMessage(icon: Icons.search_off, title: 'ไม่พบซีรีส์ที่ค้นหา', subtitle: 'ลองใช้ชื่อภาษาอังกฤษ');
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 6, bottom: 24),
            itemCount: shows.length + 1,
            itemBuilder: (context, i) {
              if (i == shows.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('ข้อมูลและรูปภาพจาก TVmaze.com', style: TextStyle(color: Colors.white38, fontSize: 12))),
                );
              }
              return _showCard(shows[i], i);
            },
          );
        },
      ),
    );
  }
}
