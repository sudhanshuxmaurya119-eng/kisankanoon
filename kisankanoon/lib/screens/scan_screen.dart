import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/document_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const String _typePlaceholder = 'Select document type';
  static const List<String> _documentTypes = <String>[
    _typePlaceholder,
    'Land Record',
    'Aadhaar Card',
    'Bank Passbook',
    'Registry Paper',
    'Government Notice',
    'Court Document',
    'Other',
  ];

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _docNameCtrl = TextEditingController();
  final TextEditingController _docNumberCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  XFile? _pickedImage;
  bool _saving = false;
  String _selectedDocType = _typePlaceholder;

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 960,
    );
    if (image == null) {
      return;
    }

    setState(() {
      _pickedImage = image;
      _docNameCtrl.clear();
      _docNumberCtrl.clear();
      _notesCtrl.clear();
      _selectedDocType = _typePlaceholder;
    });

    await StorageService.incrementScanCount();
  }

  Future<void> _saveDocument() async {
    if (_pickedImage == null || _saving) {
      return;
    }

    final docName = _docNameCtrl.text.trim();
    if (docName.isEmpty) {
      _showMessage(
        'Please enter a document name before saving.',
        Colors.orange,
      );
      return;
    }

    if (_selectedDocType == _typePlaceholder) {
      _showMessage(
        'Please choose the document type yourself before saving.',
        Colors.orange,
      );
      return;
    }

    setState(() => _saving = true);
    final savedDocument = await DocumentService.uploadDocument(
      imageFile: File(_pickedImage!.path),
      docName: docName,
      docType: _selectedDocType,
      documentNumber: _docNumberCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      summary: '',
    );

    if (!mounted) {
      return;
    }

    setState(() => _saving = false);

    if (savedDocument == null) {
      _showMessage(
        'Document could not be saved. Please try again.',
        Colors.red,
      );
      return;
    }

    final syncedToFirebase = savedDocument['syncedToFirebase'] == true;
    final syncError = (savedDocument['syncError'] ?? '').toString().trim();
    final ownerId = (savedDocument['ownerId'] ?? '').toString().trim();

    _showMessage(
      syncedToFirebase
          ? 'Document saved in your folder and synced to Firebase account ${_shortId(ownerId)}.'
          : syncError.isEmpty
              ? 'Document saved on this device, but Firebase sync is still pending.'
              : 'Document saved on this device, but Firebase sync failed: $syncError',
      syncedToFirebase ? AppTheme.primaryGreen : Colors.orange,
      duration: const Duration(seconds: 5),
    );

    _resetScan();
  }

  void _showMessage(
    String message,
    Color backgroundColor, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration,
        ),
      );
  }

  void _resetScan() {
    setState(() {
      _pickedImage = null;
      _saving = false;
      _selectedDocType = _typePlaceholder;
    });
    _docNameCtrl.clear();
    _docNumberCtrl.clear();
    _notesCtrl.clear();
  }

  String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  @override
  void dispose() {
    _docNameCtrl.dispose();
    _docNumberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Scan Document'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_pickedImage == null) ...[
                _introCard(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(
                            Icons.upload_file,
                            color: AppTheme.primaryGreen,
                          ),
                          label: const Text(
                            'Upload',
                            style: TextStyle(color: AppTheme.primaryGreen),
                          ),
                          style: OutlinedButton.styleFrom(
                            side:
                                const BorderSide(color: AppTheme.primaryGreen),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(_pickedImage!.path),
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                _captureNoticeCard(),
                const SizedBox(height: 16),
                _detailsCard(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _saveDocument,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _saving ? 'Saving...' : 'Save document',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _saving ? null : _resetScan,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          child: const Text(
                            'New scan',
                            style: TextStyle(color: AppTheme.primaryGreen),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              _supportedDocumentsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGreen,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📄', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text(
            'Scan or upload your document',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'After scan, review the image and add the document details yourself before saving it to your folder.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMid),
            ),
          ),
        ],
      ),
    );
  }

  Widget _captureNoticeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Add details yourself',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'This scan is ready to save. The app will not guess document details, so please enter the name, type, ID, and notes yourself.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Only the details you enter here will be stored with this document in your account.',
            style: TextStyle(fontSize: 13, color: AppTheme.textMid),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _docNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Document name',
              hintText: 'Example: Land registry 2026',
              prefixIcon: Icon(Icons.description_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey<String>(_selectedDocType),
            initialValue: _selectedDocType,
            decoration: const InputDecoration(
              labelText: 'Document type',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: _documentTypes
                .map(
                  (type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedDocType = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _docNumberCtrl,
            decoration: const InputDecoration(
              labelText: 'Document ID / number',
              hintText: 'Example: 452/3 or ABCD1234',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Add any extra detail about this document',
              prefixIcon: Icon(Icons.note_alt_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'When you save, the image stays in your device folder and also tries to sync to Firestore under your signed-in account.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportedDocumentsCard() {
    const supportedItems = <String>[
      'Khasra / Khatauni',
      'Aadhaar card',
      'Bank passbook',
      'Land registry paper',
      'Government notice',
      'Court paper',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Supported documents',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ),
          ...supportedItems.map(
            (item) => ListTile(
              dense: true,
              title: Text(
                item,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
              trailing: const Icon(
                Icons.check,
                color: AppTheme.accentGreen,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
