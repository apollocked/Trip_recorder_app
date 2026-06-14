import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/journal_entry.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/confirmation_dialog.dart';
import 'package:animations_in_flutter/views/widgets/cover_image_leading.dart';
import 'package:animations_in_flutter/views/widgets/permission_dialog.dart';

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
      final entries = await context.read<TripProvider>().getJournalEntries(widget.tripId);
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorSavingTrip(e.toString()))));
      }
    }
  }

  Future<void> _showAddEntryDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final textController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    List<File> selectedImages = [];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.addJournalEntry),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: l10n.journalTitle, hintText: l10n.journalTitleHint),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: l10n.journalText, hintText: l10n.journalTextHint),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setDialogState(() => selectedDate = date);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: l10n.departureDate, prefixIcon: const Icon(Icons.calendar_today_rounded)),
                    child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(l10n.coverphoto, style: Theme.of(ctx).textTheme.bodySmall),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => pickMultipleImages(ctx, (files) {
                        setDialogState(() => selectedImages.addAll(files));
                      }),
                      icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                      label: Text(l10n.addMorePhotos),
                    ),
                  ],
                ),
                if (selectedImages.isNotEmpty)
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(selectedImages[i], width: 80, height: 80, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 0, right: 0,
                            child: GestureDetector(
                              onTap: () => setDialogState(() => selectedImages.removeAt(i)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.notNow)),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                Navigator.pop(ctx, {
                  'title': titleController.text.trim(),
                  'text': textController.text.trim(),
                  'date': selectedDate,
                  'images': selectedImages,
                });
              },
              child: Text(l10n.addJournalEntry),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      final imagePaths = (result['images'] as List<File>).map((f) => f.path).toList();
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
    await context.read<TripProvider>().deleteJournalEntry(widget.tripId, entry.id);
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
        title: Text(l10n.journal, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEntries,
              child: _entries.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.article_rounded, size: 64, color: colorScheme.onSurfaceVariant.withAlpha(80)),
                              const SizedBox(height: 16),
                              Text(l10n.noJournalEntries, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
                              const SizedBox(height: 24),
                              FilledButton.tonalIcon(
                                onPressed: _showAddEntryDialog,
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: Text(l10n.addJournalEntry),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
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
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: colorScheme.error, borderRadius: BorderRadius.circular(20)),
                            child: Icon(Icons.delete_rounded, color: colorScheme.onError),
                          ),
                          onDismissed: (_) => _deleteEntry(entry),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(entry.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                      ),
                                      Text(
                                        '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  if (entry.text.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(entry.text, style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.5)),
                                  ],
                                  if (entry.imagePaths.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 80,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: entry.imagePaths.length,
                                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                                        itemBuilder: (_, i) => ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: coverImage(entry.imagePaths[i]),
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
