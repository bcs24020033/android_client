import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/facility.dart';
import '../services/facility_cache.dart';
import '../services/facility_api.dart';

class NearbyFacilitiesViewModel extends ChangeNotifier {
  NearbyFacilitiesViewModel(this._api, {FacilityCache? cache})
    : _cache = cache ?? FacilityCache() {
    _cacheRestoration = _restoreCachedFacilities();
  }

  final FacilityApi _api;
  final FacilityCache _cache;
  late final Future<void> _cacheRestoration;
  List<Facility> _facilities = const [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isShowingCachedData = false;
  bool _isDisposed = false;
  bool _canOpenAppSettings = false;
  bool _canOpenLocationSettings = false;
  String? _errorMessage;

  List<Facility> get facilities => _facilities;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  bool get isShowingCachedData => _isShowingCachedData;
  bool get canOpenAppSettings => _canOpenAppSettings;
  bool get canOpenLocationSettings => _canOpenLocationSettings;
  String? get errorMessage => _errorMessage;

  Future<void> _restoreCachedFacilities() async {
    try {
      final cachedFacilities = await _cache.load();
      if (cachedFacilities != null) {
        _facilities = cachedFacilities;
        _hasSearched = true;
        _isShowingCachedData = true;
      }
    } catch (_) {
      // A cache read failure should not prevent a live API search.
    } finally {
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> searchNearby() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    _canOpenAppSettings = false;
    _canOpenLocationSettings = false;
    notifyListeners();

    try {
      await _cacheRestoration;

      if (!await Geolocator.isLocationServiceEnabled()) {
        _errorMessage = 'Turn on location services to find nearby facilities.';
        _canOpenLocationSettings = true;
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location access is blocked for this app. Allow it in app settings.';
        _canOpenAppSettings = true;
        return;
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        _errorMessage = 'Location access is needed to search nearby.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final facilities = await _api.findNearby(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _facilities = facilities;
      _hasSearched = true;
      _isShowingCachedData = false;
      try {
        await _cache.save(facilities);
      } catch (_) {
        // Keep live results available even if local storage is unavailable.
      }
    } on LocationServiceDisabledException {
      _errorMessage = 'Turn on location services to find nearby facilities.';
      _canOpenLocationSettings = true;
    } on TimeoutException {
      _errorMessage = 'Could not get a location fix. Please try again.';
    } on FacilityApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Nearby search could not be completed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
