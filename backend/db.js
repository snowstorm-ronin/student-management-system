const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'Saumil.22.11.2008.',
    database: 'student_mgmt',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

pool.getConnection()
    .then(conn => {
        console.log('✅ Database connected successfully!');
        conn.release();
    })
    .catch(err => {
        console.error('❌ Database connection failed:', err.message);
    });

module.exports = pool;