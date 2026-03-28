const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'kisankanoon_secret_2025';

// Helper to generate JWT
const signToken = (userId) =>
  jwt.sign({ id: userId }, JWT_SECRET, { expiresIn: '30d' });

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { name, mobile, email, password, country, state } = req.body;
    if (!name || !email || !password || !mobile) {
      return res.status(400).json({ message: 'सभी फ़ील्ड आवश्यक हैं।' });
    }
    const exists = await User.findOne({ email: email.toLowerCase() });
    if (exists) {
      return res.status(400).json({ message: 'यह ईमेल पहले से पंजीकृत है।' });
    }
    const user = await User.create({ name, mobile, email, password, country, state });
    const token = signToken(user._id);
    res.status(201).json({ token, user });
  } catch (err) {
    res.status(500).json({ message: 'सर्वर में त्रुटि। पुनः प्रयास करें।' });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'ईमेल और पासवर्ड आवश्यक हैं।' });
    }
    const user = await User.findOne({ email: email.toLowerCase() }).select('+password');
    if (!user) {
      return res.status(401).json({ message: 'यह ईमेल पंजीकृत नहीं है।' });
    }
    const valid = await user.comparePassword(password);
    if (!valid) {
      return res.status(401).json({ message: 'पासवर्ड गलत है।' });
    }
    const token = signToken(user._id);
    res.json({ token, user });
  } catch (err) {
    res.status(500).json({ message: 'सर्वर में त्रुटि। पुनः प्रयास करें।' });
  }
});

// GET /api/auth/me  (protected)
router.get('/me', authenticate, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) return res.status(404).json({ message: 'उपयोगकर्ता नहीं मिला।' });
    res.json({ user });
  } catch (err) {
    res.status(500).json({ message: 'सर्वर में त्रुटि।' });
  }
});

// Middleware: Authenticate JWT
function authenticate(req, res, next) {
  const auth = req.headers.authorization;
  if (!auth || !auth.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'अनधिकृत अनुरोध।' });
  }
  try {
    const decoded = jwt.verify(auth.split(' ')[1], JWT_SECRET);
    req.userId = decoded.id;
    next();
  } catch {
    res.status(401).json({ message: 'टोकन अमान्य है।' });
  }
}

module.exports = { router, authenticate };
