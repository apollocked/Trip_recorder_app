import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/views/widgets/confirmation_dialog.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';

enum _Cat {
  docs(Icons.folder_rounded),
  clothes(Icons.checkroom_rounded),
  elec(Icons.phone_android_rounded),
  toilet(Icons.clean_hands_rounded),
  other(Icons.more_horiz_rounded);

  final IconData icon;
  const _Cat(this.icon);

  String label(AppLocalizations l10n) => switch (this) {
    _Cat.docs => l10n.prepCatDocuments,
    _Cat.clothes => l10n.prepCatClothing,
    _Cat.elec => l10n.prepCatElectronics,
    _Cat.toilet => l10n.prepCatToiletries,
    _Cat.other => l10n.categoryOther,
  };
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  static const _key = 'todo_prep';
  List<_PrepItem> _items = [];
  final _c = TextEditingController();
  var _cat = _Cat.other;

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
        _items = list
            .map((e) => _PrepItem.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
        _key,
        jsonEncode(_items.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  void _add(String title) {
    if (title.trim().isEmpty) return;
    _c.clear();
    setState(
      () =>
          _items = [_PrepItem(title: title.trim(), category: _cat), ..._items],
    );
    _save();
  }

  void _toggle(int i) {
    HapticFeedback.selectionClick();
    setState(
      () => _items = [
        for (int j = 0; j < _items.length; j++)
          j == i ? _items[j].copyWith(done: !_items[j].done) : _items[j],
      ],
    );
    _save();
  }

  void _removeAt(int i) {
    setState(() => _items = [..._items.take(i), ..._items.skip(i + 1)]);
    _save();
  }

  void _clearDone() {
    final b = _items.length;
    setState(() => _items = _items.where((e) => !e.done).toList());
    if (_items.length < b) _save();
  }

  void _showAddDialog() {
    _c.clear();
    _cat = _Cat.other;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(l10n.addItem),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _c,
                autofocus: true,
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
                decoration: InputDecoration(
                  hintText: l10n.addItemHint,
                  filled: true,
                  fillColor: Theme.of(
                    ctx,
                  ).colorScheme.surfaceContainerHighest.withAlpha(80),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) {
                    _add(v);
                    Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                l10n.tripCategory,
                style: Theme.of(
                  ctx,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _Cat.values.map((cat) {
                  final sel = cat == _cat;
                  return ChoiceChip(
                    selected: sel,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 16,
                          color: sel
                              ? Theme.of(ctx).colorScheme.onPrimaryContainer
                              : null,
                        ),
                        const SizedBox(width: 4),
                        Text(cat.label(l10n)),
                      ],
                    ),
                    onSelected: (_) => setDlg(() => _cat = cat),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (_c.text.trim().isNotEmpty) {
                  _add(_c.text);
                  Navigator.pop(ctx);
                }
              },
              child: Text(l10n.addItem),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final hasDone = _items.any((e) => e.done);
    final checked = _items.where((e) => e.done).length;
    final map = <_Cat, List<_PrepItem>>{};
    for (final cat in _Cat.values) {
      map[cat] = [];
    }
    for (final i in _items) {
      map[i.category]!.add(i);
    }
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        title: Text(
          l10n.todo,
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(onPressed: _showAddDialog, child: Text(l10n.addItem)),
          if (hasDone)
            IconButton(
              onPressed: _clearDone,
              icon: const Icon(Icons.clear_all_rounded),
              tooltip: l10n.delete,
            ),
        ],
      ),
      body: _items.isEmpty
          ? ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                EmptyState(
                  icon: Icons.checklist_rounded,
                  title: l10n.noItemsYet,
                  subtitle: l10n.addItemHint,
                  description: l10n.prepDescription,
                  action: FilledButton.tonalIcon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(l10n.addItem),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: checked / _items.length,
                      minHeight: 6,
                      backgroundColor: c.surfaceContainerHighest,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    l10n.itemsChecked(checked, _items.length),
                    style: t.labelSmall?.copyWith(color: c.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 88,
                    ),
                    children: _buildSections(map, c, t, l10n),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildSections(
    Map<_Cat, List<_PrepItem>> map,
    ColorScheme c,
    TextTheme t,
    AppLocalizations l10n,
  ) {
    final r = <Widget>[];
    var idx = 0;
    for (final cat in _Cat.values) {
      final items = map[cat]!;
      if (items.isEmpty) continue;
      final ck = items.where((e) => e.done).length;

      r.add(
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 12, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(cat.icon, size: 18, color: c.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cat.label(l10n),
                      style: t.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: c.primaryContainer.withAlpha(120),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$ck/${items.length}',
                      style: t.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: c.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              if (items.length > 1) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ck / items.length,
                    minHeight: 4,
                    backgroundColor: c.surfaceContainerHighest,
                  ),
                ),
              ],
            ],
          ),
        ),
      );

      for (final item in items) {
        final i = idx++;
        r.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Dismissible(
              key: ValueKey('prep_${item._seq}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => showConfirmationDialog(
                context: context,
                title: l10n.confirmDeleteTitle(item.title),
                message: l10n.confirmDeleteMessage,
                icon: Icons.delete_rounded,
              ),
              background: Container(
                alignment: Directionality.of(context) == TextDirection.rtl
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                padding: EdgeInsets.only(
                  right: Directionality.of(context) == TextDirection.rtl ? 0 : 20,
                  left: Directionality.of(context) == TextDirection.rtl ? 20 : 0,
                ),
                decoration: BoxDecoration(
                  color: c.error,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.delete_rounded, color: c.onError),
              ),
              onDismissed: (_) => _removeAt(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: item.done
                      ? c.primaryContainer.withAlpha(50)
                      : c.surfaceContainerHighest.withAlpha(60),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: item.done
                        ? c.primary.withAlpha(80)
                        : c.outlineVariant.withAlpha(128),
                  ),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: CheckboxListTile(
                    value: item.done,
                    onChanged: (_) => _toggle(i),
                    title: Text(
                      item.title,
                      style: t.bodyLarge?.copyWith(
                        decoration: item.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.done ? c.onSurfaceVariant : c.onSurface,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.only(left: 4, right: 8),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return r;
  }
}

class _PrepItem {
  final String title;
  final bool done;
  final _Cat category;
  final int _seq;
  _PrepItem({
    required this.title,
    this.done = false,
    this.category = _Cat.other,
  }) : _seq = _seqCounter++;
  static int _seqCounter = 0;

  _PrepItem copyWith({bool? done}) => _PrepItem._(
    title: title,
    done: done ?? this.done,
    category: category,
    seq: _seq,
  );
  _PrepItem._({
    required this.title,
    this.done = false,
    required this.category,
    required int seq,
  }) : _seq = seq;

  factory _PrepItem.fromJson(Map<String, dynamic> json) {
    final ci = json['category'] as int? ?? 4;
    return _PrepItem(
      title: json['title'] as String,
      done: json['done'] as bool? ?? false,
      category: _Cat.values[ci.clamp(0, 4)],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'done': done,
    'category': category.index,
  };
}
