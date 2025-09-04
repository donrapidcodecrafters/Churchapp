CREATE TABLE notes (
  id SERIAL PRIMARY KEY,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE songs (
  id SERIAL PRIMARY KEY,
  title TEXT,
  lyrics TEXT,
  sheet_music TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE services (
  id SERIAL PRIMARY KEY,
  title TEXT,
  date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE service_songs (
  id SERIAL PRIMARY KEY,
  service_id INT REFERENCES services(id),
  song_id INT REFERENCES songs(id),
  position INT
);

-- Pastor Notes table for live-editable sermon notes
CREATE TABLE IF NOT EXISTS pastor_notes (
  id SERIAL PRIMARY KEY,
  service_id INT REFERENCES services(id),
  content TEXT,
  display_time INT DEFAULT 10,
  position INT DEFAULT 1
);
