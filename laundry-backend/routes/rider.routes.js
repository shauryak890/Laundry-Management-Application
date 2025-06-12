const express = require('express');
const router = express.Router();

// Import middleware
const { protect } = require('../middleware/auth.middleware');
const { checkRole } = require('../middleware/role.middleware');

// Import controllers
const {
  getRiders,
  getRider,
  createRider,
  updateRiderStatus,
  updateRiderLocation,
  getRiderOrders
} = require('../controllers/rider.controller');

// Routes with protection middleware
router.use(protect);

// Routes accessible to admin only
router.route('/')
  .get(checkRole('admin'), getRiders)
  .post(checkRole('admin'), createRider);

// Routes with mixed access
router.route('/:id')
  .get(checkRole('admin', 'rider'), getRider);

router.route('/:id/status')
  .put(checkRole('admin', 'rider'), updateRiderStatus);

router.route('/:id/location')
  .put(checkRole('rider'), updateRiderLocation);

router.route('/:id/orders')
  .get(checkRole('admin', 'rider'), getRiderOrders);

module.exports = router;
