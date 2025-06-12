const Service = require('../models/service.model');

/**
 * @desc    Get all services
 * @route   GET /api/services
 * @access  Public
 */
exports.getServices = async (req, res) => {
  try {
    const services = await Service.find();
    
    res.status(200).json({
      success: true,
      count: services.length,
      data: services
    });
  } catch (error) {
    console.error('Error fetching services:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

/**
 * @desc    Get single service
 * @route   GET /api/services/:id
 * @access  Public
 */
exports.getService = async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);
    
    if (!service) {
      return res.status(404).json({
        success: false,
        error: 'Service not found'
      });
    }
    
    res.status(200).json({
      success: true,
      data: service
    });
  } catch (error) {
    console.error('Error fetching service:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

/**
 * @desc    Create new service
 * @route   POST /api/services
 * @access  Private
 */
exports.createService = async (req, res) => {
  try {
    // Add created by user if authenticated
    if (req.user) {
      req.body.createdBy = req.user.id;
    }
    
    const service = await Service.create(req.body);
    
    res.status(201).json({
      success: true,
      data: service
    });
  } catch (error) {
    console.error('Error creating service:', error);
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(val => val.message);
      return res.status(400).json({
        success: false,
        error: messages
      });
    } else if (error.code === 11000) {
      // Duplicate key error
      return res.status(400).json({
        success: false,
        error: 'Service name already exists'
      });
    } else {
      res.status(500).json({
        success: false,
        error: 'Server Error'
      });
    }
  }
};

/**
 * @desc    Update service
 * @route   PUT /api/services/:id
 * @access  Private
 */
exports.updateService = async (req, res) => {
  try {
    let service = await Service.findById(req.params.id);
    
    if (!service) {
      return res.status(404).json({
        success: false,
        error: 'Service not found'
      });
    }
    
    // Update timestamps
    req.body.updatedAt = Date.now();
    
    // Update service
    service = await Service.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });
    
    res.status(200).json({
      success: true,
      data: service
    });
  } catch (error) {
    console.error('Error updating service:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};

/**
 * @desc    Delete service
 * @route   DELETE /api/services/:id
 * @access  Private
 */
exports.deleteService = async (req, res) => {
  try {
    const service = await Service.findById(req.params.id);
    
    if (!service) {
      return res.status(404).json({
        success: false,
        error: 'Service not found'
      });
    }
    
    await service.deleteOne();
    
    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (error) {
    console.error('Error deleting service:', error);
    res.status(500).json({
      success: false,
      error: 'Server Error'
    });
  }
};
