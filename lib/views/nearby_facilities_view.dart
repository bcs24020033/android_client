import 'package:flutter/material.dart';

import '../models/facility.dart';
import '../services/facility_api.dart';
import '../viewmodels/nearby_facilities_view_model.dart';

class NearbyFacilitiesView extends StatefulWidget {
  const NearbyFacilitiesView({super.key});

  @override
  State<NearbyFacilitiesView> createState() => _NearbyFacilitiesViewState();
}

class _NearbyFacilitiesViewState extends State<NearbyFacilitiesView> {
  late final NearbyFacilitiesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NearbyFacilitiesViewModel(FacilityApi());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby facilities',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF173B2B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find recycling and disposal points within 25 km. Your location is used for this search only.',
                  style: TextStyle(color: Color(0xFF627168), height: 1.4),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _viewModel.isLoading
                      ? null
                      : _viewModel.searchNearby,
                  icon: const Icon(Icons.my_location),
                  label: Text(
                    _viewModel.isLoading
                        ? 'Finding your location…'
                        : 'Use my location',
                  ),
                ),
                if (_viewModel.isShowingCachedData) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Showing your last saved facility search. Tap “Use my location” to refresh.',
                    style: TextStyle(color: Color(0xFF527160), height: 1.4),
                  ),
                ],
                if (_viewModel.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _viewModel.errorMessage!,
                    style: const TextStyle(color: Color(0xFF9A3C32)),
                  ),
                  if (_viewModel.canOpenAppSettings)
                    TextButton(
                      onPressed: _viewModel.openAppSettings,
                      child: const Text('Open app settings'),
                    ),
                  if (_viewModel.canOpenLocationSettings)
                    TextButton(
                      onPressed: _viewModel.openLocationSettings,
                      child: const Text('Open location settings'),
                    ),
                ],
                const SizedBox(height: 18),
                Expanded(child: _buildResults(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResults(BuildContext context) {
    if (_viewModel.isLoading && _viewModel.facilities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.errorMessage != null && !_viewModel.hasSearched) {
      return const SizedBox.shrink();
    }
    if (!_viewModel.hasSearched) {
      return const Center(
        child: Text(
          'Tap “Use my location” when you are ready to search.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF627168)),
        ),
      );
    }
    if (_viewModel.facilities.isEmpty) {
      return const Center(
        child: Text(
          'No facilities found within 25 km.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF627168)),
        ),
      );
    }

    return ListView.separated(
      itemCount: _viewModel.facilities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _FacilityCard(facility: _viewModel.facilities[index]),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({required this.facility});

  final Facility facility;

  @override
  Widget build(BuildContext context) {
    final label = switch (facility.type) {
      'recycling' => 'Recycling centre',
      'disposal' => 'Waste disposal',
      'e_waste' => 'E-waste collection',
      'drop_off' => 'Community drop-off',
      _ => 'Facility',
    };
    final icon = switch (facility.type) {
      'e_waste' => Icons.devices_outlined,
      'disposal' => Icons.delete_outline,
      _ => Icons.recycling,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFEAF3EC),
              child: Icon(icon, color: const Color(0xFF216A4B)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility.name,
                    style: const TextStyle(
                      color: Color(0xFF173B2B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(color: Color(0xFF527160))),
                  const SizedBox(height: 6),
                  Text(
                    facility.address,
                    style: const TextStyle(color: Color(0xFF627168)),
                  ),
                  if (facility.openingHours.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      facility.openingHours,
                      style: const TextStyle(color: Color(0xFF627168)),
                    ),
                  ],
                ],
              ),
            ),
            if (facility.distanceKm != null) ...[
              const SizedBox(width: 8),
              Text(
                '${facility.distanceKm!.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: Color(0xFF216A4B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
