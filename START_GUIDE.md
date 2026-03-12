# Wayfarer Start Setup

There are three main parts to your application: the Database (MongoDB), the User App (Wayfarer), and the Admin Panel (Wayfarer Admin). We also have a Backend API that connects to the database.

## 1. How to start the Database (MongoDB)
The database must be running in the background for logins and trips to save.
1. Open Windows Search and type **Services**.
2. Scroll down to find **MongoDB Server**.
3. Right-click on it and select **Start**.
*(Alternatively, you can open MongoDB Compass and click "Connect" to automatically start the background connection).*

## 2. How to start the Home (User App)
To run just the user app:
1. Open a terminal in the `project2/wayfarer` folder.
2. Run this command:
   ```powershell
   flutter run -d chrome
   ```

## 3. How to start the Admin Panel
To run just the admin dashboard:
1. Open a terminal in the `project2/wayfarer_admin` folder.
2. Run this command:
   ```powershell
   flutter run -d chrome --web-port=5001
   ```
*(We use port 5001 so it doesn't conflict with the User App!)*

---

## 🚀 The Magic Shortcut: Start Everything at Once!
Instead of opening multiple terminals, you can launch the Backend, User App, and Admin Panel all at the same time:
1. Open a single terminal in the main `project2` folder.
2. Run:
   ```powershell
   npm run start
   ```
This uses the `concurrently` package to boot up the Node.js backend alongside both Flutter interfaces simultaneously.
