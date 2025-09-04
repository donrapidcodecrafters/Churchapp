const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const multer = require('multer');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(bodyParser.json());
const upload = multer({ dest: 'uploads/' });

// Database
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'churchdb',
  password: 'password',
  port: 5432,
});

app.get('/', (req, res) => res.send('Church App API Running'));

app.post('/songs', async (req, res) => {
  const { title, lyrics } = req.body;
  const result = await pool.query('INSERT INTO songs(title, lyrics) VALUES($1,$2) RETURNING *', [title, lyrics]);
  res.json(result.rows[0]);
});

app.get('/services/:id', async (req, res) => {
  const { id } = req.params;
  const service = await pool.query('SELECT * FROM services WHERE id=$1', [id]);
  const songs = await pool.query('SELECT s.* FROM service_songs ss JOIN songs s ON ss.song_id=s.id WHERE ss.service_id=$1 ORDER BY ss.position', [id]);
  res.json({ service: service.rows[0], songs: songs.rows });
});

// Music OCR upload (stub with Audiveris CLI)
app.post('/music-ocr', upload.single('sheet'), (req, res) => {
  const filePath = req.file.path;
  const outputDir = path.join(__dirname, 'out');
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);
  const cmd = `audiveris -batch -export -output ${outputDir} ${filePath}`;
  exec(cmd, (error, stdout, stderr) => {
    if (error) return res.status(500).json({ error: "OCR failed" });
    const files = fs.readdirSync(outputDir).filter(f => f.endsWith('.xml'));
    if (files.length === 0) return res.status(500).json({ error: "No MusicXML generated" });
    const musicXMLPath = path.join(outputDir, files[0]);
    const musicXML = fs.readFileSync(musicXMLPath, 'utf8');
    res.json({ status: "ok", musicxml: musicXML });
  });
});

app.listen(4000, () => console.log('Server running on port 4000'));

// Serve Chromecast receiver page
const path = require('path');
app.use('/receiver', express.static(path.join(__dirname, 'public')));


// SSE for AirPlay/web fallback
let clients = [];
app.get('/lyrics-stream', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();
  clients.push(res);
  req.on('close', () => {
    clients = clients.filter(c => c !== res);
  });
});

app.post('/push-lyrics', (req, res) => {
  const { lyrics } = req.body;
  clients.forEach(c => c.write(`data: ${lyrics}\n\n`));
  res.json({ status: "ok" });
});


// Pastor Notes endpoints
app.post('/services/:id/notes', async (req, res) => {
  const { id } = req.params;
  const { content, display_time, position } = req.body;
  const result = await pool.query(
    'INSERT INTO pastor_notes(service_id, content, display_time, position) VALUES($1,$2,$3,$4) RETURNING *',
    [id, content, display_time, position]
  );
  res.json(result.rows[0]);
});

app.get('/services/:id/notes', async (req, res) => {
  const { id } = req.params;
  const result = await pool.query(
    'SELECT * FROM pastor_notes WHERE service_id=$1 ORDER BY position',
    [id]
  );
  res.json(result.rows);
});

app.put('/notes/:noteId', async (req, res) => {
  const { noteId } = req.params;
  const { content, display_time, position } = req.body;
  const result = await pool.query(
    'UPDATE pastor_notes SET content=$1, display_time=$2, position=$3 WHERE id=$4 RETURNING *',
    [content, display_time, position, noteId]
  );
  res.json(result.rows[0]);
});

app.delete('/notes/:noteId', async (req, res) => {
  const { noteId } = req.params;
  await pool.query('DELETE FROM pastor_notes WHERE id=$1', [noteId]);
  res.json({ status: "deleted" });
});
