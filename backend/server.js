const express = require('express');
const cors = require('cors');
const pool = require('./db');

const app = express();
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// ==================== TEST ENDPOINT ====================
app.get('/api/test', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT 1 as test');
        res.json({ message: 'Database connected!', data: rows });
    } catch (error) {
        console.error('DB Error:', error.message);
        res.status(500).json({ error: error.message });
    }
});

// ==================== USERS ====================
app.post('/api/users/register', async (req, res) => {
    try {
        const { uid, email, role } = req.body;
        const [existing] = await pool.query('SELECT * FROM Users WHERE uid = ?', [uid]);
        if (existing.length > 0) {
            return res.json({ message: 'User already exists', user: existing[0] });
        }
        await pool.query('INSERT INTO Users (uid, email, role) VALUES (?, ?, ?)', [uid, email, role]);
        res.status(201).json({ message: 'User registered', role: role });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/users/:uid', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Users WHERE uid = ?', [req.params.uid]);
        if (rows.length === 0) return res.status(404).json({ message: 'User not found' });
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ==================== STUDENTS ====================
app.get('/api/students', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Students ORDER BY StudentID DESC');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/students/uid/:uid', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Students WHERE uid = ?', [req.params.uid]);
        if (rows.length === 0) return res.status(404).json({ message: 'Student not found' });
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/students/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Students WHERE StudentID = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ message: 'Not found' });
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/students', async (req, res) => {
    try {
        const { Name, Email, Phone, Department, Address, uid } = req.body;
        const [result] = await pool.query(
            'INSERT INTO Students (Name, Email, Phone, Department, Address, uid) VALUES (?, ?, ?, ?, ?, ?)',
            [Name, Email, Phone, Department, Address, uid || null]
        );
        res.status(201).json({ message: 'Student added', id: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/students/:id', async (req, res) => {
    try {
        const { Name, Email, Phone, Department, Address } = req.body;
        await pool.query(
            'UPDATE Students SET Name=?, Email=?, Phone=?, Department=?, Address=? WHERE StudentID=?',
            [Name, Email, Phone, Department, Address, req.params.id]
        );
        res.json({ message: 'Student updated' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/students/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM Students WHERE StudentID = ?', [req.params.id]);
        res.json({ message: 'Student deleted' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ==================== COURSES ====================
app.get('/api/courses', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Courses ORDER BY CourseID DESC');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/courses', async (req, res) => {
    try {
        const { CourseName, CourseCode, Department, Credits } = req.body;
        const [result] = await pool.query(
            'INSERT INTO Courses (CourseName, CourseCode, Department, Credits) VALUES (?, ?, ?, ?)',
            [CourseName, CourseCode, Department, Credits]
        );
        res.status(201).json({ message: 'Course added', id: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/courses/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM Courses WHERE CourseID = ?', [req.params.id]);
        res.json({ message: 'Course deleted' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ==================== ATTENDANCE ====================
app.get('/api/attendance', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT a.*, s.Name as StudentName, c.CourseName 
            FROM Attendance a
            JOIN Students s ON a.StudentID = s.StudentID
            JOIN Courses c ON a.CourseID = c.CourseID
            ORDER BY a.Date DESC
        `);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/attendance/student/:studentId', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT a.*, c.CourseName 
            FROM Attendance a
            JOIN Courses c ON a.CourseID = c.CourseID
            WHERE a.StudentID = ?
            ORDER BY a.Date DESC
        `, [req.params.studentId]);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/attendance', async (req, res) => {
    try {
        const { StudentID, CourseID, Date, Status } = req.body;
        const [result] = await pool.query(
            'INSERT INTO Attendance (StudentID, CourseID, Date, Status) VALUES (?, ?, ?, ?)',
            [StudentID, CourseID, Date, Status]
        );
        res.status(201).json({ message: 'Attendance marked', id: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/attendance/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM Attendance WHERE AttendanceID = ?', [req.params.id]);
        res.json({ message: 'Attendance deleted' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ==================== RESULTS ====================
app.get('/api/results', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT r.*, s.Name as StudentName, c.CourseName 
            FROM Results r
            JOIN Students s ON r.StudentID = s.StudentID
            JOIN Courses c ON r.CourseID = c.CourseID
            ORDER BY r.created_at DESC
        `);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/results/student/:studentId', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT r.*, c.CourseName 
            FROM Results r
            JOIN Courses c ON r.CourseID = c.CourseID
            WHERE r.StudentID = ?
            ORDER BY r.created_at DESC
        `, [req.params.studentId]);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/results', async (req, res) => {
    try {
        const { StudentID, CourseID, Marks, Grade, Semester, ExamType } = req.body;
        const [result] = await pool.query(
            'INSERT INTO Results (StudentID, CourseID, Marks, Grade, Semester, ExamType) VALUES (?, ?, ?, ?, ?, ?)',
            [StudentID, CourseID, Marks, Grade, Semester, ExamType]
        );
        res.status(201).json({ message: 'Result added', id: result.insertId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/results/:id', async (req, res) => {
    try {
        const { StudentID, CourseID, Marks, Grade, Semester, ExamType } = req.body;
        await pool.query(
            'UPDATE Results SET StudentID=?, CourseID=?, Marks=?, Grade=?, Semester=?, ExamType=? WHERE ResultID=?',
            [StudentID, CourseID, Marks, Grade, Semester, ExamType, req.params.id]
        );
        res.json({ message: 'Result updated' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/results/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM Results WHERE ResultID = ?', [req.params.id]);
        res.json({ message: 'Result deleted' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`✅ Server running on http://localhost:${PORT}`);
});