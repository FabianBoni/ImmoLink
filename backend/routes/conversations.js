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
    
    // Find conversations where user is in the participants array
    const conversations = await db.collection('conversations')
      .find({
        participants: userId
      })
      .sort({ lastMessageTime: -1 })
      .toArray();
    
    // Populate participant names
    const populatedConversations = await Promise.all(
      conversations.map(async (conversation) => {
        // Get other participant (not the current user)
        const otherParticipantId = conversation.participants.find(id => id !== userId);
        
        // Get other participant details
        let otherParticipant = null;
        if (otherParticipantId) {
          try {
            otherParticipant = await db.collection('users')
              .findOne({ _id: new ObjectId(otherParticipantId) });
          } catch (err) {
            console.log(`Could not find user with ID: ${otherParticipantId}`);
          }
        }
        
        return {
          ...conversation,
          otherParticipantId,
          otherParticipantName: otherParticipant ? otherParticipant.fullName : 'Unknown User',
          otherParticipantEmail: otherParticipant ? otherParticipant.email : '',
          otherParticipantRole: otherParticipant ? otherParticipant.role : 'unknown',
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
      participants: [req.body.participants?.[0] || req.body.currentUserId || 'current-user-id', otherUserId],
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
        conversationId: result.insertedId.toString(),
        senderId: conversation.participants[0],
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
    
    // Get participant details
    const participants = await Promise.all(
      conversation.participants.map(async (participantId) => {
        try {
          const user = await db.collection('users')
            .findOne({ _id: new ObjectId(participantId) });
          return user ? {
            id: participantId,
            fullName: user.fullName,
            email: user.email,
            role: user.role
          } : {
            id: participantId,
            fullName: 'Unknown User',
            email: '',
            role: 'unknown'
          };
        } catch (err) {
          return {
            id: participantId,
            fullName: 'Unknown User',
            email: '',
            role: 'unknown'
          };
        }
      })
    );
    
    const populatedConversation = {
      ...conversation,
      participantDetails: participants,
    };
    
    res.json(populatedConversation);
    
  } catch (error) {
    console.error('Error fetching conversation:', error);
    res.status(500).json({ message: 'Error fetching conversation' });
  } finally {
    await client.close();
  }
});

// Update conversation (for last message updates)
router.put('/:conversationId', async (req, res) => {
  const client = new MongoClient(dbUri);
  
  try {
    await client.connect();
    const db = client.db(dbName);
    
    const { conversationId } = req.params;
    const { lastMessage, lastMessageTime } = req.body;
    
    await db.collection('conversations').updateOne(
      { _id: new ObjectId(conversationId) },
      {
        $set: {
          lastMessage,
          lastMessageTime: new Date(lastMessageTime),
          updatedAt: new Date()
        }
      }
    );
    
    res.json({ message: 'Conversation updated successfully' });
  } catch (error) {
    console.error('Error updating conversation:', error);
    res.status(500).json({ message: 'Error updating conversation' });
  } finally {
    await client.close();
  }
});

module.exports = router;
