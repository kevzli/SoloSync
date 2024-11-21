const express = require('express');
const bcrypt = require('bcrypt');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');

const crypto = require('crypto');
const SECRET_KEY = crypto.randomBytes(64).toString('hex');
console.log(SECRET_KEY);
const TOKEN_EXPIRATION = '24h';

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

app.post('/insert', async (req, res) => {
  const { username, password, email } = req.body;

  try {
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const query = 'INSERT INTO UsersInfo (username, password, email) VALUES (?, ?, ?)';
    const values = [username, hashedPassword, email];

    queryDatabase(query, values)
      .then((result) => {
        res.status(200).json({ message: 'User inserted', result });
      })
      .catch((err) => {
        if (err.code === 'ER_DUP_ENTRY') {
          res.status(400).json({ message: 'Error: Email already exists' });
        } else {
          res.status(500).json({ message: 'Error inserting user', error: err });
        }
      });
  } catch (error) {
    res.status(500).json({ message: 'Error hashing password', error });
  }
});


app.post('/login', (req, res) => {
  const { email, password } = req.body;
  const query = "SELECT * FROM UsersInfo WHERE email = ?";
  const values = [email];

  queryDatabase(query, values)
    .then((result) => {
      if (result.length === 0) {
        return res.status(400).json({ message: 'User not found' });
      }

      const user = result[0];
      const hashedPassword = user.password;

      bcrypt.compare(password, hashedPassword, (err, isMatch) => {
        if (err) {
          return res.status(500).json({ message: 'Error comparing password', error: err });
        }

        if (isMatch) {
          const token = jwt.sign({ userId: user.id, email: user.email }, SECRET_KEY, { expiresIn: TOKEN_EXPIRATION });

          res.status(200).json({ message: 'Login Success', token, userId: user.id });
        } else {
          res.status(400).json({ message: 'Incorrect password' });
        }
      });
    })
    .catch((err) => {
      res.status(500).json({ message: 'Database query error', error: err });
    });
});

app.post('/update_user', authenticateToken, (req, res) => {
  const { email, newUsername } = req.body;
  const query = "UPDATE UsersInfo SET username = ? WHERE email = ?";
  const values = [newUsername, email];

  queryDatabase(query, values)
    .then((result) => {
      res.status(200).json({ message: 'User updated successfully', result });
    })
    .catch((err) => {
      res.status(500).json({ message: 'Error updating user', error: err });
    });
});


function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }

  jwt.verify(token, SECRET_KEY, (err, user) => {
    if (err) {
      return res.status(403).json({ message: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
}

// Share note
app.post('/share', authenticateToken, (req, res) => {
  const { user_id, coordinate, note, image_url } = req.body;
  let query;
  let values;

  if (image_url === '') {
    // If image_url is empty, insert NULL by not including it in the query
    query = 'INSERT INTO Shared (user_id, coordinate, note) VALUES (?, ?, ?)';
    values = [user_id, coordinate, note];
  } else {
    // Include image_url in the query if it is provided
    query = 'INSERT INTO Shared (user_id, coordinate, note, imageurl) VALUES (?, ?, ?, ?)';
    values = [user_id, coordinate, note, image_url];
  }

  queryDatabase(query, values)
    .then((result) => {
      res.status(200).json({ message: 'Share successful', result });
    })
    .catch((err) => {
      res.status(500).json({ message: 'Error sharing note', error: err });
    });
});

app.post('/get_all_annotations', (req, res) => {
  const query = 'SELECT * FROM Shared';

  queryDatabase(query)
    .then((results) => {
      res.setHeader('Content-Type', 'application/json');
      res.status(200).json(results);
    })
    .catch((err) => {
      res.status(500).json({ message: 'Error retrieving annotations', error: err });
    });
});

app.post('/elete_note', (req, res) => {
  const {note_id, user_id} = req.body;
  const query = 'DELETE FROM Shared WHERE note_id = ? AND user_id = ?';
  values = [note_id, user_id];

  queryDatabase(query, values)
  .then((result) => {
    res.status(200).json({ message: 'Delete note successful', result });
  })
  .catch((err) => {
    res.status(500).json({ message: 'Error delete note', error: err });
  });

});


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