const User = require('../models/user.model');

// @desc    Create new address
// @route   POST /api/addresses
// @access  Private
exports.createAddress = async (req, res) => {
  try {
    const {
      addressLine1,
      addressLine2,
      city,
      state,
      pincode,
      country,
      label,
      isDefault
    } = req.body;

    // Check if this is the first address (make it default)
    const user = await User.findById(req.user._id);
    const addressCount = user.addresses.length;
    const shouldBeDefault = isDefault || addressCount === 0;

    // If setting as default, unset any existing default
    if (shouldBeDefault) {
      user.addresses.forEach((address) => {
        if (address.isDefault) {
          address.isDefault = false;
        }
      });
    }

    // Create address
    user.addresses.push({
      addressLine1,
      addressLine2,
      city,
      state,
      pincode,
      country: country || 'India',
      label: label || 'home',
      isDefault: shouldBeDefault
    });

    await user.save();

    res.status(201).json({
      success: true,
      data: user.addresses[user.addresses.length - 1]
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Get all addresses for current user
// @route   GET /api/addresses
// @access  Private
exports.getAddresses = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).populate('addresses');

    res.status(200).json({
      success: true,
      count: user.addresses.length,
      data: user.addresses.sort((a, b) => b.isDefault - a.isDefault)
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Get address by ID
// @route   GET /api/addresses/:id
// @access  Private
exports.getAddressById = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const address = user.addresses.find((address) => address._id.toString() === req.params.id);

    if (!address) {
      return res.status(404).json({
        success: false,
        error: 'Address not found'
      });
    }

    res.status(200).json({
      success: true,
      data: address
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Update address
// @route   PUT /api/addresses/:id
// @access  Private
exports.updateAddress = async (req, res) => {
  try {
    const {
      addressLine1,
      addressLine2,
      city,
      state,
      pincode,
      country,
      label,
      isDefault
    } = req.body;

    const user = await User.findById(req.user._id);
    const addressIndex = user.addresses.findIndex((address) => address._id.toString() === req.params.id);

    if (addressIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Address not found'
      });
    }

    // If setting as default, unset any existing default
    if (isDefault) {
      user.addresses.forEach((address) => {
        if (address.isDefault) {
          address.isDefault = false;
        }
      });
    }

    // Update address
    user.addresses[addressIndex] = {
      ...user.addresses[addressIndex],
      addressLine1,
      addressLine2,
      city,
      state,
      pincode,
      country,
      label,
      isDefault: isDefault || user.addresses[addressIndex].isDefault,
      updatedAt: Date.now()
    };

    await user.save();

    res.status(200).json({
      success: true,
      data: user.addresses[addressIndex]
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Delete address
// @route   DELETE /api/addresses/:id
// @access  Private
exports.deleteAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const addressIndex = user.addresses.findIndex((address) => address._id.toString() === req.params.id);

    if (addressIndex === -1) {
      return res.status(404).json({
        success: false,
        error: 'Address not found'
      });
    }

    // Check if this is the default address
    const isDefault = user.addresses[addressIndex].isDefault;

    // Remove the address from the array
    user.addresses.splice(addressIndex, 1);

    // If deleted address was default, set another one as default
    if (isDefault && user.addresses.length > 0) {
      user.addresses[0].isDefault = true;
    }

    await user.save();

    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
};
