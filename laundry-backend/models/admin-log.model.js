const mongoose = require('mongoose');

const AdminLogSchema = new mongoose.Schema({
  adminId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  action: {
    type: String,
    required: true,
    enum: [
      'LOGIN',
      'LOGOUT',
      'UPDATE_USER',
      'DELETE_USER',
      'UPDATE_ORDER_STATUS',
      'CANCEL_ORDER',
      'REFUND_ORDER',
      'CREATE_SERVICE',
      'UPDATE_SERVICE',
      'DELETE_SERVICE',
      'SEND_NOTIFICATION',
      'GENERATE_INVOICE',
      'ASSIGN_DELIVERY_AGENT'
    ]
  },
  details: {
    type: mongoose.Schema.Types.Mixed
  },
  ip: {
    type: String
  },
  userAgent: {
    type: String
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

// Index by adminId and timestamp for faster queries
AdminLogSchema.index({ adminId: 1, timestamp: -1 });

module.exports = mongoose.model('AdminLog', AdminLogSchema);
