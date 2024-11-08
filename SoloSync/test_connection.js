const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

// Body parser middleware
app.use(bodyParser.json());  // Add this line to handle incoming JSON data

// Database connection
const db = mysql.createConnection({
  host: '3.144.195.16',
  user: 'SoloSync',
  password: 'CSE438S01',
  database: 'SoloSync',
});

db.connect((err) => {
  if (err) {
    console.error('Error connecting to the database:', err.stack);
    return;
  }
  console.log('Connected to the database.');
});

// Insert user route
app.post('/insert', (req, res) => {
  const { username, password, email } = req.body;
  
  const query = 'INSERT INTO UsersInfo (username, password, email) VALUES (?, ?, ?)';
  const values = [username, password, email];

  // Query function
  queryDatabase(query, values)
    .then((result) => {
      res.status(200).json({ message: 'User inserted', result });
    })
    .catch((err) => {
      res.status(500).json({ message: 'Error inserting user', error: err });
    });
});

// Share note
app.post('/share', (req, res) =>{
  const {user_id, coordinate, note, image_url} = req.body;
  const query = 'INSERT INTO Shared (user_id, coordinate ,note, image_url) VALUES (?, ?, ?, ?)' 
  const values = [user_id, coordinate, note, image_url]
  queryDatabase(query, values)
  .then((result) => {
    res.status(200).json({ message: 'Shared successful', result });
  })
  .catch((err) => {
    res.status(500).json({ message: 'Error share note', error: err });
  });
})

// Query function
function queryDatabase(query, values) {
  return new Promise((resolve, reject) => {
    db.query(query, values, (err, result) => {
      if (err) {
        reject(err);
      } else {
        resolve(result);
      }
    });
  });
}

// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});