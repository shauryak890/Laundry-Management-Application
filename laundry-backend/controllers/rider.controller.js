const Rider = require('../models/rider.model');
const User = require('../models/user.model');
const Order = require('../models/order.model');
const mongoose = require('mongoose');

// @desc    Get all riders
// @route   GET /api/riders
// @access  Private (Admin)
exports.getRiders = async (req, res) => {
  try {
    // Get riders with populated user data
    const riders = await Rider.find()
      .populate('userId', 'name email phoneNumber profileImageUrl')
      .populate('currentOrder', 'status pickupDate deliveryDate addressText');

    res.status(200).json({
      success: true,
      count: riders.length,
      data: riders
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

// @desc    Get rider by ID
// @route   GET /api/riders/:id
// @access  Private (Admin, Rider - own profile only)
exports.getRider = async (req, res) => {
  try {
    const rider = await Rider.findById(req.params.id)
      .populate('userId', 'name email phoneNumber profileImageUrl')
      .populate('currentOrder', 'status pickupDate deliveryDate addressText')
      .populate('assignedOrders', 'status pickupDate deliveryDate addressText');

    if (!rider) {
      return res.status(404).json({
        success: false,
        error: 'Rider not found'
      });
    }

    // Check if user is rider and trying to access another rider's profile
    if (req.user.role === 'rider' && rider.userId._id.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to access this rider profile'
      });
    }

    res.status(200).json({
      success: true,
      data: rider
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

// @desc    Create a new rider (from existing user)
// @route   POST /api/riders
// @access  Private (Admin)
exports.createRider = async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { userId } = req.body;

    // Check if user exists
    const user = await User.findById(userId);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    // Check if user is already a rider
    const existingRider = await Rider.findOne({ userId });
    
    if (existingRider) {
      return res.status(400).json({
        success: false,
        error: 'User is already a rider'
      });
    }

    // Update user role
    user.role = 'rider';
    await user.save({ session });

    // Create rider profile
    const rider = await Rider.create([{
      userId: user._id,
      status: 'offline',
      location: {
        type: 'Point',
        coordinates: [0, 0]
      }
    }], { session });

    await session.commitTransaction();
    
    res.status(201).json({
      success: true,
      data: rider[0]
    });
  } catch (err) {
    await session.abortTransaction();
    console.error(err);
    
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  } finally {
    session.endSession();
  }
};

// @desc    Update rider status
// @route   PUT /api/riders/:id/status
// @access  Private (Admin, Rider - own profile only)
exports.updateRiderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    
    if (!['available', 'busy', 'offline'].includes(status)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid status. Must be available, busy, or offline'
      });
    }

    let rider = await Rider.findById(req.params.id);

    if (!rider) {
      return res.status(404).json({
        success: false,
        error: 'Rider not found'
      });
    }

    // Check if user is rider and trying to update another rider's status
    if (req.user.role === 'rider' && rider.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to update this rider'
      });
    }

    // If going offline, check for active orders
    if (status === 'offline' && rider.activeOrderCount > 0) {
      return res.status(400).json({
        success: false,
        error: 'Cannot go offline with active orders'
      });
    }

    rider.status = status;
    await rider.save();

    res.status(200).json({
      success: true,
      data: rider
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

// @desc    Update rider location
// @route   PUT /api/riders/:id/location
// @access  Private (Rider - own profile only)
exports.updateRiderLocation = async (req, res) => {
  try {
    const { latitude, longitude } = req.body;
    
    if (longitude === undefined || latitude === undefined) {
      return res.status(400).json({
        success: false,
        error: 'Latitude and longitude are required'
      });
    }

    let rider = await Rider.findById(req.params.id);

    if (!rider) {
      return res.status(404).json({
        success: false,
        error: 'Rider not found'
      });
    }

    // Check if user is rider and trying to update another rider's location
    if (req.user.role === 'rider' && rider.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to update this rider location'
      });
    }

    // Update rider location
    rider.location = {
      type: 'Point',
      coordinates: [longitude, latitude],
      lastUpdated: Date.now()
    };
    
    await rider.save();

    // If rider has a current order, update its rider location too
    if (rider.currentOrder) {
      await Order.findByIdAndUpdate(rider.currentOrder, {
        riderLocation: {
          type: 'Point',
          coordinates: [longitude, latitude],
          lastUpdated: Date.now()
        }
      });
    }

    res.status(200).json({
      success: true,
      data: rider
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

// @desc    Get orders assigned to a rider
// @route   GET /api/riders/:id/orders
// @access  Private (Admin, Rider - own orders only)
exports.getRiderOrders = async (req, res) => {
  try {
    const rider = await Rider.findById(req.params.id);

    if (!rider) {
      return res.status(404).json({
        success: false,
        error: 'Rider not found'
      });
    }

    // Check if user is rider and trying to access another rider's orders
    if (req.user.role === 'rider' && rider.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to access these orders'
      });
    }

    // Get orders with status filter if provided
    const statusFilter = req.query.status ? { status: req.query.status } : {};
    
    const orders = await Order.find({
      assignedRider: req.params.id,
      ...statusFilter
    }).sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: orders.length,
      data: orders
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};
