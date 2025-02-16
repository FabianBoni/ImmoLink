const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { MongoClient } = require('mongodb');
const { dbUri, dbName } = require('../config');

router.post('/register', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);

    // Create user document matching schema
    const newUser = {
      email: req.body.email,
      password: await bcrypt.hash(req.body.password, 10),
      fullName: req.body.fullName,
      role: req.body.role.toLowerCase(), // Ensure lowercase for enum match
      birthDate: new Date(req.body.birthDate),
      isAdmin: false,
      isValidated: true
    };

    // Log document for verification
    console.log('Attempting to insert user:', newUser);

    const result = await db.collection('users').insertOne(newUser);
    
    res.status(201).json({
      success: true,
      userId: result.insertedId
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ 
      message: 'Registration failed', 
      error: error.message,
      details: error.errInfo 
    });
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