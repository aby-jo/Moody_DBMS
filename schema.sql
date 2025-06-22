CREATE TABLE IF NOT EXISTS users(

    id SERIAL,
    name VARCHAR(32) NOT NULL UNIQUE,
    password_hashed VARCHAR(128) NOT NULL,
    PRIMARY KEY (id)

);

CREATE TABLE IF NOT EXISTS moods(
    
    id SERIAL,
    name VARCHAR(12) NOT NULL UNIQUE,
    emoji VARCHAR(16),
    PRIMARY KEY(id)

);

CREATE TABLE IF NOT EXISTS songs(
    
    id SERIAL,
    name VARCHAR(32) NOT NULL,
    artist VARCHAR(32),
    PRIMARY KEY(id)

);

CREATE TABLE IF NOT EXISTS moodentries(
    
    id SERIAL,
    user_id INT NOT NULL,
    mood_id INT NOT NULL,
    song_id INT NOT NULL,
    entry_date DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY(id),
    FOREIGN KEY (user_id) references users(id) ON DELETE CASCADE,
    FOREIGN KEY (mood_id) references moods(id),
    FOREIGN KEY (song_id) references songs(id)

);

CREATE TABLE IF NOT EXISTS playlists(
    
    id SERIAL,
    user_id INT NOT NULL,
    name VARCHAR(32) NOT NULL,
    PRIMARY KEY(id),
    FOREIGN KEY (user_id) references users(id) ON DELETE CASCADE

);

CREATE TABLE IF NOT EXISTS playlistsongs(

    playlist_id INT NOT NULL,
    song_id INT NOT NULL,
    PRIMARY KEY(playlist_id,song_id),
    FOREIGN KEY(playlist_id) references playlists(id) ON DELETE CASCADE,
    FOREIGN KEY(song_id) references songs(id)

);

--Indexes on names for faster lookup using name
CREATE INDEX IF NOT EXISTS username ON users(name);
CREATE INDEX IF NOT EXISTS moodname ON moods(name);
CREATE INDEX IF NOT EXISTS playlistname ON playlists(name);

--Indexes on foreign keys for performance
CREATE INDEX IF NOT EXISTS moodentries_user_id ON moodentries(user_id);
CREATE INDEX IF NOT EXISTS moodentries_song_id ON moodentries(song_id);
CREATE INDEX IF NOT EXISTS moodentries_mood_id ON moodentries(mood_id);
CREATE INDEX IF NOT EXISTS playlists_user_id ON playlists(user_id);
CREATE INDEX IF NOT EXISTS playlistsongs_song_id ON playlistsongs(song_id);
CREATE INDEX IF NOT EXISTS playlistsongs_playlist_id ON playlistsongs(playlist_id);

--View for seeing username,song and its mood
CREATE OR REPLACE VIEW song_mood AS
SELECT users.name as user_name,songs.name AS song_name,moods.name AS mood FROM
songs JOIN moodentries ON song_id=songs.id  join users ON users.id=user_id JOIN moods ON mood_id=moods.id
ORDER BY users.name,moods.name,songs.name;

--Function to return all the songs and playlist of a user by passing the users id as argument
CREATE OR REPLACE FUNCTION getusersongs(IN userId INT) 
RETURNS TABLE (
    song_name VARCHAR,
    playlist_name VARCHAR
) AS
$$
BEGIN
RETURN QUERY
SELECT songs.name AS song_name,playlists.name AS playlist_name FROM
songs JOIN playlistsongs ON song_id=songs.id JOIN playlists ON playlists.id=playlist_id AND user_id=userId
ORDER BY songs.name,playlists.name;
END;
$$
LANGUAGE plpgsql;

