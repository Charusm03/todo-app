const { pool } = require('../config/database');

class Todo {
    static async create(todoData) {
        const { title, description, user_id } = todoData;

        const [result] = await pool.execute(
            'INSERT INTO todos (title, description, user_id) VALUES (?, ?, ?)',
            [title, description, user_id]
        );

        return result.insertId;
    }

    static async findAll() {
        const [todos] = await pool.execute(
            `SELECT t.*, u.username 
             FROM todos t 
             LEFT JOIN users u ON t.user_id = u.id 
             ORDER BY t.created_at DESC`
        );
        return todos;
    }

    static async findByUserId(userId) {
        const [todos] = await pool.execute(
            `SELECT t.*, u.username 
             FROM todos t 
             LEFT JOIN users u ON t.user_id = u.id 
             WHERE t.user_id = ? 
             ORDER BY t.created_at DESC`,
            [userId]
        );
        return todos;
    }

    static async findById(id) {
        const [todos] = await pool.execute(
            `SELECT t.*, u.username 
             FROM todos t 
             LEFT JOIN users u ON t.user_id = u.id 
             WHERE t.id = ?`,
            [id]
        );
        return todos[0];
    }

    static async update(id, updateData) {
        const { title, description, completed } = updateData;

        const [result] = await pool.execute(
            'UPDATE todos SET title = ?, description = ?, completed = ? WHERE id = ?',
            [title, description, completed, id]
        );

        return result.affectedRows > 0;
    }

    static async delete(id) {
        const [result] = await pool.execute(
            'DELETE FROM todos WHERE id = ?',
            [id]
        );

        return result.affectedRows > 0;
    }

    static async toggleComplete(id) {
        const [result] = await pool.execute(
            'UPDATE todos SET completed = NOT completed WHERE id = ?',
            [id]
        );

        return result.affectedRows > 0;
    }
}

module.exports = Todo;