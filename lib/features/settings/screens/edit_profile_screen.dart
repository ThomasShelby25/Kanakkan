import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/supabase_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _currentAvatarUrl;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = SupabaseService.currentUser;
    final currentName = user?.userMetadata?['display_name'] ?? user?.email?.split('@')[0] ?? '';
    final currentPhone = user?.userMetadata?['phone_number'] ?? '';
    _currentAvatarUrl = user?.userMetadata?['avatar_url'];
    
    _nameController = TextEditingController(text: currentName);
    _phoneController = TextEditingController(text: currentPhone);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    
    String? newUrl = _currentAvatarUrl;
    if (_imageFile != null) {
      newUrl = await SupabaseService.uploadAvatar(_imageFile!);
    }
    
    await SupabaseService.updateProfile(
      name: name,
      phone: _phoneController.text.trim(),
      avatarUrl: newUrl,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context, true); // true indicates a refresh is needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTypography.titleMedium()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      image: _imageFile != null
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : _currentAvatarUrl != null
                              ? DecorationImage(image: NetworkImage(_currentAvatarUrl!), fit: BoxFit.cover)
                              : null,
                    ),
                    alignment: Alignment.center,
                    child: (_imageFile == null && _currentAvatarUrl == null)
                        ? Icon(Icons.person, size: 60, color: AppColors.primary)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 3),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              style: AppTypography.bodyMedium(),
              decoration: InputDecoration(
                labelText: 'Display Name',
                labelStyle: TextStyle(color: AppColors.secondary),
                prefixIcon: Icon(Icons.person_outline, color: AppColors.secondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: AppTypography.bodyMedium(),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: AppColors.secondary),
                prefixIcon: Icon(Icons.phone_outlined, color: AppColors.secondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: false,
              controller: TextEditingController(text: user?.email ?? ''),
              style: AppTypography.bodyMedium().copyWith(color: AppColors.secondary),
              decoration: InputDecoration(
                labelText: 'Email (Cannot be changed)',
                labelStyle: TextStyle(color: AppColors.secondary),
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.secondary),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
