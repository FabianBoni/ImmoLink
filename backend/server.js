const express = require('express');
const cors = require('cors');
const path = require('path');
const { connectDB } = require('./database');
const app = express();
const authRoutes = require('./routes/auth');
const propertyRoutes = require('./routes/properties');
const usersRouter = require('./routes/users');
const contactsRoutes = require('./routes/contacts');
const conversationsRoutes = require('./routes/conversations');
const chatRoutes = require('./routes/chat');
const invitationsRoutes = require('./routes/invitations');
const uploadRoutes = require('./routes/upload');
const imagesRoutes = require('./routes/images');

// Enable CORS for all routes
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

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

app.use('/api/contacts', contactsRoutes);

app.use('/api/conversations', conversationsRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/invitations', invitationsRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/images', imagesRoutes);

const PORT = process.env.PORT || 3000;

// Initialize database connection and start server
async function startServer() {
  try {
    await connectDB();
    console.log('Database connected successfully');
    
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();