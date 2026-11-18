import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../services/report_api.dart';

class WasteReportViewModel extends ChangeNotifier {
  WasteReportViewModel(this._api);

  static const int maxPhotoBytes = 1500000;

  final WasteReportApi _api;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoName;
  String? _photoMimeType;
  String? _errorMessage;
  String? _successMessage;
  bool _isLoading = false;
  bool _disposed = false;

  Uint8List? get photoBytes => _photoBytes;
  String? get photoName => _photoName;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _isLoading;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> takePhoto() => _pick(ImageSource.camera);

  Future<void> chooseFromGallery() => _pick(ImageSource.gallery);

  Future<void> restoreLostPhoto() async {
    try {
      final response = await _picker.retrieveLostData();
      if (!response.isEmpty && response.files != null && response.files!.isNotEmpty) {
        await _readPhoto(response.files!.first);
      }
    } catch (_) {
      _errorMessage = 'The previous photo selection could not be restored.';
      _notify();
    }
  }

  Future<void> _pick(ImageSource source) async {
    _errorMessage = null;
    _successMessage = null;
    _notify();
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 70,
      );
      if (file != null) await _readPhoto(file);
    } catch (_) {
      _errorMessage = 'Could not open the camera or photo gallery.';
      _notify();
    }
  }

  Future<void> _readPhoto(XFile file) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      _errorMessage = 'The selected photo is empty. Please choose another.';
      _notify();
      return;
    }
    if (bytes.length > maxPhotoBytes) {
      _errorMessage = 'Choose a photo smaller than 1.5 MB.';
      _notify();
      return;
    }

    final extension = file.name.toLowerCase().split('.').last;
    final mimeType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => null,
    };
    if (mimeType == null) {
      _errorMessage = 'Choose a JPEG, PNG, or WebP photo.';
      _notify();
      return;
    }

    _photoBytes = bytes;
    _photoName = file.name;
    _photoMimeType = mimeType;
    _errorMessage = null;
    _successMessage = null;
    _notify();
  }

  void clearPhoto({bool clearStatus = true}) {
    _photoBytes = null;
    _photoName = null;
    _photoMimeType = null;
    if (clearStatus) {
      _errorMessage = null;
      _successMessage = null;
    }
    _notify();
  }

  Future<bool> submit({
    required String category,
    required String description,
  }) async {
    if (_isLoading) return false;
    if (_photoBytes == null || _photoMimeType == null) {
      _errorMessage = 'Add a photo before submitting the report.';
      _notify();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _notify();
    try {
      await _api.submit(
        category: category,
        description: description,
        imageBase64: base64Encode(_photoBytes!),
        imageMimeType: _photoMimeType!,
      );
      _successMessage = 'Report submitted. It is waiting for administrator review.';
      return true;
    } on ReportApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while submitting. Please try again.';
    } finally {
      _isLoading = false;
      _notify();
    }
    return false;
  }
}
