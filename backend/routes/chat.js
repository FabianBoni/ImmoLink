const express = require('express');
const router = express.Router();
const { MongoClient, ObjectId } = require('mongodb');
const { dbUri, dbName } = require('../config');

// Get messages for a conversation
router.get('/:conversationId/messages', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    const messages = await db
      .collection('messages')
      .find({ conversationId: req.params.conversationId })
      .sort({ timestamp: -1 })
      .toArray();
    
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching messages' });
  } finally {
    await client.close();
  }
});

// Send a new message
router.post('/:conversationId/messages', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    
    const message = {
      ...req.body,
      conversationId: req.params.conversationId,
      timestamp: new Date(),
    };
    
    await db.collection('messages').insertOne(message);
    res.status(201).json({ message: 'Message sent successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Error sending message' });
  } finally {
    await client.close();
  }
});

module.exports = router;
