const User = require('../models/user.model');

// @desc    Register user
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res) => {
  try {
    const { name, email, password, phoneNumber = '' } = req.body;

    // Check if user already exists
    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({
        success: false,
        error: 'User with this email already exists'
      });
    }

    // Create user
    const user = await User.create({
      name,
      email,
      password,
      phoneNumber // Now optional with default empty string
    });

    sendTokenResponse(user, 201, res);
  } catch (err) {
    res.status(400).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res) => {
  try {
    console.log('Login attempt:', req.body.email);
    const { email, password } = req.body;

    // Validate email & password
    if (!email || !password) {
      console.log('Missing email or password');
      return res.status(400).json({
        success: false,
        error: 'Please provide an email and password'
      });
    }

    // Check for user
    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      console.log('User not found:', email);
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    console.log('User found:', user.email, 'Role:', user.role);

    // Check if password matches
    const isMatch = await user.matchPassword(password);

    if (!isMatch) {
      console.log('Password does not match');
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    console.log('Password matched, generating token');
    sendTokenResponse(user, 200, res);
  } catch (err) {
    console.error('Login error:', err);
    res.status(400).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Get current logged in user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: err.message
    });
  }
};

// @desc    Log user out / clear cookie
// @route   GET /api/auth/logout
// @access  Private
exports.logout = async (req, res) => {
  res.status(200).json({
    success: true,
    data: {}
  });
};

// Get token from model, create cookie and send response
const sendTokenResponse = (user, statusCode, res) => {
  try {
    console.log('JWT_SECRET:', process.env.JWT_SECRET ? 'Set' : 'Not set');
    console.log('JWT_EXPIRE:', process.env.JWT_EXPIRE);
    
    // Create token
    console.log('Generating JWT token for user:', user.email, 'with role:', user.role);
    const token = user.getSignedJwtToken();
    console.log('Token generated successfully');

    // Parse JWT_EXPIRE for cookie expiration
    let expireTime;
    if (typeof process.env.JWT_EXPIRE === 'string' && process.env.JWT_EXPIRE.endsWith('d')) {
      // If format is like '30d' (30 days)
      const days = parseInt(process.env.JWT_EXPIRE.slice(0, -1), 10);
      expireTime = days * 24 * 60 * 60 * 1000; // Convert days to milliseconds
      console.log(`JWT_EXPIRE parsed as ${days} days (${expireTime} ms)`);
    } else {
      // Assume it's already in milliseconds or handle other formats
      expireTime = process.env.JWT_EXPIRE * 24 * 60 * 60 * 1000;
      console.log(`JWT_EXPIRE used directly: ${expireTime} ms`);
    }

    const options = {
      expires: new Date(Date.now() + expireTime),
      httpOnly: true
    };
    console.log('Cookie expiration set to:', options.expires);

    // Prepare response
    const response = {
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        profileImageUrl: user.profileImageUrl,
        role: user.role,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      }
    };
    
    console.log('Sending successful login response with token');
    res.status(statusCode).json(response);
  } catch (error) {
    console.error('Error in sendTokenResponse:', error);
    res.status(500).json({
      success: false,
      error: 'Error generating authentication token'
    });
  }
};
