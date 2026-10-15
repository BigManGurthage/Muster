from flask_login import UserMixin

from . import login_manager, mysql


# Database helpers
def fetch_all(sql, params=None):
    """Run a SELECT and return every row as a list of dicts."""
    cur = mysql.connection.cursor()
    cur.execute(sql, params or ())
    rows = cur.fetchall()
    cur.close()
    return rows


def fetch_one(sql, params=None):
    """Run a SELECT and return the first row as a dict (or None)."""
    cur = mysql.connection.cursor()
    cur.execute(sql, params or ())
    row = cur.fetchone()
    cur.close()
    return row


def execute(sql, params=None):
    """Run an INSERT/UPDATE/DELETE, commit, and return the new row id."""
    cur = mysql.connection.cursor()
    cur.execute(sql, params or ())
    mysql.connection.commit()
    last_id = cur.lastrowid
    cur.close()
    return last_id


# Users and authentication
class User(UserMixin):
    """The logged-in user. `role` is 'admin', 'fundraiser' or 'supporter'."""

    def __init__(self, user_id, username, role):
        self.id = user_id
        self.username = username
        self.role = role


@login_manager.user_loader
def load_user(user_id):
    """Flask-Login calls this on every request with the id kept in the session."""
    row = fetch_one('SELECT user_id, username, role FROM users '
                    'WHERE user_id = %s AND is_active = TRUE', (user_id,))
    if row is None:
        return None
    return User(row['user_id'], row['username'], row['role'])


def get_user_by_username(username):
    """Return the user's full row, or None if the username doesn't exist."""
    return fetch_one('SELECT * FROM users WHERE username = %s', (username,))


def create_user(username, email, password_hash, firstname, surname, role):
    """Insert a new user and return their id. The password must already be hashed."""
    return execute(
        'INSERT INTO users (username, email, password_hash, firstname, surname, role) '
        'VALUES (%s, %s, %s, %s, %s, %s)',
        (username, email, password_hash, firstname, surname, role))


# Home page and search


# Event details and donations


# Campaign management


# Administrator dashboard
