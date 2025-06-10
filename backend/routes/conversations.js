const express = require('express');
const router = express.Router();
const { MongoClient, ObjectId } = require('mongodb');
const { dbUri, dbName } = require('../config');

// Get all conversations for a user
router.get('/user/:userId', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    
    const userId = req.params.userId;
    
    // Find conversations where user is either landlord or tenant
    const conversations = await db.collection('conversations')
      .find({
        $or: [
          { landlordId: userId },
          { tenantId: userId }
        ]
      })
      .sort({ lastMessageTime: -1 })
      .toArray();
    
    // Populate participant names and property details
    const populatedConversations = await Promise.all(
      conversations.map(async (conversation) => {
        // Get property details
        const property = await db.collection('properties')
          .findOne({ _id: new ObjectId(conversation.propertyId) });
        
        // Get landlord details
        const landlord = await db.collection('users')
          .findOne({ _id: new ObjectId(conversation.landlordId) });
        
        // Get tenant details
        const tenant = await db.collection('users')
          .findOne({ _id: new ObjectId(conversation.tenantId) });
        
        return {
          ...conversation,
          propertyAddress: property ? `${property.address.street}, ${property.address.city}` : 'Unknown Property',
          landlordName: landlord ? landlord.fullName : 'Unknown Landlord',
          tenantName: tenant ? tenant.fullName : 'Unknown Tenant',
        };
      })
    );
    
    console.log(`Found ${populatedConversations.length} conversations for user ${userId}`);
    res.json(populatedConversations);
    
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ message: 'Error fetching conversations' });
  } finally {
    await client.close();
  }
});

// Create a new conversation
router.post('/', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    
    const { otherUserId, initialMessage } = req.body;
    
    // Create conversation document
    const conversation = {
      participants: [req.body.currentUserId || 'temp-user-id', otherUserId],
      lastMessage: initialMessage || 'Chat started',
      lastMessageTime: new Date(),
      unreadCount: 1,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    
    const result = await db.collection('conversations').insertOne(conversation);
    
    // If there's an initial message, add it to messages collection
    if (initialMessage) {
      await db.collection('messages').insertOne({
        conversationId: result.insertedId,
        senderId: req.body.currentUserId || 'temp-user-id',
        receiverId: otherUserId,
        content: initialMessage,
        timestamp: new Date(),
        messageType: 'text',
        isRead: false
      });
    }
    
    res.status(201).json({ 
      conversationId: result.insertedId,
      message: 'Conversation created successfully' 
    });
  } catch (error) {
    console.error('Error creating conversation:', error);
    res.status(500).json({ message: 'Error creating conversation' });
  } finally {
    await client.close();
  }
});

// Get conversation by ID
router.get('/:conversationId', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    
    const conversation = await db.collection('conversations')
      .findOne({ _id: new ObjectId(req.params.conversationId) });
    
    if (!conversation) {
      return res.status(404).json({ message: 'Conversation not found' });
    }
    
    // Get property and user details
    const property = await db.collection('properties')
      .findOne({ _id: new ObjectId(conversation.propertyId) });
    
    const landlord = await db.collection('users')
      .findOne({ _id: new ObjectId(conversation.landlordId) });
    
    const tenant = await db.collection('users')
      .findOne({ _id: new ObjectId(conversation.tenantId) });
    
    const populatedConversation = {
      ...conversation,
      propertyAddress: property ? `${property.address.street}, ${property.address.city}` : 'Unknown Property',
      landlordName: landlord ? landlord.fullName : 'Unknown Landlord',
      tenantName: tenant ? tenant.fullName : 'Unknown Tenant',
    };
    
    res.json(populatedConversation);
    
  } catch (error) {
    console.error('Error fetching conversation:', error);
    res.status(500).json({ message: 'Error fetching conversation' });
  } finally {
    await client.close();
  }
});

module.exports = router;
