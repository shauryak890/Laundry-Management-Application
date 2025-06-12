/**
 * Role-based access control middleware
 * Used to restrict routes to specific user roles
 */

// Middleware to check if user has the required role
exports.checkRole = (...roles) => {
  return (req, res, next) => {
    // We expect the protect middleware to run first and set req.user
    if (!req.user || !req.user.role) {
      return res.status(403).json({
        success: false,
        error: 'Access forbidden'
      });
    }

    // Check if user role is included in the allowed roles
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: `User role ${req.user.role} is not authorized to access this route`
      });
    }

    next();
  };
};

// Middleware to specifically check for admin access
exports.adminOnly = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      error: 'Admin access required'
    });
  }
  next();
};

// Middleware to specifically check for rider access
exports.riderOnly = (req, res, next) => {
  if (!req.user || req.user.role !== 'rider') {
    return res.status(403).json({
      success: false,
      error: 'Rider access required'
    });
  }
  next();
};
