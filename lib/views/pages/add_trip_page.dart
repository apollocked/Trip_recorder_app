import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/widgets/permission_dialog.dart';

class AddTripPage extends StatefulWidget {
  final Trip? trip;
  const AddTripPage({super.key, this.trip});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _nightsController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  File? _imageFile;
  String? _existingImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _titleController.text = widget.trip!.title;
      _priceController.text = widget.trip!.price;
      _nightsController.text = widget.trip!.nights;
      _descriptionController.text = widget.trip!.description;
      _selectedDate = widget.trip!.date;
      _existingImagePath = widget.trip!.img;
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip == null ? "Add New Journey" : "Edit Journey"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                checkExistingPermissions(context, (pickedFile) {
                  setState(() {
                    _imageFile = pickedFile;
                  });
                });
              },
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: (_imageFile == null && _existingImagePath == null)
                      ? Border.all(color: colorScheme.outlineVariant)
                      : null,
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : (_existingImagePath != null
                            ? DecorationImage(
                                image: File(_existingImagePath!).isAbsolute
                                    ? FileImage(File(_existingImagePath!))
                                          as ImageProvider
                                    : AssetImage(
                                        _existingImagePath!.startsWith(
                                              'images/',
                                            )
                                            ? _existingImagePath!
                                            : 'images/$_existingImagePath',
                                      ),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: (_imageFile == null && _existingImagePath == null)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_enhance_rounded,
                            size: 48,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text("Snap a photo or Pick from Gallery"),
                        ],
                      )
                    : Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircleAvatar(
                            backgroundColor: colorScheme.primary,
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInputSection(colorScheme),
            const SizedBox(height: 32),
            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton.icon(
                onPressed: () {
                  if (_titleController.text.isEmpty ||
                      (_imageFile == null && _existingImagePath == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Missing title or photo!")),
                    );
                    return;
                  }
                  final newTrip = Trip(
                    title: _titleController.text,
                    price: _priceController.text,
                    nights: _nightsController.text,
                    img: _imageFile?.path ?? _existingImagePath!,
                    date: _selectedDate,
                    description: _descriptionController.text,
                    isLiked: widget.trip?.isLiked ?? false,
                  );
                  HapticFeedback.selectionClick();
                  Navigator.pop(context, newTrip);
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text("Save Trip"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Where to?",
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: "Price",
                      prefixText: "\$ ",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _nightsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: "Nights",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Date"),
              trailing: Text(
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            const Divider(),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "Tell us about this trip...",
                border: InputBorder.none,
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
