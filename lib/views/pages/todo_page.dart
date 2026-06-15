import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  static const _storageKey = 'todo_items';
  List<_TodoItem> _items = [];
  final _controller = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _items = list.map((e) => _TodoItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.insert(0, _TodoItem(title: text));
    });
    _saveItems();
    _controller.clear();
  }

  void _toggleItem(int index) {
    HapticFeedback.selectionClick();
    setState(() => _items[index].isDone = !_items[index].isDone);
    _saveItems();
  }

  void _removeItem(int index) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle(_items[index].title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(onPressed: () {
            Navigator.pop(ctx);
            setState(() => _items.removeAt(index));
            _saveItems();
          }, child: Text(l10n.delete)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.todo, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.addItemHint,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addItem,
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: !_loaded
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.checklist_rounded, size: 72, color: colorScheme.onSurfaceVariant.withAlpha(80)),
                            const SizedBox(height: 16),
                            Text(l10n.noItemsYet, style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: ListView.builder(
                          key: ValueKey(_items.length),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _TodoTile(
                              item: item,
                              onToggle: () => _toggleItem(index),
                              onDelete: () => _removeItem(index),
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final _TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _TodoTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 4, right: 8),
        leading: Checkbox(
          value: item.isDone,
          onChanged: (_) => onToggle(),
          shape: const CircleBorder(),
        ),
        title: Text(
          item.title,
          style: textTheme.bodyLarge?.copyWith(
            decoration: item.isDone ? TextDecoration.lineThrough : null,
            color: item.isDone ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error, size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _TodoItem {
  final String title;
  bool isDone;

  _TodoItem({required this.title, this.isDone = false});

  factory _TodoItem.fromJson(Map<String, dynamic> json) => _TodoItem(
    title: json['title'] as String,
    isDone: json['isDone'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};
}
