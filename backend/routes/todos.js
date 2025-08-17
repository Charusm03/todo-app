const express = require('express');
const Todo = require('../models/Todo');
const { authenticateToken, requireRole } = require('../middleware/auth');

const router = express.Router();

// All todo routes require authentication
router.use(authenticateToken);

// Get todos (role-based filtering)
router.get('/', async (req, res) => {
    try {
        let todos;

        if (req.user.role === 'admin') {
            // Admin can see all todos
            todos = await Todo.findAll();
        } else if (req.user.role === 'manager') {
            // Manager can see all todos (but cannot create)
            todos = await Todo.findAll();
        } else {
            // Employee can only see their own todos
            todos = await Todo.findByUserId(req.user.id);
        }

        res.json({ todos });
    } catch (error) {
        console.error('Get todos error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Create todo (Admin only)
router.post('/', requireRole(['admin']), async (req, res) => {
    try {
        const { title, description } = req.body;

        if (!title) {
            return res.status(400).json({ error: 'Title is required' });
        }

        const todoId = await Todo.create({
            title,
            description: description || '',
            user_id: req.user.id
        });

        const todo = await Todo.findById(todoId);
        res.status(201).json({
            message: 'Todo created successfully',
            todo
        });

    } catch (error) {
        console.error('Create todo error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Update todo (Admin and Manager)
router.put('/:id', requireRole(['admin', 'manager']), async (req, res) => {
    try {
        const { id } = req.params;
        const { title, description, completed } = req.body;

        if (!title) {
            return res.status(400).json({ error: 'Title is required' });
        }

        // Check if todo exists
        const existingTodo = await Todo.findById(id);
        if (!existingTodo) {
            return res.status(404).json({ error: 'Todo not found' });
        }

        const success = await Todo.update(id, {
            title,
            description: description || '',
            completed: completed || false
        });

        if (success) {
            const updatedTodo = await Todo.findById(id);
            res.json({
                message: 'Todo updated successfully',
                todo: updatedTodo
            });
        } else {
            res.status(404).json({ error: 'Todo not found' });
        }

    } catch (error) {
        console.error('Update todo error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Toggle todo completion (Admin and Manager)
router.patch('/:id/toggle', requireRole(['admin', 'manager']), async (req, res) => {
    try {
        const { id } = req.params;

        const success = await Todo.toggleComplete(id);

        if (success) {
            const todo = await Todo.findById(id);
            res.json({
                message: 'Todo status updated',
                todo
            });
        } else {
            res.status(404).json({ error: 'Todo not found' });
        }

    } catch (error) {
        console.error('Toggle todo error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Delete todo (Admin and Manager)
router.delete('/:id', requireRole(['admin', 'manager']), async (req, res) => {
    try {
        const { id } = req.params;

        const success = await Todo.delete(id);

        if (success) {
            res.json({ message: 'Todo deleted successfully' });
        } else {
            res.status(404).json({ error: 'Todo not found' });
        }

    } catch (error) {
        console.error('Delete todo error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

module.exports = router;