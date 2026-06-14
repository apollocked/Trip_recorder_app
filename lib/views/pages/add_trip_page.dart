import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/model/trip_category.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/permission_dialog.dart';
import 'package:animations_in_flutter/views/widgets/star_rating.dart';

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

    setState(() {
      _imageError = !hasImages;
    });

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

      if (widget.tripId != null) {
        await context.read<TripProvider>().updateTrip(
          widget.tripId!,
          title: _titleController.text.trim(),
          price: double.tryParse(_priceController.text.trim()) ?? 0,
          nights: int.tryParse(_nightsController.text.trim()) ?? 1,
          imageFiles: _imageFiles.isNotEmpty ? _imageFiles : null,
          existingImagePaths: _imageFiles.isEmpty ? _existingImagePaths : null,
          assetImagePaths: assetPaths.isNotEmpty ? assetPaths : null,
          date: _selectedDate,
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          rating: _rating,
          currency: _selectedCurrency,
        );
      } else {
        await context.read<TripProvider>().addTrip(
          title: _titleController.text.trim(),
          price: double.tryParse(_priceController.text.trim()) ?? 0,
          nights: int.tryParse(_nightsController.text.trim()) ?? 1,
          imageFiles: _imageFiles,
          assetImagePaths: _existingImagePaths
              .where((p) => p.startsWith('images/'))
              .toList(),
          date: _selectedDate,
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          rating: _rating,
          currency: _selectedCurrency,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving trip: $e')));
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
                  style: textTheme.labelLarge?.copyWith(
                    color: _imageError
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildImageSection(colorScheme, textTheme, l10n),
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
                Text(
                  l10n.rateTrip,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: StarRating(
                    rating: _rating,
                    size: 36,
                    interactive: true,
                    onChanged: (val) => setState(() => _rating = val),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  l10n.tripCategory,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TripCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.label),
                      selected: isSelected,
                      selectedColor: colorScheme.primaryContainer,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                Text(
                  l10n.currencyLabel,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCurrency,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  items: CurrencyInfo.all.map((c) {
                    return DropdownMenuItem(
                      value: c.code,
                      child: Text('${c.symbol}  ${c.code} — ${c.name}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCurrency = val);
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.tripDetails,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                _buildTextField(
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
                    const SizedBox(width: 16),
                    Expanded(
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
                  ],
                ),
                const SizedBox(height: 16),

                _buildDatePicker(colorScheme, l10n),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _descriptionController,
                  label: l10n.tripDescription,
                  icon: Icons.notes_rounded,
                  colorScheme: colorScheme,
                  maxLines: 4,
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

  Widget _buildImageSection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    var l10n,
  ) {
    final allPaths = [
      ..._imageFiles.map((f) => f.path),
      ..._existingImagePaths,
    ];

    return Column(
      children: [
        if (allPaths.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allPaths.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == allPaths.length) {
                  return _buildAddImageButton(colorScheme);
                }
                final path = allPaths[index];
                final isAsset = path.startsWith('images/');
                return Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant),
                        image: DecorationImage(
                          image: isAsset
                              ? AssetImage(path) as ImageProvider
                              : FileImage(File(path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (index < _imageFiles.length) {
                              _imageFiles.removeAt(index);
                            } else {
                              _existingImagePaths.removeAt(
                                index - _imageFiles.length,
                              );
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        else
          GestureDetector(
            onTap: () => pickMultipleImages(context, (files) {
              setState(() {
                _imageFiles.addAll(files);
                _imageError = false;
              });
            }),
            child: Container(
              height: 200,
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
              ),
              child: Column(
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
                    style: TextStyle(
                      color: _imageError
                          ? colorScheme.error
                          : colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.tapToAddPhotos,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (allPaths.isNotEmpty) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => pickMultipleImages(context, (files) {
              setState(() {
                _imageFiles.addAll(files);
              });
            }),
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
            label: Text(l10n.addMorePhotos),
          ),
        ],
      ],
    );
  }

  Widget _buildAddImageButton(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => pickMultipleImages(context, (files) {
        setState(() {
          _imageFiles.addAll(files);
        });
      }),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withAlpha(80),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
        ),
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDatePicker(ColorScheme colorScheme, var l10n) {
    return InkWell(
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const Spacer(),
            Text(
              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
