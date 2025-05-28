# Laundry Management App - Backend API

This is the backend API for the Whites & Brights Laundry Management App. It provides endpoints for user authentication, profile management, order creation and tracking, and address management.

## Technologies Used

- Node.js
- Express.js
- MongoDB with Mongoose
- JSON Web Tokens (JWT) for authentication

## Setup Instructions

### Prerequisites

- Node.js (v14+ recommended)
- MongoDB (local or Atlas)

### Installation

1. Install dependencies:
   ```
   npm install
   ```

2. Set up environment variables:
   Create a `.env` file in the root directory with the following variables:
   ```
   PORT=5000
   MONGODB_URI=mongodb://localhost:27017/laundry_app
   JWT_SECRET=your_jwt_secret_key_change_this_in_production
   JWT_EXPIRE=30d
   ```

3. Start the server:
   ```
   npm run dev
   ```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user
- `GET /api/auth/logout` - Logout user

### User Management

- `PUT /api/users/profile` - Update user profile
- `PUT /api/users/profile/image` - Upload profile image
- `GET /api/users/:id` - Get user by ID

### Order Management

- `POST /api/orders` - Create a new order
- `GET /api/orders` - Get all orders for current user
- `GET /api/orders/:id` - Get order by ID
- `PUT /api/orders/:id/status` - Update order status
- `DELETE /api/orders/:id` - Cancel order

### Address Management

- `POST /api/addresses` - Create a new address
- `GET /api/addresses` - Get all addresses for current user
- `GET /api/addresses/:id` - Get address by ID
- `PUT /api/addresses/:id` - Update address
- `DELETE /api/addresses/:id` - Delete address

## License

MIT
