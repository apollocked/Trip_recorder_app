import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/views/widgets/common/permission_dialog.dart';

Future<Map<String, dynamic>?> showJournalEntryDialog(BuildContext context) =>
    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _JournalEntryDialog(),
    );

class _JournalEntryDialog extends StatefulWidget {
  const _JournalEntryDialog();

  @override
  State<_JournalEntryDialog> createState() => _JournalEntryDialogState();
}

class _JournalEntryDialogState extends State<_JournalEntryDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  DateTime _selectedDate = DateTime.now();
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.addJournalEntry),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              inputFormatters: [LengthLimitingTextInputFormatter(120)],
              decoration: InputDecoration(
                labelText: l10n.journalTitle,
                hintText: l10n.journalTitleHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 4,
              inputFormatters: [LengthLimitingTextInputFormatter(2000)],
              decoration: InputDecoration(
                labelText: l10n.journalText,
                hintText: l10n.journalTextHint,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.departureDate,
                  prefixIcon: const Icon(Icons.calendar_today_rounded),
                ),
                child: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.coverphoto,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => pickMultipleImages(context, (files) {
                    setState(() => _selectedImages.addAll(files));
                  }),
                  icon: const Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 18,
                  ),
                  label: Text(l10n.addMorePhotos),
                ),
              ],
            ),
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[i],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _selectedImages.removeAt(i),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.imageOverlay,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.white,
                            ),
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.notNow),
        ),
        FilledButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) return;
            Navigator.pop(context, {
              'title': _titleController.text.trim(),
              'text': _textController.text.trim(),
              'date': _selectedDate,
              'images': _selectedImages,
            });
          },
          child: Text(l10n.addJournalEntry),
        ),
      ],
    );
  }
}
