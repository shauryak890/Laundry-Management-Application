const express = require('express');
const { 
  createAddress, 
  getAddresses, 
  getAddressById, 
  updateAddress, 
  deleteAddress 
} = require('../controllers/address.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

// All routes are protected
router.use(protect);

router.route('/')
  .post(createAddress)
  .get(getAddresses);

router.route('/:id')
  .get(getAddressById)
  .put(updateAddress)
  .delete(deleteAddress);

module.exports = router;
