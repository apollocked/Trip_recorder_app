import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/model/trip_category.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/app_text_field.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/category_selector.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/currency_dropdown.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/date_picker_field.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/notification_permission.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/save_button.dart';
import 'package:animations_in_flutter/views/widgets/star_rating.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/trip_image_picker.dart';

class AddTripPage extends StatefulWidget {
  final String? tripId;
  const AddTripPage({super.key, this.tripId});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _nightsController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  final List<File> _imageFiles = [];
  List<String> _existingImagePaths = [];
  bool _imageError = false;
  bool _isSaving = false;
  TripCategory _selectedCategory = TripCategory.other;
  double _rating = 0.0;
  String _selectedCurrency = 'USD';
  DateTime? _reminderDate;

  @override
  void initState() {
    super.initState();
    if (widget.tripId != null) {
      final trip = context.read<TripProvider>().getTripById(widget.tripId!);
      if (trip != null) {
        _titleController.text = trip.title;
        _priceController.text = trip.price.toStringAsFixed(0);
        _nightsController.text = trip.nights.toString();
        _descriptionController.text = trip.description;
        _selectedDate = trip.date;
        _existingImagePaths = List.from(trip.imagePaths);
        _selectedCategory = trip.category;
        _rating = trip.rating;
        _selectedCurrency = trip.currency;
        _reminderDate = trip.reminderDate;
      }
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _nightsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final isFormValid = _formKey.currentState!.validate();
    final hasImages = _imageFiles.isNotEmpty || _existingImagePaths.isNotEmpty;
    setState(() => _imageError = !hasImages);
    if (!isFormValid || !hasImages) {
      if (!hasImages) HapticFeedback.vibrate();
      return;
    }
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    try {
      final assetPaths = _existingImagePaths
          .where((p) => p.startsWith('images/'))
          .toList();
      if (_reminderDate != null) {
        final granted = await requestNotificationPermission(context);
        if (!granted) {
          if (mounted) setState(() => _isSaving = false);
          return;
        }
        if (!mounted) return;
      }
      final String title = _titleController.text.trim();
      final double price = double.tryParse(_priceController.text.trim()) ?? 0;
      final int nights = int.tryParse(_nightsController.text.trim()) ?? 1;
      final String desc = _descriptionController.text.trim();
      if (widget.tripId != null) {
        await context.read<TripProvider>().updateTrip(
          widget.tripId!,
          title: title,
          price: price,
          nights: nights,
          imageFiles: _imageFiles.isNotEmpty ? _imageFiles : null,
          existingImagePaths: _imageFiles.isEmpty ? _existingImagePaths : null,
          assetImagePaths: assetPaths.isNotEmpty ? assetPaths : null,
          date: _selectedDate,
          description: desc,
          category: _selectedCategory,
          rating: _rating,
          currency: _selectedCurrency,
          reminderDate: _reminderDate,
        );
      } else {
        await context.read<TripProvider>().addTrip(
          title: title,
          price: price,
          nights: nights,
          imageFiles: _imageFiles,
          assetImagePaths: _existingImagePaths
              .where((p) => p.startsWith('images/'))
              .toList(),
          date: _selectedDate,
          description: desc,
          category: _selectedCategory,
          rating: _rating,
          currency: _selectedCurrency,
          reminderDate: _reminderDate,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorSavingTrip(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.tripId != null;

    Widget labeled(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          title: Text(
            isEditing ? l10n.editJourney : l10n.addtitle,
            semanticsLabel: isEditing
                ? l10n.editFormSemantics
                : l10n.addFormSemantics,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.coverphoto,
                  style: textTheme.labelLarge?.copyWith(
                    color: _imageError
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TripImagePicker(
                  imageFiles: _imageFiles,
                  existingImagePaths: _existingImagePaths,
                  imageError: _imageError,
                  onImagesAdded: (files) => setState(() {
                    _imageFiles.addAll(files);
                    _imageError = false;
                  }),
                  onImageRemovedAt: (index) => setState(() {
                    if (index < _imageFiles.length) {
                      _imageFiles.removeAt(index);
                    } else {
                      _existingImagePaths.removeAt(index - _imageFiles.length);
                    }
                  }),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  l10n: l10n,
                ),
                if (_imageError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      l10n.photoErrorReq,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                labeled(
                  l10n.rateTrip,
                  Center(
                    child: StarRating(
                      rating: _rating,
                      size: 36,
                      interactive: true,
                      onChanged: (val) => setState(() => _rating = val),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                labeled(
                  l10n.tripCategory,
                  CategorySelector(
                    selectedCategory: _selectedCategory,
                    onChanged: (cat) => setState(() => _selectedCategory = cat),
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(height: 24),
                labeled(
                  l10n.currencyLabel,
                  CurrencyDropdown(
                    selectedCurrency: _selectedCurrency,
                    onChanged: (val) => setState(() => _selectedCurrency = val),
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.tripDetails,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _titleController,
                  label: l10n.destination,
                  icon: Icons.map_rounded,
                  colorScheme: colorScheme,
                  validator: (val) => val == null || val.isEmpty
                      ? l10n.destinationRequired
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _priceController,
                        label: l10n.budget,
                        icon: Icons.attach_money_rounded,
                        colorScheme: colorScheme,
                        keyboardType: TextInputType.number,
                        prefixText:
                            '${CurrencyInfo.symbolFor(_selectedCurrency)} ',
                        validator: (val) =>
                            val == null || val.isEmpty ? l10n.required : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        controller: _nightsController,
                        label: l10n.nights,
                        icon: Icons.bedtime_rounded,
                        colorScheme: colorScheme,
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            val == null || val.isEmpty ? l10n.required : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DatePickerField(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.departureDate,
                  currentDate: _selectedDate,
                  onDateChanged: (d) => setState(() => _selectedDate = d),
                  colorScheme: colorScheme,
                  l10n: l10n,
                ),
                const SizedBox(height: 16),
                DatePickerField(
                  icon: Icons.notifications_active_rounded,
                  label: l10n.setReminder,
                  currentDate: _reminderDate,
                  onDateChanged: (d) => setState(() => _reminderDate = d),
                  isOptional: true,
                  colorScheme: colorScheme,
                  l10n: l10n,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: l10n.tripDescription,
                  icon: Icons.notes_rounded,
                  colorScheme: colorScheme,
                  maxLines: 4,
                  maxLength: 1000,
                ),
                const SizedBox(height: 40),
                SaveButton(
                  isSaving: _isSaving,
                  isEditing: isEditing,
                  onPressed: _handleSave,
                  updateText: l10n.updateJourney,
                  createText: l10n.createJourney,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
