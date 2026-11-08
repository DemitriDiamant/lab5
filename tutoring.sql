-- =========================================================
-- IS 6465 Lab 5: Build and Query the Peer Tutoring Hub Database
-- How to run (inside the sqlite3 shell):  .read tutoring.sql
-- =========================================================

-- Turn on foreign key checking (SQLite leaves it OFF by default)
PRAGMA foreign_keys = ON;

-- Start fresh each time this file runs, so IDs always come out as 1, 2, 3...
-- (Drop the child table first, because it points to students.)
DROP TABLE IF EXISTS tutoring_requests;
DROP TABLE IF EXISTS students;


-- =========================================================
-- Part 1: Create tables
-- =========================================================

CREATE TABLE students (
    student_id    INTEGER PRIMARY KEY,
    student_name  TEXT NOT NULL,
    student_email TEXT NOT NULL UNIQUE
);

CREATE TABLE tutoring_requests (
    request_id     INTEGER PRIMARY KEY,
    student_id     INTEGER NOT NULL,
    course         TEXT NOT NULL,
    topic          TEXT NOT NULL,
    preferred_date TEXT NOT NULL,
    preferred_time TEXT NOT NULL,
    status         TEXT NOT NULL DEFAULT 'Open',
    created_at     TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);


-- =========================================================
-- Part 2: Insert students and tutoring requests
-- =========================================================

-- Each student is inserted only ONCE
INSERT INTO students (student_name, student_email)
VALUES ('Jordan Lee', 'jordan.lee@example.edu');      -- becomes student_id 1

INSERT INTO students (student_name, student_email)
VALUES ('Avery Patel', 'avery.patel@example.edu');    -- becomes student_id 2

-- Requests use the student's student_id (status and created_at fill in automatically)
INSERT INTO tutoring_requests (student_id, course, topic, preferred_date, preferred_time)
VALUES (1, 'IS 6465', 'Forms', '2026-11-16', '14:00');        -- request_id 1 (Jordan)

INSERT INTO tutoring_requests (student_id, course, topic, preferred_date, preferred_time)
VALUES (1, 'IS 6465', 'SQL SELECT', '2026-11-18', '10:00');   -- request_id 2 (Jordan)

INSERT INTO tutoring_requests (student_id, course, topic, preferred_date, preferred_time)
VALUES (2, 'IS 6465', 'SQLite CRUD', '2026-11-17', '15:30');  -- request_id 3 (Avery)


-- =========================================================
-- Part 3: Read the stored data
-- =========================================================

-- 3a. All rows in students
SELECT * FROM students;

-- 3b. All rows in tutoring_requests
SELECT * FROM tutoring_requests;

-- 3c. Only requests with a status of Open
SELECT * FROM tutoring_requests
WHERE status = 'Open';

-- 3d. One request by its request_id
SELECT * FROM tutoring_requests
WHERE request_id = 1;

-- 3e. JOIN: request list with student info, ordered by preferred_date
SELECT
    r.request_id,
    s.student_name,
    s.student_email,
    r.course,
    r.topic,
    r.preferred_date,
    r.preferred_time,
    r.status
FROM tutoring_requests AS r
JOIN students AS s ON r.student_id = s.student_id
ORDER BY r.preferred_date;


-- =========================================================
-- Part 4: Update one request
-- =========================================================

-- BEFORE: Jordan's request 2
SELECT * FROM tutoring_requests WHERE request_id = 2;

-- Update 1: revise Jordan's request 2 (new topic, date, and time)
UPDATE tutoring_requests
SET topic = 'SQL JOIN',
    preferred_date = '2026-11-19',
    preferred_time = '11:00'
WHERE request_id = 2;

-- AFTER: Jordan's request 2
SELECT * FROM tutoring_requests WHERE request_id = 2;

-- Update 2: cancel Avery's request (request 3)
UPDATE tutoring_requests
SET status = 'Cancelled'
WHERE request_id = 3;

-- Show Avery's Cancelled status
SELECT r.request_id, s.student_name, r.topic, r.status
FROM tutoring_requests AS r
JOIN students AS s ON r.student_id = s.student_id
WHERE r.request_id = 3;


-- =========================================================
-- Part 5: Delete one test request
-- =========================================================

-- Insert a clearly fake test request (becomes request_id 4)
INSERT INTO tutoring_requests (student_id, course, topic, preferred_date, preferred_time)
VALUES (2, 'IS 6465', 'Delete Practice', '2026-11-20', '09:00');

-- BEFORE delete: the test row is there
SELECT * FROM tutoring_requests;

-- Delete ONLY the test request
DELETE FROM tutoring_requests
WHERE request_id = 4;

-- AFTER delete: test row is gone, requests 1-3 remain
SELECT * FROM tutoring_requests;