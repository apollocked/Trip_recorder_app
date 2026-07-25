import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip_category.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/services/premium_service.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/app_text_field.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/date_picker_field.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/future_trip_banner.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/notification_permission.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/past_trip_fields.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/save_button.dart';
import 'package:animations_in_flutter/views/widgets/shared/premium_popup.dart';

class AddTripPage extends StatefulWidget {
  final String? tripId;
  final bool? isFutureTrip;
  const AddTripPage({super.key, this.tripId, this.isFutureTrip});

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

  bool get _isFuture => _selectedDate.isAfter(DateTime.now());

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
      _selectedDate = widget.isFutureTrip == true
          ? DateTime.now().add(const Duration(days: 1))
          : DateTime.now();
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
    final premium = context.read<PremiumService>();
    if (widget.tripId == null && !premium.canAddTrip) {
      if (mounted) {
        final result = await PremiumPopup.show(context);
        if (result == true && mounted) {
          await premium.activatePremium();
        }
      }
      return;
    }
    final isFormValid = _formKey.currentState!.validate();
    final hasImages = _imageFiles.isNotEmpty || _existingImagePaths.isNotEmpty;
    if (!_isFuture) setState(() => _imageError = !hasImages);
    if (!isFormValid || (!_isFuture && !hasImages)) {
      if (!_isFuture && !hasImages) HapticFeedback.vibrate();
      return;
    }
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    try {
      if (_isFuture && !await requestNotificationPermission(context)) {
        if (mounted) setState(() => _isSaving = false);
        return;
      }
      if (!mounted) return;
      final title = _titleController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0;
      final nights = int.tryParse(_nightsController.text.trim()) ?? (_isFuture ? 0 : 1);
      final desc = _descriptionController.text.trim();
      final reminderToUse = _isFuture ? _selectedDate : _reminderDate;
      final assetPaths =
          _existingImagePaths.where((p) => p.startsWith('images/')).toList();
      final provider = context.read<TripProvider>();
      if (widget.tripId != null) {
        await provider.updateTrip(
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
          reminderDate: reminderToUse,
        );
      } else {
        await provider.addTrip(
          title: title,
          price: price,
          nights: nights,
          imageFiles: _imageFiles,
          assetImagePaths: assetPaths,
          date: _selectedDate,
          description: desc,
          category: _selectedCategory,
          rating: _rating,
          currency: _selectedCurrency,
          reminderDate: reminderToUse,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSavingTrip(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.tripId != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: cs.surface,
          elevation: 0,
          title: Text(
            isEditing ? l10n.editJourney : l10n.addtitle,
            semanticsLabel:
                isEditing ? l10n.editFormSemantics : l10n.addFormSemantics,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 92),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isFuture)
                  PastTripFields(
                    imageFiles: _imageFiles,
                    existingImagePaths: _existingImagePaths,
                    imageError: _imageError,
                    rating: _rating,
                    selectedCategory: _selectedCategory,
                    selectedCurrency: _selectedCurrency,
                    priceController: _priceController,
                    nightsController: _nightsController,
                    colorScheme: cs,
                    textTheme: tt,
                    l10n: l10n,
                    onImagesAdded: (files) =>
                        setState(() { _imageFiles.addAll(files); _imageError = false; }),
                    onImageRemovedAt: (index) => setState(() {
                      if (index < _imageFiles.length) {
                        _imageFiles.removeAt(index);
                      } else {
                        _existingImagePaths.removeAt(index - _imageFiles.length);
                      }
                    }),
                    onRatingChanged: (val) => setState(() => _rating = val),
                    onCategoryChanged: (cat) =>
                        setState(() => _selectedCategory = cat),
                    onCurrencyChanged: (val) =>
                        setState(() => _selectedCurrency = val),
                  ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _titleController,
                  label: l10n.destination,
                  icon: Icons.map_rounded,
                  colorScheme: cs,
                  validator: (val) =>
                      val == null || val.isEmpty ? l10n.destinationRequired : null,
                ),
                const SizedBox(height: 16),
                DatePickerField(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.departureDate,
                  currentDate: _selectedDate,
                  onDateChanged: (d) => setState(() => _selectedDate = d),
                  colorScheme: cs,
                  l10n: l10n,
                ),
                if (_isFuture) ...[
                  const SizedBox(height: 12),
                  FutureTripBanner(colorScheme: cs, textTheme: tt, l10n: l10n),
                ],
                if (_isFuture) ...[
                  const SizedBox(height: 16),
                  DatePickerField(
                    icon: Icons.notifications_active_rounded,
                    label: l10n.setReminder,
                    currentDate: _reminderDate,
                    onDateChanged: (d) => setState(() => _reminderDate = d),
                    isOptional: true,
                    colorScheme: cs,
                    l10n: l10n,
                  ),
                ],
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: l10n.tripDescription,
                  icon: Icons.notes_rounded,
                  colorScheme: cs,
                  maxLines: 4,
                  maxLength: 1000,
                ),
                const SizedBox(height: 40),
                SaveButton(
                  isSaving: _isSaving,
                  isEditing: isEditing,
                  onPressed: _handleSave,
                  updateText: l10n.updateJourney,
                  createText: _isFuture ? l10n.planTrip : l10n.createJourney,
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
