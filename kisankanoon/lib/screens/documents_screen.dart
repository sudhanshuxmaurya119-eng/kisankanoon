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
                    'मेरे दस्तावेज़',
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
                      '📁 डिवाइस फ़ोल्डर',
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
            'कोई दस्तावेज़ नहीं',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'स्कैन या अपलोड करें, फिर दस्तावेज़ यहाँ अपने आप दिखाई देंगे।',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textMid),
          ),
        ],
      ),
    );
  }

  Widget _documentCard(BuildContext context, Map<String, dynamic> document) {
    final localPath =
        (document['localPath'] ?? document['imagePath'] ?? '').toString();
    final imageFile = localPath.isEmpty ? null : File(localPath);
    final hasImage = imageFile != null && imageFile.existsSync();
    final summary = (document['summary'] ?? '').toString().trim();

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
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.bgGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('📄', style: TextStyle(fontSize: 24)),
                  ),
                )
              : const Center(child: Text('📄', style: TextStyle(fontSize: 24))),
        ),
        title: Text(
          (document['name'] ?? document['title'] ?? 'दस्तावेज़').toString(),
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
              (document['type'] ?? 'Document').toString(),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCreatedAt(document['createdAt']?.toString()),
              style: const TextStyle(fontSize: 11, color: AppTheme.textMid),
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 4),
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
                title: const Text('हटाएँ?'),
                content: const Text(
                  'यह दस्तावेज़ फ़ोल्डर और सूची दोनों से हटा दिया जाएगा।',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('नहीं'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'हाँ',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await DocumentService.deleteDocument(
                document['id'].toString(),
                localPath,
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
    final localPath =
        (document['localPath'] ?? document['imagePath'] ?? '').toString();
    final imageFile = localPath.isEmpty ? null : File(localPath);
    final hasImage = imageFile != null && imageFile.existsSync();
    final summary = (document['summary'] ?? '').toString().trim();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
              (document['name'] ?? document['title'] ?? 'दस्तावेज़').toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(document['type'] ?? 'Document').toString()} • ${_formatCreatedAt(document['createdAt']?.toString())}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMid),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.bgGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('📄', style: TextStyle(fontSize: 42)),
                      ),
                    )
                  : const Center(
                      child: Text('📄', style: TextStyle(fontSize: 42)),
                    ),
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'विश्लेषण',
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
    );
  }

  String _formatCreatedAt(String? rawDate) {
    final date = rawDate == null ? null : DateTime.tryParse(rawDate);
    if (date == null) return 'अभी जोड़ा गया';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }
}
