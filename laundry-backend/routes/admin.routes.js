const express = require('express');
const router = express.Router();
const adminProtect = require('../middleware/admin');
const User = require('../models/user.model');
const Order = require('../models/order.model');
const Service = require('../models/service.model');

// Get dashboard metrics
router.get('/dashboard', adminProtect, async (req, res) => {
  try {
    // Count total orders
    const totalOrders = await Order.countDocuments();
    
    // Count orders by status
    const pendingOrders = await Order.countDocuments({ 
      status: { $in: ['scheduled', 'pickedUp', 'inProcess', 'outForDelivery'] } 
    });
    
    const completedOrders = await Order.countDocuments({ status: 'delivered' });
    
    // Calculate revenue (sum of totalPrice from all completed orders)
    const revenueData = await Order.aggregate([
      { $match: { status: 'delivered' } },
      { $group: { _id: null, totalRevenue: { $sum: '$totalPrice' } } }
    ]);
    
    const revenue = revenueData.length > 0 ? revenueData[0].totalRevenue : 0;
    
    // Count total users
    const totalUsers = await User.countDocuments({ role: 'user' });

    res.status(200).json({
      success: true,
      data: {
        totalOrders,
        pendingOrders,
        completedOrders,
        revenue,
        totalUsers
      }
    });
  } catch (error) {
    console.error('Dashboard metrics error:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
});

// Get all users with filtering and pagination
router.get('/users', adminProtect, async (req, res) => {
  try {
    const { search, status, page = 1, limit = 10 } = req.query;
    
    // Build query
    let query = { role: 'user' };
    
    // Add search filter if provided
    if (search) {
      query = {
        ...query,
        $or: [
          { name: { $regex: search, $options: 'i' } },
          { email: { $regex: search, $options: 'i' } },
          { phoneNumber: { $regex: search, $options: 'i' } }
        ]
      };
    }
    
    // Add status filter if provided (active/inactive can be determined by lastLogin date)
    // This assumes you'll add a lastLogin field to track user activity
    
    // Execute query with pagination
    const users = await User.find(query)
      .select('-password')
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .sort({ createdAt: -1 });
      
    // Get total count for pagination
    const total = await User.countDocuments(query);
    
    res.status(200).json({
      success: true,
      count: users.length,
      pagination: {
        total,
        page: parseInt(page),
        pages: Math.ceil(total / limit)
      },
      data: users
    });
  } catch (error) {
    console.error('Get all users error:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
});

// Get all orders with filtering and pagination
router.get('/orders', adminProtect, async (req, res) => {
  try {
    const { status, userId, page = 1, limit = 10 } = req.query;
    
    // Build query
    let query = {};
    
    // Add status filter if provided
    if (status) {
      query.status = status;
    }
    
    // Add user filter if provided
    if (userId) {
      query.userId = userId;
    }
    
    // Execute query with pagination
    const orders = await Order.find(query)
      .skip((page - 1) * limit)
      .limit(parseInt(limit))
      .sort({ createdAt: -1 });
      
    // Get total count for pagination
    const total = await Order.countDocuments(query);
    
    res.status(200).json({
      success: true,
      count: orders.length,
      pagination: {
        total,
        page: parseInt(page),
        pages: Math.ceil(total / limit)
      },
      data: orders
    });
  } catch (error) {
    console.error('Get all orders error:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
});

// Update order status
router.put('/orders/:id/status', adminProtect, async (req, res) => {
  try {
    const { status } = req.body;
    
    if (!status) {
      return res.status(400).json({
        success: false,
        error: 'Please provide a status'
      });
    }
    
    // Update order status
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { 
        status,
        $set: { [`statusTimestamps.${status}`]: Date.now() },
        updatedAt: Date.now()
      },
      { new: true, runValidators: true }
    );
    
    if (!order) {
      return res.status(404).json({
        success: false,
        error: 'Order not found'
      });
    }
    
    // Log admin action
    await AdminLog.create({
      adminId: req.user._id,
      action: 'UPDATE_ORDER_STATUS',
      details: {
        orderId: order._id,
        previousStatus: order.status,
        newStatus: status
      }
    });
    
    res.status(200).json({
      success: true,
      data: order
    });
  } catch (error) {
    console.error('Update order status error:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
});

// Get all services
router.get('/services', adminProtect, async (req, res) => {
  try {
    const services = await Service.find().sort('name');
    
    res.status(200).json({
      success: true,
      count: services.length,
      data: services
    });
  } catch (error) {
    console.error('Get all services error:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
});

// Create new service
router.post('/services', adminProtect, async (req, res) => {
  try {
    const { name, price, unit, color, description } = req.body;
    
    // Create service
    const service = await Service.create({
      name,
      price,
      unit,
      color,
      description,
      createdBy: req.user._id
    });
    
    // Log admin action
    await AdminLog.create({
      adminId: req.user._id,
      action: 'CREATE_SERVICE',
      details: {
        serviceId: service._id,
        serviceName: service.name
      }
    });
    
    res.status(201).json({
      success: true,
      data: service
    });
  } catch (error) {
    console.error('Create service error:', error);
    
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        error: 'A service with this name already exists'
      });
    }
    
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
});

// Update service
router.put('/services/:id', adminProtect, async (req, res) => {
  try {
    const { name, price, unit, color, description } = req.body;
    
    // Find service before update to log changes
    const oldService = await Service.findById(req.params.id);
    
    if (!oldService) {
      return res.status(404).json({
        success: false,
        error: 'Service not found'
      });
    }
    
    // Update service
    const service = await Service.findByIdAndUpdate(
      req.params.id,
      {
        name,
        price,
        unit,
        color,
        description,
        updatedAt: Date.now()
      },
      { new: true, runValidators: true }
    );
    
    // Log admin action
    await AdminLog.create({
      adminId: req.user._id,
      action: 'UPDATE_SERVICE',
      details: {
        serviceId: service._id,
        serviceName: service.name,
        changes: {
          name: { from: oldService.name, to: name },
          price: { from: oldService.price, to: price }
        }
      }
    });
    
    res.status(200).json({
      success: true,
      data: service
    });
  } catch (error) {
    console.error('Update service error:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
});

// Delete service
router.delete('/services/:id', adminProtect, async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);
    
    if (!service) {
      return res.status(404).json({
        success: false,
        error: 'Service not found'
      });
    }
    
    await service.remove();
    
    // Log admin action
    await AdminLog.create({
      adminId: req.user._id,
      action: 'DELETE_SERVICE',
      details: {
        serviceId: req.params.id,
        serviceName: service.name
      }
    });
    
    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (error) {
    console.error('Delete service error:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
});

// Send notification to user
router.post('/notifications', adminProtect, async (req, res) => {
  try {
    const { userId, title, message, type } = req.body;
    
    // Validate request
    if (!title || !message) {
      return res.status(400).json({
        success: false,
        error: 'Please provide title and message'
      });
    }
    
    // Check if user exists if userId is provided
    if (userId) {
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'User not found'
        });
      }
    }
    
    // Create notification (you would implement this model)
    const notification = await Notification.create({
      userId: userId || null, // null for broadcast to all users
      title,
      message,
      type: type || 'info',
      createdBy: req.user._id
    });
    
    // Here you'd trigger push notification sending
    // This is a placeholder for your actual notification logic
    
    // Log admin action
    await AdminLog.create({
      adminId: req.user._id,
      action: 'SEND_NOTIFICATION',
      details: {
        notificationId: notification._id,
        userId: userId || 'broadcast',
        title
      }
    });
    
    res.status(201).json({
      success: true,
      data: notification
    });
  } catch (error) {
    console.error('Send notification error:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
});

// Generate invoice PDF for an order
router.get('/orders/:id/invoice', adminProtect, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    
    if (!order) {
      return res.status(404).json({
        success: false,
        error: 'Order not found'
      });
    }
    
    // Get user details for the invoice
    const user = await User.findById(order.userId).select('name email phoneNumber');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }
    
    // This would be where you generate the PDF
    // For now, we'll just return the data needed for invoice generation
    
    // Log admin action
    await AdminLog.create({
      adminId: req.user._id,
      action: 'GENERATE_INVOICE',
      details: {
        orderId: order._id,
        userId: order.userId
      }
    });
    
    res.status(200).json({
      success: true,
      data: {
        order,
        user: {
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber
        },
        company: {
          name: 'Whites & Brights Laundry',
          address: 'Your Company Address',
          phone: 'Your Company Phone',
          email: 'Your Company Email'
        },
        invoiceNumber: `INV-${order._id.toString().slice(-6).toUpperCase()}`,
        invoiceDate: new Date()
      }
    });
  } catch (error) {
    console.error('Generate invoice error:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
});

module.exports = router;
