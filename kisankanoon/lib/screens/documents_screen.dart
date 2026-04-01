import 'dart:io';

import 'package:flutter/material.dart';

import '../services/document_service.dart';
import '../theme/app_theme.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  const Text(
                    'My Documents',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.bgGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Device + Firebase',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📂', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text(
            'No documents yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Scan or upload a document and it will appear here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textMid),
          ),
        ],
      ),
    );
  }

  Widget _documentCard(BuildContext context, Map<String, dynamic> document) {
    final summary = (document['summary'] ?? '').toString().trim();
    final documentNumber = (document['documentNumber'] ?? '').toString().trim();
    final syncedToFirebase = document['syncedToFirebase'] == true;

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
          (document['name'] ?? document['title'] ?? 'Document').toString(),
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
              (document['type'] ?? 'General Document').toString(),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryGreen,
              ),
            ),
            if (documentNumber.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'ID: $documentNumber',
                style: const TextStyle(fontSize: 11, color: AppTheme.textDark),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatCreatedAt(document['createdAt']?.toString()),
              style: const TextStyle(fontSize: 11, color: AppTheme.textMid),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: syncedToFirebase
                    ? AppTheme.bgGreen
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                syncedToFirebase ? 'Firebase synced' : 'Firebase sync pending',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: syncedToFirebase
                      ? AppTheme.primaryGreen
                      : Colors.orange.shade800,
                ),
              ),
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                summary.split('\n').first,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete document?'),
                content: const Text(
                  'This will remove the document from your folder. If it is synced, it will also be removed from Firebase.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm != true) {
              return;
            }

            final localPath =
                (document['localPath'] ?? document['imagePath'] ?? '').toString();
            final deleted = await DocumentService.deleteDocument(
              document['id'].toString(),
              localPath,
            );

            if (!context.mounted) {
              return;
            }

            if (!deleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Document could not be deleted from Firebase. Please try again.',
                  ),
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
    final summary = (document['summary'] ?? '').toString().trim();
    final notes = (document['notes'] ?? '').toString().trim();
    final documentNumber = (document['documentNumber'] ?? '').toString().trim();
    final ownerId = (document['ownerId'] ?? '').toString().trim();
    final syncError = (document['syncError'] ?? '').toString().trim();
    final syncedToFirebase = document['syncedToFirebase'] == true;

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
                (document['name'] ?? document['title'] ?? 'Document').toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(document['type'] ?? 'General Document').toString()} • ${_formatCreatedAt(document['createdAt']?.toString())}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMid),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 220,
                child: _previewImage(document),
              ),
              const SizedBox(height: 16),
              _detailRow('Document ID', documentNumber.isEmpty ? 'Not added' : documentNumber),
              _detailRow(
                'Firebase status',
                syncedToFirebase ? 'Synced successfully' : 'Not synced yet',
                valueColor:
                    syncedToFirebase ? AppTheme.primaryGreen : Colors.orange,
              ),
              if (ownerId.isNotEmpty)
                _detailRow('Account ID', _shortId(ownerId)),
              if (syncError.isNotEmpty)
                _detailRow(
                  'Sync message',
                  syncError,
                  valueColor: Colors.orange.shade800,
                ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes',
                  style: TextStyle(
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
              if (summary.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Analysis',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary,
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
            width: 110,
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
                fontWeight: valueColor == null ? FontWeight.w500 : FontWeight.w700,
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
    final downloadUrl = (document['downloadUrl'] ?? '').toString();
    final localFile = localPath.isEmpty ? null : File(localPath);
    final hasLocalFile = localFile != null && localFile.existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.bgGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLocalFile
          ? Image.file(
              localFile,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Text('📄', style: TextStyle(fontSize: 24)),
              ),
            )
          : downloadUrl.isNotEmpty
              ? Image.network(
                  downloadUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('📄', style: TextStyle(fontSize: 24)),
                  ),
                )
              : const Center(
                  child: Text('📄', style: TextStyle(fontSize: 24)),
                ),
    );
  }

  Widget _previewImage(Map<String, dynamic> document) {
    final localPath =
        (document['localPath'] ?? document['imagePath'] ?? '').toString();
    final downloadUrl = (document['downloadUrl'] ?? '').toString();
    final localFile = localPath.isEmpty ? null : File(localPath);
    final hasLocalFile = localFile != null && localFile.existsSync();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLocalFile
          ? Image.file(
              localFile,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Text('📄', style: TextStyle(fontSize: 42)),
              ),
            )
          : downloadUrl.isNotEmpty
              ? Image.network(
                  downloadUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('📄', style: TextStyle(fontSize: 42)),
                  ),
                )
              : const Center(
                  child: Text('📄', style: TextStyle(fontSize: 42)),
                ),
    );
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
      return 'Just now';
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }
}
