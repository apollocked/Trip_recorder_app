import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:permission_handler/permission_handler.dart';

class AddTripPage extends StatefulWidget {
  const AddTripPage({super.key});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _nightsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _imageFile;

  // --- SOFT ASK DIALOG ---
  // Explains the "Why" before triggering the system popup
  Future<void> _showSoftAskDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.camera_alt, size: 48, color: Colors.blue),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Share your journey!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "We need access to your camera and gallery so you can upload beautiful photos of your trips.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Not Now"),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handlePermission();
            },
            child: const Text("Allow Access"),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePermission() async {
    // 1. Request permissions and get the results
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
    ].request();

    print("Camera Status: ${statuses[Permission.camera]}");
    print("Photos Status: ${statuses[Permission.photos]}");

    // 2. If granted, go to picker
    if (statuses[Permission.camera]!.isGranted ||
        statuses[Permission.photos]!.isGranted) {
      _showImageSourceOptions();
    }
    // 3. If the user blocked it, we must send them to settings
    else if (statuses[Permission.camera]!.isPermanentlyDenied ||
        statuses[Permission.photos]!.isPermanentlyDenied) {
      print("User permanently denied. Opening settings...");
      await openAppSettings();
    }
  }

  // --- IMAGE PICKER LOGIC ---
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // --- SELECTION DIALOG (Gallery or Camera) ---
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Photo Source",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Add New Journey")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // IMAGE PICKER BOX
            GestureDetector(
              // Trigger the SOFT ASK first
              onTap: _showSoftAskDialog,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: _imageFile == null
                      ? Border.all(color: colorScheme.outlineVariant)
                      : null,
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
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
            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton.icon(
                onPressed: () {
                  if (_titleController.text.isEmpty || _imageFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Missing info!")),
                    );
                    return;
                  }
                  final newTrip = Trip(
                    title: _titleController.text,
                    price: _priceController.text,
                    nights: _nightsController.text,
                    img: _imageFile!.path,
                    date: _selectedDate,
                  );
                  Navigator.pop(context, newTrip);
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text("Save Trip"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TEXT FIELDS UI ---
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
                    decoration: const InputDecoration(
                      labelText: "Price",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _nightsController,
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
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
          ],
        ),
      ),
    );
  }
}
