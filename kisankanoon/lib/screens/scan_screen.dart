import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/app_language_service.dart';
import '../services/app_strings.dart';
import '../services/document_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const List<String> _documentTypeKeys = <String>[
    'landRecord',
    'aadhaarCard',
    'bankPassbook',
    'registryPaper',
    'governmentNotice',
    'courtDocument',
    'other',
  ];

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _docNameCtrl = TextEditingController();
  final TextEditingController _docNumberCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  File? _selectedFile;
  String _selectedFileName = '';
  String _selectedFileKind = 'image';
  bool _saving = false;
  String? _selectedDocTypeKey;
  String _languageCode = AppLanguageService.currentCode.value;

  String get _translationCode => _languageCode == 'en' ? 'en' : 'hi';

  @override
  void initState() {
    super.initState();
    AppLanguageService.currentCode.addListener(_handleLanguageChanged);
  }

  @override
  void dispose() {
    AppLanguageService.currentCode.removeListener(_handleLanguageChanged);
    _docNameCtrl.dispose();
    _docNumberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _handleLanguageChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _languageCode = AppLanguageService.currentCode.value;
    });
  }

  String _t(String key) => AppStrings.t(_translationCode, key);

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 1280,
    );
    if (image == null) {
      return;
    }

    _setSelectedFile(
      file: File(image.path),
      fileName: image.name.isEmpty ? _fileNameFromPath(image.path) : image.name,
    );
    await StorageService.incrementScanCount();
  }

  Future<void> _pickDocumentFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['pdf', 'doc', 'docx', 'txt', 'rtf'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final pickedFile = result.files.single;
    final path = pickedFile.path;
    if (path == null || path.isEmpty) {
      _showMessage(_t('pickDocumentFailed'), Colors.red);
      return;
    }

    _setSelectedFile(
      file: File(path),
      fileName:
          pickedFile.name.isEmpty ? _fileNameFromPath(path) : pickedFile.name,
    );
    await StorageService.incrementScanCount();
  }

  void _setSelectedFile({
    required File file,
    required String fileName,
  }) {
    setState(() {
      _selectedFile = file;
      _selectedFileName = fileName;
      _selectedFileKind = _fileKindFromName(fileName);
      _selectedDocTypeKey = null;
      _saving = false;
    });
    _docNameCtrl.clear();
    _docNumberCtrl.clear();
    _notesCtrl.clear();
  }

  Future<void> _saveDocument() async {
    if (_selectedFile == null || _saving) {
      return;
    }

    final docName = _docNameCtrl.text.trim();
    if (docName.isEmpty) {
      _showMessage(_t('pleaseEnterDocumentName'), Colors.orange);
      return;
    }

    if (_selectedDocTypeKey == null) {
      _showMessage(_t('pleaseChooseDocumentType'), Colors.orange);
      return;
    }

    setState(() => _saving = true);
    final savedDocument = await DocumentService.uploadDocument(
      sourceFile: _selectedFile!,
      docName: docName,
      docType: _t(_selectedDocTypeKey!),
      documentNumber: _docNumberCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      summary: '',
    );

    if (!mounted) {
      return;
    }

    setState(() => _saving = false);

    if (savedDocument == null) {
      _showMessage(_t('documentSaveFailed'), Colors.red);
      return;
    }

    final syncedToFirebase = savedDocument['syncedToFirebase'] == true;
    final cloudFileAvailable = savedDocument['cloudFileAvailable'] == true;
    final syncError = (savedDocument['syncError'] ?? '').toString().trim();

    late final String message;
    late final Color color;

    if (syncedToFirebase && cloudFileAvailable) {
      message = _t('documentSavedSynced');
      color = AppTheme.primaryGreen;
    } else if (syncedToFirebase) {
      message = _t('documentSavedMetadataOnly');
      color = AppTheme.primaryGreen;
    } else if (syncError.isEmpty) {
      message = _t('documentSavedPending');
      color = Colors.orange;
    } else {
      message = '${_t('documentSavedSyncFailedPrefix')}$syncError';
      color = Colors.orange;
    }

    _showMessage(message, color, duration: const Duration(seconds: 5));
    _resetSelection();
  }

  void _showMessage(
    String message,
    Color backgroundColor, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!mounted) {
      return;
    }

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

  void _resetSelection() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = '';
      _selectedFileKind = 'image';
      _selectedDocTypeKey = null;
      _saving = false;
    });
    _docNameCtrl.clear();
    _docNumberCtrl.clear();
    _notesCtrl.clear();
  }

  String _fileKindFromName(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp') ||
        lowerName.endsWith('.bmp') ||
        lowerName.endsWith('.gif') ||
        lowerName.endsWith('.heic') ||
        lowerName.endsWith('.heif')) {
      return 'image';
    }
    if (lowerName.endsWith('.pdf')) {
      return 'pdf';
    }
    return 'document';
  }

  String _fileNameFromPath(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    final slashIndex = normalizedPath.lastIndexOf('/');
    if (slashIndex == -1 || slashIndex == normalizedPath.length - 1) {
      return normalizedPath;
    }
    return normalizedPath.substring(slashIndex + 1);
  }

  String _fileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1).toUpperCase();
  }

  IconData _fileIcon() {
    switch (_selectedFileKind) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'document':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(_t('scanDocumentTitle')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_selectedFile == null) ...[
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
                          label: Text(_t('camera')),
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
                            Icons.photo_library_outlined,
                            color: AppTheme.primaryGreen,
                          ),
                          label: Text(
                            _t('uploadImage'),
                            style:
                                const TextStyle(color: AppTheme.primaryGreen),
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _pickDocumentFile,
                    icon: const Icon(
                      Icons.upload_file_outlined,
                      color: AppTheme.primaryGreen,
                    ),
                    label: Text(
                      _t('uploadPdfDocument'),
                      style: const TextStyle(color: AppTheme.primaryGreen),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
              ] else ...[
                _selectedFileKind == 'image'
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedFile!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      )
                    : _filePreviewCard(),
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
                            _saving ? _t('saving') : _t('saveDocument'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _saving ? null : _resetSelection,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          child: Text(
                            _t('newScan'),
                            style:
                                const TextStyle(color: AppTheme.primaryGreen),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📄', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            _t('scanOrUploadDocument'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _t('reviewAndAddDetails'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMid),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filePreviewCard() {
    final extension = _fileExtension(_selectedFileName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.bgGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _fileIcon(),
                  size: 30,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('selectedFile'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedFileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (extension.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    extension,
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
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
          Text(
            _t('documentDetails'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _t('onlyEnteredDetailsSaved'),
            style: const TextStyle(fontSize: 13, color: AppTheme.textMid),
          ),
          if (_selectedFileName.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bgGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_fileIcon(), size: 18, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _docNameCtrl,
            decoration: InputDecoration(
              labelText: _t('documentName'),
              hintText: _t('documentNameHint'),
              prefixIcon: const Icon(Icons.description_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey<String?>(_selectedDocTypeKey),
            initialValue: _selectedDocTypeKey,
            decoration: InputDecoration(
              labelText: _t('documentType'),
              prefixIcon: const Icon(Icons.category_outlined),
            ),
            hint: Text(_t('selectDocumentType')),
            items: _documentTypeKeys
                .map(
                  (typeKey) => DropdownMenuItem<String>(
                    value: typeKey,
                    child: Text(_t(typeKey)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() => _selectedDocTypeKey = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _docNumberCtrl,
            decoration: InputDecoration(
              labelText: _t('documentIdNumber'),
              hintText: _t('documentIdHint'),
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: _t('notesLabel'),
              hintText: _t('notesHint'),
              prefixIcon: const Icon(Icons.note_alt_outlined),
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
            child: Text(
              _t('firebaseSyncNote'),
              style: const TextStyle(
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
    final supportedItems = <String>[
      _t('landRecord'),
      _t('aadhaarCard'),
      _t('bankPassbook'),
      _t('registryPaper'),
      _t('governmentNotice'),
      _t('courtDocument'),
      _t('pdfDocument'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              _t('supportedDocuments'),
              style: const TextStyle(
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
