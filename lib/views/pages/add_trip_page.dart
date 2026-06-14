import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/permission_dialog.dart';

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
  File? _imageFile;
  String? _existingImagePath;
  bool _imageError = false;
  bool _isSaving = false;

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
        _existingImagePath = trip.imagePath;
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
    final isImageValid = _imageFile != null || _existingImagePath != null;

    setState(() {
      _imageError = !isImageValid;
    });

    if (!isFormValid || !isImageValid) {
      if (!isImageValid) HapticFeedback.vibrate();
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      if (widget.tripId != null) {
        await context.read<TripProvider>().updateTrip(
          widget.tripId!,
          title: _titleController.text.trim(),
          price: double.tryParse(_priceController.text.trim()) ?? 0,
          nights: int.tryParse(_nightsController.text.trim()) ?? 1,
          imageFile: _imageFile,
          existingImagePath: _imageFile == null ? _existingImagePath : null,
          date: _selectedDate,
          description: _descriptionController.text.trim(),
        );
      } else {
        await context.read<TripProvider>().addTrip(
          title: _titleController.text.trim(),
          price: double.tryParse(_priceController.text.trim()) ?? 0,
          nights: int.tryParse(_nightsController.text.trim()) ?? 1,
          imageFile: _imageFile,
          assetImagePath: _existingImagePath?.startsWith('images/') == true
              ? _existingImagePath
              : null,
          date: _selectedDate,
          description: _descriptionController.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving trip: $e')),
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
                ? "Edit Journey form"
                : "Add New Journey form",
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
                  semanticsLabel:
                      "Section for adding a cover photo for the trip",
                  style: textTheme.labelLarge?.copyWith(
                    color: _imageError
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    checkExistingPermissions(context, (pickedFile) {
                      setState(() {
                        _imageFile = pickedFile;
                        _imageError = false;
                      });
                    });
                  },
                  child: Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _imageError
                          ? colorScheme.errorContainer.withAlpha(200)
                          : colorScheme.secondaryContainer.withAlpha(102),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _imageError
                            ? colorScheme.error
                            : colorScheme.outlineVariant,
                        width: _imageError ? 2 : 1,
                      ),
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : (_existingImagePath != null
                                ? DecorationImage(
                                    image:
                                        _existingImagePath!.startsWith(
                                          'images/',
                                        )
                                        ? AssetImage(_existingImagePath!)
                                              as ImageProvider
                                        : FileImage(File(_existingImagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                    ),
                    child: (_imageFile == null && _existingImagePath == null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                size: 42,
                                color: _imageError
                                    ? colorScheme.error
                                    : colorScheme.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.photoreq,
                                semanticsLabel:
                                    "Image is required for the trip",
                                style: TextStyle(
                                  color: _imageError
                                      ? colorScheme.error
                                      : colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                if (_imageError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      l10n.photoErrorReq,
                      semanticsLabel: "Image is required for the trip",
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
                Text(
                  l10n.tripDetails,
                  semanticsLabel: "Section for entering trip details",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                Semantics(
                  label: "Destination you are travelled to input field",
                  child: _buildTextField(
                    controller: _titleController,
                    label: l10n.destination,
                    icon: Icons.map_rounded,
                    colorScheme: colorScheme,
                    validator: (val) => val == null || val.isEmpty
                        ? l10n.destinationRequired
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Semantics(
                        label: "Trip budget input field",
                        child: _buildTextField(
                          controller: _priceController,
                          label: l10n.budget,
                          icon: Icons.attach_money_rounded,
                          colorScheme: colorScheme,
                          keyboardType: TextInputType.number,
                          isPrice: true,
                          validator: (val) =>
                              val == null || val.isEmpty ? l10n.required : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Semantics(
                        label: "Number of nights you stayed input field",
                        child: _buildTextField(
                          controller: _nightsController,
                          label: l10n.nights,
                          icon: Icons.bedtime_rounded,
                          colorScheme: colorScheme,
                          keyboardType: TextInputType.number,
                          validator: (val) =>
                              val == null || val.isEmpty ? l10n.required : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.departureDate,
                          semanticsLabel: "Select the first day of the trip",
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const Spacer(),
                        Text(
                          "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                          semanticsLabel:
                              "Selected date is ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Semantics(
                  label: "Trip description input field ",
                  child: _buildTextField(
                    controller: _descriptionController,
                    label: l10n.tripDescription,
                    icon: Icons.notes_rounded,
                    colorScheme: colorScheme,
                    maxLines: 4,
                  ),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _isSaving ? null : _handleSave,
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isEditing ? l10n.updateJourney : l10n.createJourney,
                            semanticsLabel: isEditing
                                ? "Update Journey button"
                                : "Save Journey button",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isPrice = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      autovalidateMode:
          AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        prefixText: isPrice ? "\$ " : null,
        filled: true,
        fillColor: colorScheme.surface,
        errorStyle: const TextStyle(fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
