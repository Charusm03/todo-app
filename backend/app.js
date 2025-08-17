// app.js - Create this file if it doesn't exist
const express = require('express');
const cors = require('cors');
const { testConnection } = require('./config/database');

const app = express();

// Enable CORS for all origins during development
app.use(cors({
    origin: '*', // Allow all origins
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// Parse JSON bodies
app.use(express.json());

// Test database connection on startup
testConnection();

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/todos', require('./routes/todos'));

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Server is running',
        timestamp: new Date().toISOString()
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'RBAC Todo API Server',
        endpoints: [
            'POST /api/auth/register',
            'POST /api/auth/login',
            'GET /api/todos',
            'POST /api/todos',
            'PUT /api/todos/:id',
            'DELETE /api/todos/:id'
        ]
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

module.exports = app;
