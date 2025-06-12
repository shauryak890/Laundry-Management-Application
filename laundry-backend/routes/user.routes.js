const express = require('express');
const { updateProfile, getUserById, uploadProfileImage, getCurrentUser } = require('../controllers/user.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

// All routes are protected
router.use(protect);

// Get current user profile
router.get('/me', getCurrentUser);

router.put('/profile', updateProfile);
router.put('/profile/image', uploadProfileImage);
router.get('/:id', getUserById);

module.exports = router;
