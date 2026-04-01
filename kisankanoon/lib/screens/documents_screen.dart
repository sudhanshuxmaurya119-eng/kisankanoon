import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'scan_screen.dart';
import '../services/app_language_service.dart';
import '../services/app_strings.dart';
import '../services/document_service.dart';
import '../theme/app_theme.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
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

  bool get _isEnglish => _translationCode == 'en';

  String get _addDocumentLabel =>
      _isEnglish ? 'Add document' : 'दस्तावेज़ जोड़ें';

  String get _openFileLabel => _isEnglish ? 'Open file' : 'फ़ाइल खोलें';

  String get _openFileFailedMessage =>
      _isEnglish ? 'This file could not be opened.' : 'यह फ़ाइल नहीं खुल सकी।';

  String get _fileUnavailableMessage => _isEnglish
      ? 'This file is not available on this device right now.'
      : 'यह फ़ाइल अभी इस डिवाइस पर उपलब्ध नहीं है।';

  Future<void> _openAddDocumentScreen() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ScanScreen()));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppTheme.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        _t('myDocuments'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _openAddDocumentScreen,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(_addDocumentLabel),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.bgGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _t('deviceAndFirestore'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: DocumentService.getDocumentsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    );
                  }

                  final documents = snapshot.data ?? [];
                  if (documents.isEmpty) {
                    return _emptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: documents.length,
                    itemBuilder: (context, index) =>
                        _documentCard(context, documents[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📂', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            _t('noDocumentsYet'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _t('documentsEmptyHint'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMid),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _openAddDocumentScreen,
            icon: const Icon(Icons.add),
            label: Text(_addDocumentLabel),
          ),
        ],
      ),
    );
  }

  Widget _documentCard(BuildContext context, Map<String, dynamic> document) {
    final documentNumber = (document['documentNumber'] ?? '').toString().trim();
    final syncedToFirebase = document['syncedToFirebase'] == true;
    final fileKind = (document['fileKind'] ?? 'document').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _showPreview(context, document),
        contentPadding: const EdgeInsets.all(12),
        leading: _thumbnail(document, size: 56),
        title: Text(
          (document['name'] ?? document['title'] ?? _t('documentWord'))
              .toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              (document['type'] ?? _t('generalDocument')).toString(),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryGreen,
              ),
            ),
            if (documentNumber.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${_t('documentIdNumber')}: $documentNumber',
                style: const TextStyle(fontSize: 11, color: AppTheme.textDark),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatCreatedAt(document['createdAt']?.toString()),
              style: const TextStyle(fontSize: 11, color: AppTheme.textMid),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: syncedToFirebase
                        ? AppTheme.bgGreen
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    syncedToFirebase
                        ? _t('firebaseSynced')
                        : _t('firebaseSyncPending'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: syncedToFirebase
                          ? AppTheme.primaryGreen
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.bgLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _fileTypeLabel(document, fileKind),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMid,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(_t('deleteDocumentQuestion')),
                content: Text(_t('deleteDocumentWarning')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(_t('cancel')),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      _t('delete'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm != true) {
              return;
            }

            final localPath =
                (document['localPath'] ?? document['imagePath'] ?? '')
                    .toString();
            final deleted = await DocumentService.deleteDocument(
              document['id'].toString(),
              localPath,
            );

            if (!context.mounted) {
              return;
            }

            if (!deleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_t('deleteFailed')),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _showPreview(
    BuildContext context,
    Map<String, dynamic> document,
  ) async {
    final notes = (document['notes'] ?? '').toString().trim();
    final documentNumber = (document['documentNumber'] ?? '').toString().trim();
    final ownerId = (document['ownerId'] ?? '').toString().trim();
    final syncError = (document['syncError'] ?? '').toString().trim();
    final syncedToFirebase = document['syncedToFirebase'] == true;
    final cloudFileAvailable = document['cloudFileAvailable'] == true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                (document['name'] ?? document['title'] ?? _t('documentWord'))
                    .toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(document['type'] ?? _t('generalDocument')).toString()} | ${_formatCreatedAt(document['createdAt']?.toString())}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMid),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 220,
                child: _previewBody(document),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openStoredDocument(document),
                  icon: const Icon(
                    Icons.open_in_new,
                    color: AppTheme.primaryGreen,
                  ),
                  label: Text(
                    _openFileLabel,
                    style: const TextStyle(color: AppTheme.primaryGreen),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _detailRow(
                _t('documentIdNumber'),
                documentNumber.isEmpty ? _t('notAdded') : documentNumber,
              ),
              _detailRow(
                _t('firebaseStatus'),
                syncedToFirebase
                    ? _t('syncedSuccessfully')
                    : _t('notSyncedYet'),
                valueColor:
                    syncedToFirebase ? AppTheme.primaryGreen : Colors.orange,
              ),
              _detailRow(
                _t('fileType'),
                _fileTypeLabel(
                  document,
                  (document['fileKind'] ?? 'document').toString(),
                ),
              ),
              if (ownerId.isNotEmpty)
                _detailRow(_t('accountId'), _shortId(ownerId)),
              if (syncedToFirebase && !cloudFileAvailable)
                _detailRow(
                  _t('syncMessage'),
                  _t('fileKeptOnDevice'),
                  valueColor: Colors.orange.shade800,
                ),
              if (syncError.isNotEmpty)
                _detailRow(
                  _t('syncMessage'),
                  syncError,
                  valueColor: Colors.orange.shade800,
                ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _t('notesLabel'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notes,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textDark,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStoredDocument(Map<String, dynamic> document) async {
    final file = await _resolveDocumentFile(document);
    if (!mounted) {
      return;
    }

    if (file == null || !await file.exists()) {
      _showMessage(_fileUnavailableMessage, Colors.orange);
      return;
    }

    final result = await OpenFilex.open(file.path);
    if (!mounted) {
      return;
    }

    if (result.type != ResultType.done) {
      final detail = result.message.trim();
      final message = detail.isEmpty
          ? _openFileFailedMessage
          : '$_openFileFailedMessage ($detail)';
      _showMessage(message, Colors.red);
    }
  }

  Future<File?> _resolveDocumentFile(Map<String, dynamic> document) async {
    final localPath = (document['localPath'] ?? document['imagePath'] ?? '')
        .toString()
        .trim();
    if (localPath.isNotEmpty) {
      final localFile = File(localPath);
      if (await localFile.exists()) {
        return localFile;
      }
    }

    final fileBytes = _decodeFileBytes(document);
    if (fileBytes == null) {
      return null;
    }

    final tempDirectory = await getTemporaryDirectory();
    final fileName = _resolvedFileName(document);
    final tempFile = File('${tempDirectory.path}/$fileName');
    await tempFile.writeAsBytes(fileBytes, flush: true);
    return tempFile;
  }

  String _resolvedFileName(Map<String, dynamic> document) {
    final rawFileName =
        (document['fileName'] ?? document['name'] ?? _t('documentWord'))
            .toString()
            .trim();
    final safeFileName = rawFileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    if (safeFileName.contains('.')) {
      return safeFileName;
    }

    final extension = (document['fileExtension'] ?? '').toString().trim();
    if (extension.isEmpty) {
      return safeFileName;
    }
    return '$safeFileName$extension';
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

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMid,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: valueColor ?? AppTheme.textDark,
                fontWeight:
                    valueColor == null ? FontWeight.w500 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbnail(
    Map<String, dynamic> document, {
    required double size,
  }) {
    final localPath =
        (document['localPath'] ?? document['imagePath'] ?? '').toString();
    final imageBytes = _decodeImageBytes(document);
    final localFile = localPath.isEmpty ? null : File(localPath);
    final hasLocalFile = localFile != null && localFile.existsSync();
    final fileKind = (document['fileKind'] ?? 'document').toString();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.bgGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: fileKind == 'image' && hasLocalFile
          ? Image.file(
              localFile,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fileIconTile(document, size: 24),
            )
          : fileKind == 'image' && imageBytes != null
              ? Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _fileIconTile(document, size: 24),
                )
              : _fileIconTile(document, size: 24),
    );
  }

  Widget _previewBody(Map<String, dynamic> document) {
    final localPath =
        (document['localPath'] ?? document['imagePath'] ?? '').toString();
    final imageBytes = _decodeImageBytes(document);
    final localFile = localPath.isEmpty ? null : File(localPath);
    final hasLocalFile = localFile != null && localFile.existsSync();
    final fileKind = (document['fileKind'] ?? 'document').toString();

    if (fileKind == 'image' && hasLocalFile) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          localFile,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _filePreviewCard(document),
        ),
      );
    }

    if (fileKind == 'image' && imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _filePreviewCard(document),
        ),
      );
    }

    return _filePreviewCard(document);
  }

  Widget _filePreviewCard(Map<String, dynamic> document) {
    final fileName =
        (document['fileName'] ?? document['name'] ?? _t('documentWord'))
            .toString();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _fileIconData((document['fileKind'] ?? 'document').toString()),
            size: 46,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 12),
          Text(
            fileName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _fileTypeLabel(
              document,
              (document['fileKind'] ?? 'document').toString(),
            ),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMid,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileIconTile(Map<String, dynamic> document, {required double size}) {
    return Center(
      child: Icon(
        _fileIconData((document['fileKind'] ?? 'document').toString()),
        size: size,
        color: AppTheme.primaryGreen,
      ),
    );
  }

  IconData _fileIconData(String fileKind) {
    switch (fileKind) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'document':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Uint8List? _decodeImageBytes(Map<String, dynamic> document) {
    if ((document['fileKind'] ?? 'document').toString() != 'image') {
      return null;
    }
    return _decodeFileBytes(document);
  }

  Uint8List? _decodeFileBytes(Map<String, dynamic> document) {
    final imageBase64 =
        (document['fileBase64'] ?? document['imageBase64'] ?? '')
            .toString()
            .trim();
    if (imageBase64.isEmpty) {
      return null;
    }

    try {
      return base64Decode(imageBase64);
    } catch (_) {
      return null;
    }
  }

  String _fileTypeLabel(Map<String, dynamic> document, String fileKind) {
    final extension = (document['fileExtension'] ?? '').toString().trim();
    if (extension.isNotEmpty) {
      return extension.replaceFirst('.', '').toUpperCase();
    }
    if (fileKind == 'pdf') {
      return _t('pdfDocument');
    }
    if (fileKind == 'image') {
      return 'IMAGE';
    }
    return _t('documentWord');
  }

  String _shortId(String value) {
    if (value.length <= 10) {
      return value;
    }
    return '${value.substring(0, 5)}...${value.substring(value.length - 5)}';
  }

  String _formatCreatedAt(String? rawDate) {
    final date = rawDate == null ? null : DateTime.tryParse(rawDate);
    if (date == null) {
      return _t('justNow');
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year | $hour:$minute';
  }
}
