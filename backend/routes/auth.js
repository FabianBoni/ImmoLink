const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { MongoClient } = require('mongodb');
const { dbUri, dbName } = require('../config');

router.post('/register', async (req, res) => {
  if (!dbUri) {
    return res.status(500).json({ message: 'Database configuration missing' });
  }

  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    const users = db.collection('users');
    
    // Check if user already exists
    const existingUser = await users.findOne({ email: req.body.email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already registered' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(req.body.password, salt);

    // Create new user document
    const newUser = {
      email: req.body.email,
      password: hashedPassword,
      fullName: req.body.fullName,
      birthDate: new Date(req.body.birthDate),
      role: req.body.role,
      isAdmin: false,
      isValidated: false,
      address: {
        street: '',
        city: '',
        postalCode: '',
        country: ''
      },
      createdAt: new Date()
    };

    // Insert user into database
    const result = await users.insertOne(newUser);
    
    // Return success response
    res.status(201).json({
      message: 'User registered successfully',
      userId: result.insertedId
    });

  } catch (error) {
    res.status(500).json({ message: 'Registration failed', error: error.message });
  } finally {
    await client.close();
  }
});

// Add login endpoint
router.post('/login', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    const users = db.collection('users');
    
    // Find user by email
    const user = await users.findOne({ email: req.body.email });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Verify password
    const validPassword = await bcrypt.compare(req.body.password, user.password);
    if (!validPassword) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Create session or token
    const sessionData = {
      userId: user._id,
      email: user.email,
      role: user.role,
      fullName: user.fullName
    };

    res.status(200).json({
      message: 'Login successful',
      user: sessionData
    });

  } catch (error) {
    res.status(500).json({ message: 'Login failed', error: error.message });
  } finally {
    await client.close();
  }
});

module.exports = router;