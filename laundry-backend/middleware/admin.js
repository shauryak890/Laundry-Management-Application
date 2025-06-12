const jwt = require('jsonwebtoken');
const User = require('../models/user.model');

// Middleware to protect admin routes
const adminProtect = async (req, res, next) => {
  try {
    // Check if there's a token in the header
    let token;
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    // Check if token exists
    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to access this route'
      });
    }

    try {
      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Get user from the token
      const user = await User.findById(decoded.id);
      
      if (!user) {
        return res.status(401).json({
          success: false,
          error: 'User not found with this ID'
        });
      }

      // Check if user is an admin
      if (user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          error: 'Not authorized to access this route. Admin access required.'
        });
      }

      // Set user in request
      req.user = user;
      next();
    } catch (err) {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to access this route'
      });
    }
  } catch (err) {
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
};

module.exports = adminProtect;
