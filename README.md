# 🎓 Student Management System

A full-stack web application for managing students, courses, attendance, and results.

![Flutter](https://img.shields.io/badge/Flutter-3.44-blue)
![Node.js](https://img.shields.io/badge/Node.js-18-green)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)
![Firebase](https://img.shields.io/badge/Firebase-Auth-yellow)

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter Web |
| Backend | Node.js + Express |
| Database | MySQL |
| Authentication | Firebase Auth |

---

## ✨ Features

### 👨‍🏫 Admin Panel
- Add, Edit, Delete Students
- Manage Courses (Add/Delete)
- Mark & Delete Attendance
- Add, Edit, Delete Results
- View Reports Dashboard
- Sidebar Navigation

### 👨‍🎓 Student Panel
- View Profile with Logout
- View Attendance Statistics
- View Results & Grades
- View Enrolled Courses
- Tabbed Interface

---

## 🎨 Color Theme

| Color | Hex Code |
|-------|----------|
| Warm Orange | `#FF8C42` |
| Golden Yellow | `#FFB347` |
| Soft Cream | `#FFF8F0` |
| Rich Red | `#D64933` |
| Dark Brown | `#4A2511` |

---

## 🗄️ Database Schema

### Tables
- **Users** - Firebase UID, email, role
- **Students** - Name, Email, Phone, Department, Address
- **Courses** - CourseName, CourseCode, Department, Credits
- **Attendance** - StudentID, CourseID, Date, Status
- **Results** - StudentID, CourseID, Marks, Grade, Semester

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK
- Node.js
- MySQL Server
- Firebase Account

### Backend Setup
```bash
cd backend
npm install
# Update .env with your MySQL credentials
node server.js