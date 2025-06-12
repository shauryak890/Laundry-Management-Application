const mongoose = require('mongoose');

const RiderSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
    required: true,
    unique: true
  },
  status: {
    type: String,
    enum: ['available', 'busy', 'offline'],
    default: 'offline'
  },
  location: {
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
      default: Date.now
    }
  },
  assignedOrders: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order'
  }],
  currentOrder: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    default: null
  },
  activeOrderCount: {
    type: Number,
    default: 0
  },
  ratings: [{
    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Order'
    },
    rating: {
      type: Number,
      min: 1,
      max: 5
    },
    review: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  averageRating: {
    type: Number,
    default: 0
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

// Create a 2dsphere index for location-based queries
RiderSchema.index({ 'location.coordinates': '2dsphere' });

// Pre-save middleware to update the updatedAt timestamp
RiderSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Calculate average rating
RiderSchema.methods.calculateAverageRating = function() {
  if (this.ratings.length === 0) {
    this.averageRating = 0;
    return;
  }
  
  const totalRating = this.ratings.reduce((sum, item) => sum + item.rating, 0);
  this.averageRating = Math.round((totalRating / this.ratings.length) * 10) / 10;
};

// Update rider status based on assigned orders
RiderSchema.methods.updateStatus = function() {
  if (this.assignedOrders.length > 0) {
    this.status = 'busy';
  } else {
    this.status = 'available';
  }
};

module.exports = mongoose.model('Rider', RiderSchema);
