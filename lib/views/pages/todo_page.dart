import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  static const _key = 'todo_prep';
  List<_PrepItem> _items = [];
  final _c = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final r = p.getString(_key);
      if (r != null && r.isNotEmpty) {
        final list = jsonDecode(r) as List;
        _items = list.map((e) => _PrepItem.fromJson(e as Map<String, dynamic>)).toList();
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key, jsonEncode(_items.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void _add() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    _c.clear();
    setState(() => _items = [_PrepItem(title: t), ..._items]);
    _save();
  }

  void _toggle(int i) {
    HapticFeedback.selectionClick();
    setState(() {
      _items = [
        for (int j = 0; j < _items.length; j++)
          j == i ? _items[j].copyWith(done: !_items[j].done) : _items[j],
      ];
    });
    _save();
  }

  void _delete(int i) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle(_items[i].title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _items = [..._items.take(i), ..._items.skip(i + 1)]);
              _save();
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _clearDone() {
    final before = _items.length;
    setState(() => _items = _items.where((e) => !e.done).toList());
    if (_items.length < before) _save();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final hasDone = _items.any((e) => e.done);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        title: Text(l10n.todo, style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _c,
                    decoration: InputDecoration(
                      hintText: l10n.addItemHint,
                      filled: true,
                      fillColor: c.surfaceContainerHighest.withAlpha(80),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _add,
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          if (hasDone)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearDone,
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: Text(l10n.delete),
              ),
            ),
          Expanded(
            child: _items.isEmpty
                ? EmptyState(icon: Icons.assignment_rounded, title: l10n.noItemsYet)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: c.outlineVariant.withAlpha(80)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 4, right: 8),
                          leading: Checkbox(
                            value: item.done,
                            onChanged: (_) => _toggle(i),
                            shape: const CircleBorder(),
                          ),
                          title: Text(
                            item.title,
                            style: t.bodyLarge?.copyWith(
                              decoration: item.done ? TextDecoration.lineThrough : null,
                              color: item.done ? c.onSurfaceVariant : c.onSurface,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: c.error, size: 20),
                            onPressed: () => _delete(i),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PrepItem {
  final String title;
  final bool done;

  const _PrepItem({required this.title, this.done = false});

  _PrepItem copyWith({bool? done}) => _PrepItem(title: title, done: done ?? this.done);

  factory _PrepItem.fromJson(Map<String, dynamic> json) => _PrepItem(
    title: json['title'] as String,
    done: json['done'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {'title': title, 'done': done};
}
