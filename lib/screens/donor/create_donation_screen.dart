import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../models/donation_model.dart';
import '../../utils/app_theme.dart';

class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  
  DateTime? _expiryDate;
  TimeOfDay? _expiryTime;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() => _expiryDate = date);
    }
  }

  Future<void> _selectExpiryTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => _expiryTime = time);
    }
  }

  Future<void> _createDonation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null || _expiryTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select expiry date and time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final locationService = context.read<LocationService>();

      // Get current location
      await locationService.getCurrentLocation();
      if (locationService.currentGeoPoint == null) {
        throw Exception('Unable to get current location');
      }

      // Upload image if selected
      String? imageUrl;
      if (_selectedImage != null) {
        final imagePath = 'donations/${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await firestoreService.uploadImage(_selectedImage!, imagePath);
      }

      // Create expiry datetime
      final expiryDateTime = DateTime(
        _expiryDate!.year,
        _expiryDate!.month,
        _expiryDate!.day,
        _expiryTime!.hour,
        _expiryTime!.minute,
      );

      // Create donation
      final donation = DonationModel(
        id: '',
        donorId: authService.currentUser!.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        quantity: int.parse(_quantityController.text),
        expiryTime: expiryDateTime,
        imageUrl: imageUrl,
        location: locationService.currentGeoPoint!,
        address: locationService.currentAddress ?? 'Unknown location',
        status: DonationStatus.available,
        createdAt: DateTime.now(),
      );

      await firestoreService.createDonation(donation);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation created successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating donation: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Donation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Selection
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Photo (Optional)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Food Title',
                  hintText: 'e.g., Fresh Vegetables, Cooked Rice',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the food, cooking method, ingredients, etc.',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantity
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity (servings)',
                  hintText: 'Number of people this can feed',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Expiry Date and Time
              const Text(
                'Expiry Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectExpiryDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _expiryDate != null
                            ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                            : 'Select Date',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectExpiryTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _expiryTime != null
                            ? _expiryTime!.format(context)
                            : 'Select Time',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Create Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createDonation,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Create Donation',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}