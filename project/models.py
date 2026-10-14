"""Database access. All SQL lives in this file and must use parameterised
queries (never build SQL with f-strings or string concatenation).

Add your functions inside your own marked section to avoid merge conflicts.
"""
from flask_login import UserMixin

from . import login_manager, mysql


# Database helpers (shared)

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
    # TODO: look the user up in the users table and return a User.
    return None


# Home page and search


# Event details and donations


# Campaign management


# Administrator dashboard
