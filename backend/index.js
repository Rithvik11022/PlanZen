const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const conn = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',         // your password
  database: 'planzen'   // your DB name
});

// ✅ GET all tasks
app.get('/tasks', (req, res) => {
  conn.query('SELECT * FROM tasks', (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

// ✅ POST a new task
app.post('/tasks', (req, res) => {
  const { title } = req.body;
  conn.query('INSERT INTO tasks (title, is_done) VALUES (?, false)', [title], (err) => {
    if (err) return res.status(500).send(err);
    res.sendStatus(200);
  });
});

// ✅ PUT toggle task done
app.put('/tasks/:id', (req, res) => {
  const { id } = req.params;
  conn.query(
    'UPDATE tasks SET is_done = NOT is_done WHERE id = ?',
    [id],
    (err) => {
      if (err) return res.status(500).send(err);
      res.sendStatus(200);
    }
  );
});

// ✅ DELETE a task
app.delete('/tasks/:id', (req, res) => {
  const { id } = req.params;
  conn.query('DELETE FROM tasks WHERE id = ?', [id], (err) => {
    if (err) return res.status(500).send(err);
    res.sendStatus(200);
  });
});

app.listen(4000, () => {
  console.log('Server running on http://localhost:4000');
});
