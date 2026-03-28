import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../models/document_model.dart';
import '../services/storage_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool _analyzing = false;
  String? _result;

  Future<void> _pickImage(ImageSource source) async {
    final img = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (img == null) return;
    setState(() {
      _pickedImage = img;
      _analyzing = true;
      _result = null;
    });
    // Simulate document analysis
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _analyzing = false;
      _result = 'यह एक भूमि रजिस्ट्री दस्तावेज़ है।\n\nमुख्य विवरण:\n• खसरा संख्या: 452/3\n• क्षेत्र: 2.5 बीघा\n• मालिक: रामलाल वर्मा\n• जिला: वाराणसी, उत्तर प्रदेश\n\nयह दस्तावेज़ वैध है। किसी भी प्रश्न के लिए 15100 पर कॉल करें।';
    });
    await StorageService.incrementScanCount();
  }

  Future<void> _saveDocument() async {
    if (_pickedImage == null || _result == null) return;
    final doc = DocumentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'स्कैन किया दस्तावेज़',
      type: 'भूमि रजिस्ट्री',
      imagePath: _pickedImage!.path,
      summary: _result!,
      createdAt: DateTime.now(),
    );
    await StorageService.saveDoc(doc);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('दस्तावेज़ सुरक्षित हो गया!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    setState(() {
      _pickedImage = null;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('दस्तावेज़ स्कैन करें'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_pickedImage == null) ...[
                // Scan area
                Container(
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
                    children: const [
                      Text('📄', style: TextStyle(fontSize: 60)),
                      SizedBox(height: 16),
                      Text(
                        'कागज़ की फोटो लें',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'खसरा, Aadhaar, बैंक पर्ची आदि',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMid),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('कैमरा'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, color: AppTheme.primaryGreen),
                          label: const Text(
                            'गैलरी',
                            style: TextStyle(color: AppTheme.primaryGreen),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryGreen),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Image preview
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
                if (_analyzing)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: const [
                        CircularProgressIndicator(color: AppTheme.primaryGreen),
                        SizedBox(height: 16),
                        Text(
                          'दस्तावेज़ पढ़ रहे हैं...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_result != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'विश्लेषण पूरा',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _result!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textDark,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _saveDocument,
                            icon: const Icon(Icons.save),
                            label: const Text('सुरक्षित करें'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => setState(() {
                              _pickedImage = null;
                              _result = null;
                            }),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primaryGreen),
                            ),
                            child: const Text(
                              'नया स्कैन',
                              style: TextStyle(color: AppTheme.primaryGreen),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Supported documents
              Container(
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
                        'समर्थित दस्तावेज़',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    ...['📄 खसरा / खतौनी', '🪪 Aadhaar कार्ड', '🏦 बैंक पर्ची', '📋 भूमि रजिस्ट्री', '🏛️ सरकारी नोटिस', '⚖️ अदालती कागज़']
                        .map((item) => ListTile(
                      dense: true,
                      title: Text(item, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                      trailing: const Icon(Icons.check, color: AppTheme.accentGreen, size: 16),
                    )),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
