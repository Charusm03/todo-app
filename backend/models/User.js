const { pool } = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
    static async create(userData) {
        const { username, email, password, role = 'employee' } = userData;

        // Hash password
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        const [result] = await pool.execute(
            'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
            [username, email, hashedPassword, role]
        );

        return result.insertId;
    }

    static async findByEmail(email) {
        const [users] = await pool.execute(
            'SELECT * FROM users WHERE email = ?',
            [email]
        );
        return users[0];
    }

    static async findByUsername(username) {
        const [users] = await pool.execute(
            'SELECT * FROM users WHERE username = ?',
            [username]
        );
        return users[0];
    }

    static async findById(id) {
        const [users] = await pool.execute(
            'SELECT id, username, email, role, created_at FROM users WHERE id = ?',
            [id]
        );
        return users[0];
    }

    static async validatePassword(plainPassword, hashedPassword) {
        return await bcrypt.compare(plainPassword, hashedPassword);
    }

    static async getAllUsers() {
        const [users] = await pool.execute(
            'SELECT id, username, email, role, created_at FROM users'
        );
        return users;
    }
}

module.exports = User;