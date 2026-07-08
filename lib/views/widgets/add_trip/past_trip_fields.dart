import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/currency.dart';
import 'package:animations_in_flutter/model/trip_category.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/app_text_field.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/category_selector.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/currency_dropdown.dart';
import 'package:animations_in_flutter/views/widgets/add_trip/trip_image_picker.dart';
import 'package:animations_in_flutter/views/widgets/common/star_rating.dart';

class PastTripFields extends StatelessWidget {
  final List<File> imageFiles;
  final List<String> existingImagePaths;
  final bool imageError;
  final double rating;
  final TripCategory selectedCategory;
  final String selectedCurrency;
  final TextEditingController priceController;
  final TextEditingController nightsController;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final ValueChanged<List<File>> onImagesAdded;
  final ValueChanged<int> onImageRemovedAt;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<TripCategory> onCategoryChanged;
  final ValueChanged<String> onCurrencyChanged;

  const PastTripFields({
    super.key,
    required this.imageFiles,
    required this.existingImagePaths,
    required this.imageError,
    required this.rating,
    required this.selectedCategory,
    required this.selectedCurrency,
    required this.priceController,
    required this.nightsController,
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
    required this.onImagesAdded,
    required this.onImageRemovedAt,
    required this.onRatingChanged,
    required this.onCategoryChanged,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _coverPhotoSection(),
        const SizedBox(height: 24),
        _labeled(
          l10n.rateTrip,
          Center(
            child: StarRating(
              rating: rating,
              size: 36,
              interactive: true,
              onChanged: onRatingChanged,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _labeled(
          l10n.tripCategory,
          CategorySelector(
            selectedCategory: selectedCategory,
            onChanged: onCategoryChanged,
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(height: 24),
        _labeled(
          l10n.currencyLabel,
          CurrencyDropdown(
            selectedCurrency: selectedCurrency,
            onChanged: onCurrencyChanged,
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.tripDetails,
          style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: priceController,
                label: l10n.budget,
                icon: Icons.attach_money_rounded,
                colorScheme: colorScheme,
                keyboardType: TextInputType.number,
                prefixText: '${CurrencyInfo.symbolFor(selectedCurrency)} ',
                validator: (val) =>
                    val == null || val.isEmpty ? l10n.required : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: nightsController,
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
      ],
    );
  }

  Widget _coverPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.coverphoto,
          style: textTheme.labelLarge?.copyWith(
            color: imageError ? colorScheme.error : colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        TripImagePicker(
          imageFiles: imageFiles,
          existingImagePaths: existingImagePaths,
          imageError: imageError,
          onImagesAdded: onImagesAdded,
          onImageRemovedAt: onImageRemovedAt,
          colorScheme: colorScheme,
          textTheme: textTheme,
          l10n: l10n,
        ),
        if (imageError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              l10n.photoErrorReq,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
            ),
          ),
      ],
    );
  }

  Widget _labeled(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: textTheme.labelLarge
                  ?.copyWith(color: colorScheme.primary)),
          const SizedBox(height: 8),
          child,
        ],
      );
}
