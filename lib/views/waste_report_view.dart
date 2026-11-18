import 'package:flutter/material.dart';

import '../services/report_api.dart';
import '../viewmodels/waste_report_view_model.dart';

class WasteReportView extends StatefulWidget {
  const WasteReportView({required this.accessToken, super.key});

  final String accessToken;

  @override
  State<WasteReportView> createState() => _WasteReportViewState();
}

class _WasteReportViewState extends State<WasteReportView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  late final WasteReportViewModel _viewModel;
  String? _category;

  static const _categories = <String, String>{
    'illegal_dumping': 'Illegal dumping',
    'overflowing_bin': 'Overflowing bin',
    'missed_collection': 'Missed collection',
    'hazardous_waste': 'Hazardous waste',
    'other': 'Other',
  };

  @override
  void initState() {
    super.initState();
    _viewModel = WasteReportViewModel(
      WasteReportApi(accessToken: widget.accessToken),
    );
    _viewModel.restoreLostPhoto();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final submitted = await _viewModel.submit(
      category: _category!,
      description: _descriptionController.text,
    );
    if (!mounted || !submitted) return;
    setState(() {
      _category = null;
      _descriptionController.clear();
    });
    _viewModel.clearPhoto(clearStatus: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) => SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Text(
                'Report a waste issue',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF173B2B),
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add a photo and a few details so the local team can review it.',
                style: TextStyle(color: Color(0xFF627168), height: 1.4),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Issue type *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: _viewModel.isLoading
                    ? null
                    : (value) => setState(() => _category = value),
                validator: (value) => value == null ? 'Choose an issue type.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Where is it, and what did you notice?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final length = (value ?? '').trim().length;
                  if (length < 10) return 'Enter at least 10 characters.';
                  if (length > 500) return 'Use no more than 500 characters.';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              if (_viewModel.photoBytes case final photo?) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.memory(
                    photo,
                    height: 210,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF216A4B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _viewModel.photoName ?? 'Photo attached',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove photo',
                      onPressed: _viewModel.isLoading
                          ? null
                          : () => _viewModel.clearPhoto(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _viewModel.isLoading
                            ? null
                            : _viewModel.takePhoto,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Camera'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _viewModel.isLoading
                            ? null
                            : _viewModel.chooseFromGallery,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'A photo is required. Use JPEG, PNG, or WebP under 1.5 MB.',
                    style: TextStyle(color: Color(0xFF627168), fontSize: 12),
                  ),
                ),
              ],
              if (_viewModel.errorMessage case final error?) ...[
                const SizedBox(height: 10),
                Text(error, style: const TextStyle(color: Color(0xFFAD302D))),
              ],
              if (_viewModel.successMessage case final success?) ...[
                const SizedBox(height: 10),
                Text(success, style: const TextStyle(color: Color(0xFF216A4B))),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _viewModel.isLoading ? null : _submit,
                icon: _viewModel.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  _viewModel.isLoading ? 'Submitting…' : 'Submit report',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your report and photo are sent to the administrator for review.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF627168), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
