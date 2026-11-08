# Lab 5 Notes: Peer Tutoring Hub Database

**Student:** Demitri Diamant
**Course:** IS 6465
**Codespaces link:** (https://github.com/DemitriDiamant/lab5)

---

## Part 1: Create the database tables

### .tables and .schema output

```
sqlite> .tables
students           tutoring_requests

sqlite> .schema
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
```

### Which column is the primary key in each table?
In the `students` table, the primary key is `student_id`. In the `tutoring_requests` table, the primary key is `request_id`. Each primary key gives every row its own unique ID number.

### Which column is the foreign key, and what relationship does it represent?
The foreign key is `student_id` in the `tutoring_requests` table, and it references `students(student_id)`. It represents a one to many relationship: one student can submit many tutoring requests, but each request belongs to exactly one student.

### Why is student_email marked UNIQUE?
`student_email` is marked UNIQUE so that two student rows cannot use the same email address. An email identifies one real person, so a duplicate would create confusion about which student record a request belongs to.

---

## Part 2: Insert students and tutoring requests

### INSERT statements used (from tutoring.sql)

```sql
INSERT INTO students (student_name, student_email)
VALUES ('Jordan Lee', 'jordan.lee@example.edu');

INSERT INTO students (student_name, student_email)
VALUES ('Avery Patel', 'avery.patel@example.edu');

INSERT INTO tutoring_requests (student_id, course, topic, preferred_date, preferred_time)
VALUES (1, 'IS 6465', 'Forms', '2026-11-16', '14:00');

INSERT INTO tutoring_requests (student_id, course, topic, preferred_date, preferred_time)
VALUES (1, 'IS 6465', 'SQL SELECT', '2026-11-18', '10:00');

INSERT INTO tutoring_requests (student_id, course, topic, preferred_date, preferred_time)
VALUES (2, 'IS 6465', 'SQLite CRUD', '2026-11-17', '15:30');
```

### SELECT * output for both tables

```
sqlite> SELECT * FROM students;
| student_id | student_name | student_email           |
|------------|--------------|-------------------------|
| 1          | Jordan Lee   | jordan.lee@example.edu  |
| 2          | Avery Patel  | avery.patel@example.edu |

sqlite> SELECT * FROM tutoring_requests;
| request_id | student_id | course  | topic       | preferred_date | preferred_time | status | created_at  |
|------------|------------|---------|-------------|----------------|----------------|--------|-------------|
| 1          | 1          | IS 6465 | Forms       | 2026-11-16     | 14:00          | Open   | 2026-11-08 22:31:29 |
| 2          | 1          | IS 6465 | SQL SELECT  | 2026-11-18     | 10:00          | Open   | 2026-11-08 22:31:29 |
| 3          | 2          | IS 6465 | SQLite CRUD | 2026-11-17     | 15:30          | Open   | 2026-11-08 22:31:29 |
```

### Why does Jordan have one student row but two request rows?
Jordan is one person, so Jordan's name and email are stored only once in the `students` table with `student_id` 1. Each tutoring request is a separate event, so Jordan's two requests are two rows in `tutoring_requests`, and both store `student_id` 1 to point back to Jordan. This avoids repeating Jordan's details and means an email change only has to be made in one place.

---

## Part 3: Read the stored data

### JOIN query

```sql
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
```

### JOIN output

```
| request_id | student_name | student_email           | course  | topic       | preferred_date | preferred_time | status |
|------------|--------------|-------------------------|---------|-------------|----------------|----------------|--------|
| 1          | Jordan Lee   | jordan.lee@example.edu  | IS 6465 | Forms       | 2026-11-16     | 14:00          | Open   |
| 3          | Avery Patel  | avery.patel@example.edu | IS 6465 | SQLite CRUD | 2026-11-17     | 15:30          | Open   |
| 2          | Jordan Lee   | jordan.lee@example.edu  | IS 6465 | SQL SELECT  | 2026-11-18     | 10:00          | Open   |
```

### What does the JOIN condition connect?
The condition `r.student_id = s.student_id` connects each tutoring request to the student row with the same `student_id`. This lets the query show the student's name and email next to each request, even though the request table only stores the ID.

### What is the difference between the purpose of JOIN and WHERE?
JOIN decides which tables are combined and how their rows match up. WHERE filters the results so that only the rows meeting a condition appear, such as `status = 'Open'` or `request_id = 1`.

### Why should the application retrieve one request by request_id instead of by topic alone?
`request_id` is the primary key, so it always matches exactly one request. A topic is not unique, because many students could ask for help with "Forms," so searching by topic could return the wrong request or several requests.

---

## Part 4: Update one request

### The two UPDATE statements

```sql
-- Revise Jordan's request 2
UPDATE tutoring_requests
SET topic = 'SQL JOIN',
    preferred_date = '2026-11-19',
    preferred_time = '11:00'
WHERE request_id = 2;

-- Cancel Avery's request 3
UPDATE tutoring_requests
SET status = 'Cancelled'
WHERE request_id = 3;
```

### Before and after for the revised request

```
BEFORE the update:
| request_id | student_id | course  | topic      | preferred_date | preferred_time | status | created_at  |
|------------|------------|---------|------------|----------------|----------------|--------|-------------|
| 2          | 1          | IS 6465 | SQL SELECT | 2026-11-18     | 10:00          | Open   | 2026-11-08 22:31:29 |

AFTER the update:
| request_id | student_id | course  | topic    | preferred_date | preferred_time | status | created_at  |
|------------|------------|---------|----------|----------------|----------------|--------|-------------|
| 2          | 1          | IS 6465 | SQL JOIN | 2026-11-19     | 11:00          | Open   | 2026-11-08 22:31:29 |
```

### Avery's Cancelled status

```
| request_id | student_name | topic       | status    |
|------------|--------------|-------------|-----------|
| 3          | Avery Patel  | SQLite CRUD | Cancelled |
```

### Why is a specific WHERE clause essential in an UPDATE statement?
The WHERE clause tells SQLite exactly which row to change. Without it, the UPDATE would change every row in the table, so every request would get the new topic, date, time, or status.

### Why does the Peer Tutoring Hub use a Cancelled status instead of immediately deleting a real request?
Changing the status to Cancelled keeps the row in the database, so the Hub keeps a history of what was requested and when. The request still disappears from the list of open requests, but staff can review it later, which a permanent DELETE would make impossible.

---

## Part 5: Delete one test request

### INSERT for the test request

```sql
INSERT INTO tutoring_requests (student_id, course, topic, preferred_date, preferred_time)
VALUES (2, 'IS 6465', 'Delete Practice', '2026-11-20', '09:00');
```

### DELETE statement

```sql
DELETE FROM tutoring_requests
WHERE request_id = 4;
```

### Verification that the test record was removed

```
BEFORE the delete (row 4 is the test record):
| request_id | student_id | course  | topic           | preferred_date | preferred_time | status    | created_at  |
|------------|------------|---------|-----------------|----------------|----------------|-----------|-------------|
| 1          | 1          | IS 6465 | Forms           | 2026-11-16     | 14:00          | Open      | 2026-11-08 22:31:29 |
| 2          | 1          | IS 6465 | SQL JOIN        | 2026-11-19     | 11:00          | Open      | 2026-11-08 22:31:29 |
| 3          | 2          | IS 6465 | SQLite CRUD     | 2026-11-17     | 15:30          | Cancelled | 2026-11-08 22:31:29 |
| 4          | 2          | IS 6465 | Delete Practice | 2026-11-20     | 09:00          | Open      | 2026-11-08 22:31:29 |

AFTER the delete (row 4 is gone, rows 1 to 3 remain):
| request_id | student_id | course  | topic       | preferred_date | preferred_time | status    | created_at  |
|------------|------------|---------|-------------|----------------|----------------|-----------|-------------|
| 1          | 1          | IS 6465 | Forms       | 2026-11-16     | 14:00          | Open      | 2026-11-08 22:31:29 |
| 2          | 1          | IS 6465 | SQL JOIN    | 2026-11-19     | 11:00          | Open      | 2026-11-08 22:31:29 |
| 3          | 2          | IS 6465 | SQLite CRUD | 2026-11-17     | 15:30          | Cancelled | 2026-11-08 22:31:29 |
```

### Why is a WHERE clause essential in a DELETE statement?
Without a WHERE clause, `DELETE FROM tutoring_requests;` removes every row in the table permanently. The WHERE clause limits the delete to the one row with the matching `request_id`, so real requests are not lost.

---

## Part 6: Reflect on the CRUD workflow

| CRUD action | SQL statement used in this lab | Peer Tutoring Hub example |
| --- | --- | --- |
| Create | `INSERT INTO students ...` and `INSERT INTO tutoring_requests ...` | A student submits a new tutoring request |
| Read | `SELECT ... FROM tutoring_requests JOIN students ... ORDER BY preferred_date` | Staff view the list of requests with student names |
| Update | `UPDATE tutoring_requests SET topic = ..., preferred_date = ..., preferred_time = ... WHERE request_id = 2` and `SET status = 'Cancelled' WHERE request_id = 3` | Jordan changes a request; Avery cancels a request |
| Delete | `DELETE FROM tutoring_requests WHERE request_id = 4` | Removing a test record that is not a real request |

### How does the database preserve the connection between a student and that student's requests?
Each row in `tutoring_requests` stores the `student_id` of the student who made it. The foreign key makes sure that `student_id` matches a real row in `students` (when `PRAGMA foreign_keys = ON` is set), so every request stays linked to the correct student.

### Which database constraint prevents two student rows from using the same email address?
The UNIQUE constraint on `student_email` prevents two student rows from using the same email address. If someone tries to insert a duplicate email, SQLite rejects the INSERT.

### What could happen if an UPDATE or DELETE statement did not include a WHERE clause?
The statement would affect every row in the table. An UPDATE could overwrite every request with the same values, and a DELETE could erase all of the requests at once, which would be very hard to undo.

### Why should PHP send form values as parameters instead of placing them directly into SQL text?
If form text is pasted directly into SQL, a user could type SQL code into the form and change what the query does, which is called SQL injection. Prepared statements with parameters send the SQL and the values separately, so the database always treats the typed text as data and never as a command.