import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/views/widgets/permission_dialog.dart';

Future<Map<String, dynamic>?> showJournalEntryDialog(
  BuildContext context,
) async {
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
                inputFormatters: [LengthLimitingTextInputFormatter(120)],
                decoration: InputDecoration(
                  labelText: l10n.journalTitle,
                  hintText: l10n.journalTitleHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
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
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setDialogState(() => selectedDate = date);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.departureDate,
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    l10n.coverphoto,
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => pickMultipleImages(ctx, (files) {
                      setDialogState(() => selectedImages.addAll(files));
                    }),
                    icon: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 18,
                    ),
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
                          child: Image.file(
                            selectedImages[i],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => setDialogState(
                              () => selectedImages.removeAt(i),
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.notNow),
          ),
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

  titleController.dispose();
  textController.dispose();
  return result;
}
