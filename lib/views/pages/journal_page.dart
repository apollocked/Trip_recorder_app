import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/l10n/l10n.dart';
import 'package:animations_in_flutter/model/journal_entry.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/confirmation_dialog.dart';
import 'package:animations_in_flutter/views/shimmer/shimmer_journal_page.dart';
import 'package:animations_in_flutter/views/widgets/cover_image_leading.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';
import 'package:animations_in_flutter/views/widgets/journal/journal_entry_dialog.dart';

class JournalPage extends StatefulWidget {
  final String tripId;
  const JournalPage({super.key, required this.tripId});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  List<JournalEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await context.read<TripProvider>().getJournalEntries(
        widget.tripId,
      );
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingData(e.toString()))),
        );
      }
    }
  }

  Future<void> _showAddEntryDialog() async {
    final result = await showJournalEntryDialog(context);
    if (result != null && mounted) {
      final imagePaths = (result['images'] as List<File>)
          .map((f) => f.path)
          .toList();
      await context.read<TripProvider>().addJournalEntry(
        tripId: widget.tripId,
        title: result['title'],
        text: result['text'],
        date: result['date'],
        imagePaths: imagePaths,
      );
      _loadEntries();
    }
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    await context.read<TripProvider>().deleteJournalEntry(
      widget.tripId,
      entry.id,
    );
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.journal,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddEntryDialog,
            tooltip: l10n.addJournalEntry,
          ),
        ],
      ),
      body: _isLoading
          ? const ShimmerJournalPage()
          : RefreshIndicator(
              onRefresh: _loadEntries,
              child: _entries.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15,
                        ),
                        EmptyState(
                          icon: Icons.article_rounded,
                          title: l10n.noJournalEntries,
                          subtitle: l10n.journalTextHint,
                          action: FilledButton.tonalIcon(
                            onPressed: _showAddEntryDialog,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(l10n.addJournalEntry),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 92),
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return Dismissible(
                          key: ValueKey(entry.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) => showConfirmationDialog(
                            context: context,
                            title: l10n.confirmDeleteTitle(entry.title),
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
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.delete_rounded,
                              color: colorScheme.onError,
                            ),
                          ),
                          onDismissed: (_) => _deleteEntry(entry),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.title,
                                          style: textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        l10n.formatDateAbbreviated(entry.date),
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (entry.text.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.text,
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                  if (entry.imagePaths.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 80,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: entry.imagePaths.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (_, i) => ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: coverImage(
                                            entry.imagePaths[i],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
