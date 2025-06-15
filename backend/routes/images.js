const express = require('express');
const multer = require('multer');
const { ObjectId, GridFSBucket } = require('mongodb');
const { getDB } = require('../database');
const router = express.Router();

// Handle preflight OPTIONS requests
router.options('*', (req, res) => {
  res.set({
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Max-Age': '86400',
  });
  res.status(200).end();
});

// Configure multer for memory storage (we'll store in MongoDB)
const storage = multer.memoryStorage();
const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },  fileFilter: function (req, file, cb) {
    console.log('=== Multer fileFilter - File info ===');
    console.log('  Original name:', file.originalname);
    console.log('  Field name:', file.fieldname);
    console.log('  MIME type:', file.mimetype);
    console.log('  Encoding:', file.encoding);
    console.log('  Size:', file.size);
    
    // Allow image files or files with image extensions
    const isImageMimeType = file.mimetype && file.mimetype.startsWith('image/');
    const hasImageExtension = file.originalname && /\.(jpg|jpeg|png|gif|webp|bmp)$/i.test(file.originalname);
    
    console.log('  isImageMimeType:', isImageMimeType);
    console.log('  hasImageExtension:', hasImageExtension);
    
    // Be more permissive - accept if either condition is true OR if no mimetype is provided
    if (isImageMimeType || hasImageExtension || !file.mimetype) {
      console.log('File accepted as image');
      cb(null, true);
    } else {
      console.log('File rejected - not an image');
      cb(new Error(`Only image files are allowed. Received: ${file.mimetype} for ${file.originalname}`), false);
    }
  }
});

// Upload image to MongoDB GridFS
router.post('/upload', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const db = getDB();
    
    // Create GridFS bucket
    const bucket = new GridFSBucket(db, { bucketName: 'property_images' });
    
    // Generate unique filename
    const filename = `${Date.now()}-${req.file.originalname}`;
    
    // Create upload stream
    const uploadStream = bucket.openUploadStream(filename, {
      metadata: {
        originalName: req.file.originalname,
        mimeType: req.file.mimetype,
        uploadDate: new Date()
      }
    });
    
    // Upload the file
    uploadStream.end(req.file.buffer);
    
    uploadStream.on('finish', () => {
      res.json({
        message: 'File uploaded successfully',
        fileId: uploadStream.id.toString(),
        filename: filename,
        url: `/api/images/${uploadStream.id.toString()}`
      });
    });
    
    uploadStream.on('error', (error) => {
      console.error('GridFS upload error:', error);
      res.status(500).json({ message: 'File upload failed', error: error.message });
    });
    
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ message: 'File upload failed', error: error.message });
  }
});

// Get image as Base64 data URL (for Flutter Web)
router.get('/base64/:id', async (req, res) => {
  try {
    // Set CORS headers explicitly
    res.set({
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Content-Type': 'application/json',
    });
    
    const db = getDB();
    
    // Create GridFS bucket
    const bucket = new GridFSBucket(db, { bucketName: 'property_images' });
    
    // Validate ObjectId
    if (!ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: 'Invalid file ID' });
    }
    
    const fileId = new ObjectId(req.params.id);
    
    // Check if file exists
    const files = await bucket.find({ _id: fileId }).toArray();
    if (files.length === 0) {
      return res.status(404).json({ message: 'File not found' });
    }
    
    const file = files[0];
    
    // Read file data into buffer
    const chunks = [];
    const downloadStream = bucket.openDownloadStream(fileId);
    
    downloadStream.on('data', (chunk) => {
      chunks.push(chunk);
    });
    
    downloadStream.on('end', () => {
      const buffer = Buffer.concat(chunks);
      const base64 = buffer.toString('base64');
      const mimeType = file.metadata?.mimeType || 'image/png';
      const dataUrl = `data:${mimeType};base64,${base64}`;
      
      res.json({
        dataUrl: dataUrl,
        filename: file.filename,
        size: file.length,
        mimeType: mimeType
      });
    });
    
    downloadStream.on('error', (error) => {
      console.error('GridFS download error:', error);
      if (!res.headersSent) {
        res.status(500).json({ message: 'Error retrieving file' });
      }
    });
    
  } catch (error) {
    console.error('Base64 image retrieval error:', error);
    if (!res.headersSent) {
      res.status(500).json({ message: 'Error retrieving file' });
    }
  }
});

// Get image from MongoDB GridFS
router.get('/:id', async (req, res) => {
  try {
    // Set CORS headers explicitly for images
    res.set({
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET',
      'Access-Control-Allow-Headers': 'Content-Type',
    });
    
    const db = getDB();
    
    // Create GridFS bucket
    const bucket = new GridFSBucket(db, { bucketName: 'property_images' });
    
    // Validate ObjectId
    if (!ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: 'Invalid file ID' });
    }
    
    const fileId = new ObjectId(req.params.id);
    
    // Check if file exists
    const files = await bucket.find({ _id: fileId }).toArray();
    if (files.length === 0) {
      return res.status(404).json({ message: 'File not found' });
    }
    
    const file = files[0];
    
    // Set appropriate headers
    res.set({
      'Content-Type': file.metadata?.mimeType || 'image/png',
      'Content-Length': file.length,
      'Cache-Control': 'public, max-age=31536000', // Cache for 1 year
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET',
      'Access-Control-Allow-Headers': 'Content-Type',
    });
    
    // Create download stream and pipe to response
    const downloadStream = bucket.openDownloadStream(fileId);
    downloadStream.pipe(res);
    
    downloadStream.on('error', (error) => {
      console.error('GridFS download error:', error);
      if (!res.headersSent) {
        res.status(500).json({ message: 'Error retrieving file' });
      }
    });
    
  } catch (error) {
    console.error('Image retrieval error:', error);
    if (!res.headersSent) {
      res.status(500).json({ message: 'Error retrieving file' });
    }
  }
});

// Delete image from MongoDB GridFS
router.delete('/:id', async (req, res) => {
  try {
    const db = getDB();
    
    // Create GridFS bucket
    const bucket = new GridFSBucket(db, { bucketName: 'property_images' });
    
    // Validate ObjectId
    if (!ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: 'Invalid file ID' });
    }
    
    const fileId = new ObjectId(req.params.id);
    
    // Delete the file
    await bucket.delete(fileId);
    
    res.json({ message: 'File deleted successfully' });
    
  } catch (error) {
    console.error('Image deletion error:', error);
    res.status(500).json({ message: 'Error deleting file' });
  }
});

// List all images (for debugging)
router.get('/', async (req, res) => {
  try {
    const db = getDB();
    
    // Create GridFS bucket
    const bucket = new GridFSBucket(db, { bucketName: 'property_images' });
    
    // Get all files
    const files = await bucket.find({}).toArray();
    
    const fileList = files.map(file => ({
      id: file._id.toString(),
      filename: file.filename,
      length: file.length,
      uploadDate: file.uploadDate,
      metadata: file.metadata
    }));
    
    res.json({ files: fileList });
    
  } catch (error) {
    console.error('Images list error:', error);
    res.status(500).json({ message: 'Error retrieving images list' });
  }
});

module.exports = router;
