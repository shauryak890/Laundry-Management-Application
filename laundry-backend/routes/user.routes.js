const express = require('express');
const { updateProfile, getUserById, uploadProfileImage } = require('../controllers/user.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

// All routes are protected
router.use(protect);

router.put('/profile', updateProfile);
router.put('/profile/image', uploadProfileImage);
router.get('/:id', getUserById);

module.exports = router;
