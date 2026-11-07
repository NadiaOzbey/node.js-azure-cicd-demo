import express from 'express';

const app = express();

// Main endpoint
app.get('/', (req, res) => {
    res.send('Hello from DevOps Demo App!');
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'Healthy'
    });
});

// Application information endpoint
app.get('/info', (req, res) => {
    res.json({
        application: 'DevOps Demo',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development'
    });
});

export default app;