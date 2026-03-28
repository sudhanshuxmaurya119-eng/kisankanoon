import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/document_service.dart';

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
            // Header
            Container(
              color: AppTheme.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  const Text('मेरे दस्तावेज़', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.bgGreen, borderRadius: BorderRadius.circular(20)),
                    child: const Text('🔒 सुरक्षित', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            // Document list using Firestore stream
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: DocumentService.getDocumentsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
                  }
                  final docs = snapshot.data ?? [];
                  if (docs.isEmpty) {
                    return _emptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, i) => _docCard(context, docs[i]),
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
          const Text('कोई दस्तावेज़ नहीं', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          const Text('स्कैन टैब से दस्तावेज़ जोड़ें', style: TextStyle(fontSize: 13, color: AppTheme.textMid)),
        ],
      ),
    );
  }

  Widget _docCard(BuildContext context, Map<String, dynamic> doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppTheme.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: AppTheme.bgGreen, borderRadius: BorderRadius.circular(10)),
          child: const Center(child: Text('📄', style: TextStyle(fontSize: 26))),
        ),
        title: Text(
          doc['name'] ?? 'दस्तावेज़',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(doc['type'] ?? 'Document', style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('हटाएं?'),
                content: const Text('यह दस्तावेज़ हमेशा के लिए हटा दिया जाएगा।'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('नहीं')),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('हाँ', style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirm == true) {
              await DocumentService.deleteDocument(
                doc['id'],
                doc['storagePath'] as String?,
              );
            }
          },
        ),
      ),
    );
  }
}
