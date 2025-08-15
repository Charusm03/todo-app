const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Database connection
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT
});

// Connect to database
db.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err);
        return;
    }
    console.log('Connected to MySQL database');
});

// JWT middleware
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Access token required' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid token' });
        }
        req.user = user;
        next();
    });
};

// Routes

// Register user
app.post('/api/register', async (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({ error: 'Username and password required' });
        }

        // Check if user exists
        db.query('SELECT * FROM users WHERE username = ?', [username], async (err, results) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (results.length > 0) {
                return res.status(400).json({ error: 'User already exists' });
            }

            // Hash password
            const hashedPassword = await bcrypt.hash(password, 10);

            // Create user
            db.query('INSERT INTO users (username, password) VALUES (?, ?)',
                [username, hashedPassword], (err, results) => {
                    if (err) {
                        return res.status(500).json({ error: 'Failed to create user' });
                    }

                    res.status(201).json({ message: 'User created successfully' });
                });
        });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Login user
app.post('/api/login', (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({ error: 'Username and password required' });
        }

        // Find user
        db.query('SELECT * FROM users WHERE username = ?', [username], async (err, results) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (results.length === 0) {
                return res.status(401).json({ error: 'Invalid credentials' });
            }

            const user = results[0];

            // Check password
            const isValidPassword = await bcrypt.compare(password, user.password);
            if (!isValidPassword) {
                return res.status(401).json({ error: 'Invalid credentials' });
            }

            // Generate JWT token
            const token = jwt.sign(
                { id: user.id, username: user.username },
                process.env.JWT_SECRET,
                { expiresIn: '24h' }
            );

            res.json({ token, user: { id: user.id, username: user.username } });
        });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Get todos
app.get('/api/todos', authenticateToken, (req, res) => {
    db.query('SELECT * FROM todos WHERE user_id = ? ORDER BY created_at DESC',
        [req.user.id], (err, results) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }
            res.json(results);
        });
});

// Create todo
app.post('/api/todos', authenticateToken, (req, res) => {
    const { title, description } = req.body;

    if (!title) {
        return res.status(400).json({ error: 'Title is required' });
    }

    db.query('INSERT INTO todos (user_id, title, description) VALUES (?, ?, ?)',
        [req.user.id, title, description || ''], (err, results) => {
            if (err) {
                return res.status(500).json({ error: 'Failed to create todo' });
            }

            res.status(201).json({
                id: results.insertId,
                title,
                description,
                is_completed: false
            });
        });
});

// Update todo
app.put('/api/todos/:id', authenticateToken, (req, res) => {
    const { id } = req.params;
    const { title, description, is_completed } = req.body;

    db.query(
        'UPDATE todos SET title = ?, description = ?, is_completed = ? WHERE id = ? AND user_id = ?',
        [title, description, is_completed, id, req.user.id],
        (err, results) => {
            if (err) {
                return res.status(500).json({ error: 'Failed to update todo' });
            }

            if (results.affectedRows === 0) {
                return res.status(404).json({ error: 'Todo not found' });
            }

            res.json({ message: 'Todo updated successfully' });
        }
    );
});

// Delete todo
app.delete('/api/todos/:id', authenticateToken, (req, res) => {
    const { id } = req.params;

    db.query('DELETE FROM todos WHERE id = ? AND user_id = ?',
        [id, req.user.id], (err, results) => {
            if (err) {
                return res.status(500).json({ error: 'Failed to delete todo' });
            }

            if (results.affectedRows === 0) {
                return res.status(404).json({ error: 'Todo not found' });
            }

            res.json({ message: 'Todo deleted successfully' });
        });
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'success', message: 'Server is running' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});