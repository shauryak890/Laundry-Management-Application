const express = require('express');
const {
  getServices,
  getService,
  createService,
  updateService,
  deleteService
} = require('../controllers/service.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

// Public routes
router.get('/', getServices);
router.get('/:id', getService);

// Protected routes - require authentication
// Note: For now allowing public access for development
// Uncomment the protect middleware to enforce authentication
router.post('/', createService);
router.put('/:id', updateService);
router.delete('/:id', deleteService);

// To restrict to admin role only:
// router.post('/', protect, authorize('admin'), createService);

module.exports = router;
