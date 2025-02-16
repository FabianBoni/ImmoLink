const express = require('express');
const cors = require('cors');
const app = express();
const authRoutes = require('./routes/auth');
const propertyRoutes = require('./routes/properties');
const usersRouter = require('./routes/users');

// Enable CORS for all routes
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Mount auth routes
app.use('/api/auth', authRoutes);

// Mount routes
app.use('/api/properties', propertyRoutes);

app.use('/api/users', usersRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});