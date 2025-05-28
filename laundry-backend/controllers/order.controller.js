const Order = require('../models/order.model');

// @desc    Create new order
// @route   POST /api/orders
// @access  Private
exports.createOrder = async (req, res) => {
  try {
    const {
      serviceId,
      serviceName,
      servicePrice,
      serviceUnit,
      quantity,
      totalPrice,
      pickupDate,
      deliveryDate,
      timeSlot,
      addressId,
      addressText
    } = req.body;

    // Create order with user ID from authenticated user
        // Require authenticated user
    if (!req.user || !req.user._id) {
      return res.status(401).json({ success: false, error: 'Not authorized: user not authenticated' });
    }
    const userId = req.user._id;
    // Validate userId
    if (!require('mongoose').Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ success: false, error: 'Invalid user ID' });
    }
    const order = await Order.create({
      userId,
      serviceId,
      serviceName,
      servicePrice,
      serviceUnit,
      quantity,
      totalPrice,
      pickupDate,
      deliveryDate,
      timeSlot,
      addressId,
      addressText,
      statusTimestamps: {
        'scheduled': new Date()
      }
    });

    res.status(201).json({
      success: true,
      data: order
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Get all orders for current user
// @route   GET /api/orders
// @access  Private
exports.getUserOrders = async (req, res) => {
  try {
        // Require authenticated user
    if (!req.user || !req.user._id) {
      return res.status(401).json({ success: false, error: 'Not authorized: user not authenticated' });
    }
    const userId = req.user._id;
    // Validate userId
    if (!require('mongoose').Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ success: false, error: 'Invalid user ID' });
    }
    const orders = await Order.find({ userId }).sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: orders.length,
      data: orders
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Get order by ID
// @route   GET /api/orders/:id
// @access  Private
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({
        success: false,
        error: 'Order not found'
      });
    }

    // Make sure user owns the order
    // DEV: skip user check if req.user is missing
    if (req.user && order.userId.toString() !== req.user._id.toString()) {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to access this order'
      });
    }

    res.status(200).json({
      success: true,
      data: order
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Update order status
// @route   PUT /api/orders/:id/status
// @access  Private
exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    
    if (!status) {
      return res.status(400).json({
        success: false,
        error: 'Please provide a status'
      });
    }
    
    let order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({
        success: false,
        error: 'Order not found'
      });
    }

    // Make sure user owns the order
    // DEV: skip user check if req.user is missing
    if (req.user && order.userId.toString() !== req.user._id.toString()) {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to update this order'
      });
    }
    
    // Update status and add timestamp
    order.status = status;
    order.statusTimestamps.set(status, new Date());
    order.updatedAt = Date.now();
    
    await order.save();

    res.status(200).json({
      success: true,
      data: order
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Cancel order
// @route   DELETE /api/orders/:id
// @access  Private
exports.cancelOrder = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({
        success: false,
        error: 'Order not found'
      });
    }

    // Make sure user owns the order
    // DEV: skip user check if req.user is missing
    if (req.user && order.userId.toString() !== req.user._id.toString()) {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to cancel this order'
      });
    }
    
    // Only allow cancellation if order is scheduled
    if (order.status !== 'scheduled') {
      return res.status(400).json({
        success: false,
        error: 'Order cannot be cancelled at this stage'
      });
    }
    
    // Update status to cancelled
    order.status = 'cancelled';
    order.statusTimestamps.set('cancelled', new Date());
    order.updatedAt = Date.now();
    
    await order.save();

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
