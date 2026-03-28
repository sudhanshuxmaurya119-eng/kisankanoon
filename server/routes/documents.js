const express = require('express');
const cloudinary = require('cloudinary').v2;
const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const Document = require('../models/Document');
const { authenticate } = require('./auth');

const router = express.Router();

// Configure Cloudinary (free image hosting)
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || '',
  api_key: process.env.CLOUDINARY_API_KEY || '',
  api_secret: process.env.CLOUDINARY_API_SECRET || '',
});

const storage = new CloudinaryStorage({
  cloudinary,
  params: { folder: 'kisankanoon_docs', allowed_formats: ['jpg', 'jpeg', 'png'] },
});
const upload = multer({ storage });

// GET /api/documents  — get all docs for logged-in user
router.get('/', authenticate, async (req, res) => {
  try {
    const docs = await Document.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.json({ documents: docs });
  } catch (err) {
    res.status(500).json({ message: 'दस्तावेज़ लोड नहीं हो सके।' });
  }
});

// POST /api/documents  — upload a new scanned document
router.post('/', authenticate, upload.single('image'), async (req, res) => {
  try {
    const { name, type } = req.body;
    const imageUrl = req.file?.path || '';
    const publicId = req.file?.filename || '';
    const doc = await Document.create({
      userId: req.userId,
      name: name || 'दस्तावेज़',
      type: type || 'Document',
      imageUrl,
      publicId,
    });
    res.status(201).json({ document: doc });
  } catch (err) {
    res.status(500).json({ message: 'दस्तावेज़ अपलोड नहीं हो सका।' });
  }
});

// DELETE /api/documents/:id
router.delete('/:id', authenticate, async (req, res) => {
  try {
    const doc = await Document.findOne({ _id: req.params.id, userId: req.userId });
    if (!doc) return res.status(404).json({ message: 'दस्तावेज़ नहीं मिला।' });
    // Delete image from Cloudinary
    if (doc.publicId) {
      await cloudinary.uploader.destroy(doc.publicId).catch(() => {});
    }
    await doc.deleteOne();
    res.json({ message: 'दस्तावेज़ हटा दिया गया।' });
  } catch (err) {
    res.status(500).json({ message: 'दस्तावेज़ नहीं हटाया जा सका।' });
  }
});

module.exports = router;
