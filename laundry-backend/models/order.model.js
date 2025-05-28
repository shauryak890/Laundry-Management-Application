const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  serviceId: {
    type: String,
    required: true
  },
  serviceName: {
    type: String,
    required: true
  },
  servicePrice: {
    type: Number,
    required: true
  },
  serviceUnit: {
    type: String,
    required: true
  },
  quantity: {
    type: Number,
    required: true,
    default: 1
  },
  totalPrice: {
    type: Number,
    required: true
  },
  status: {
    type: String,
    enum: ['scheduled', 'pickedUp', 'inProcess', 'outForDelivery', 'delivered', 'cancelled'],
    default: 'scheduled'
  },
  pickupDate: {
    type: Date,
    required: true
  },
  deliveryDate: {
    type: Date,
    required: true
  },
  timeSlot: {
    type: String,
    required: true
  },
  addressId: {
    type: String,
    required: true
  },
  addressText: {
    type: String,
    required: true
  },
  statusTimestamps: {
    type: Map,
    of: Date,
    default: {}
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Middleware to set updated time
OrderSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  
  // Set status timestamp if status is changed
  if (this.isModified('status')) {
    this.statusTimestamps.set(this.status, new Date());
  }
  
  next();
});

module.exports = mongoose.model('Order', OrderSchema);
