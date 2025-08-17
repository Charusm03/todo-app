## 📝 To-Do App
This To-Do App helps users manage daily tasks with ease. It allows you to sign up or log in, add, update, delete, and mark tasks as completed, with secure authentication.

A simple To-Do List application built with:
Frontend: Flutter
Backend: Express.js (Node.js)
Database: MySQL

### 🚀 Features
User Authentication (Login)
Add new tasks
Update existing tasks
Delete tasks
Mark tasks as completed
Logout functionality

### 🛠️ Tech Stack
Frontend: Flutter (Dart)

Backend: Express.js (Node.js)

Database: MySQL

Authentication: JWT

### 📂 Project Structure
todo-app/

├── backend/         # Express.js backend

├── frontend/        # Flutter frontend

└── README.md

### ⚙️ Setup Instructions
1️⃣ Clone the repository
```
git clone https://github.com/your-username/todo-app.git
cd todo-app
```

2️⃣ Backend Setup (Express + MySQL)
Navigate to the backend folder:
```
cd backend
npm install
```
Create a .env file in backend/ with the following (update with your values):
```
Import the database:
Create a MySQL database:
CREATE DATABASE todo_db;
Run migrations or import the provided SQL file (if you created one).
```

Start the backend server:
```
node server
```
Server runs on http://localhost:3000.

3️⃣ Frontend Setup (Flutter)
Navigate to the frontend folder:
```
cd frontend
```

Get Flutter dependencies:
```
flutter pub get
```
Update the API base URL in your Flutter project (where you call your backend) to match your backend (e.g., http://10.0.2.2:3000 for Android Emulator, or http://localhost:3000 for web/desktop).

Run the Flutter app:
```
flutter run
```
