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
  assignedRider: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Rider',
    default: null
  },
  riderLocation: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point'
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      default: [0, 0]
    },
    lastUpdated: {
      type: Date,
      default: null
    }
  },
  isAssigned: {
    type: Boolean,
    default: false
  },
  assignedAt: {
    type: Date,
    default: null
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

// Middleware to set updated time and handle rider assignment
OrderSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  
  // Set status timestamp if status is changed
  if (this.isModified('status')) {
    this.statusTimestamps.set(this.status, new Date());
  }
  
  // Update isAssigned flag if rider is assigned or removed
  if (this.isModified('assignedRider')) {
    if (this.assignedRider) {
      this.isAssigned = true;
      this.assignedAt = new Date();
    } else {
      this.isAssigned = false;
      this.assignedAt = null;
    }
  }
  
  next();
});

// Create a 2dsphere index for location-based queries
OrderSchema.index({ 'riderLocation.coordinates': '2dsphere' });

module.exports = mongoose.model('Order', OrderSchema);
