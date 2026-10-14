"""Routes. Keep views thin: forms in forms.py, SQL in models.py.

Add your routes inside your own marked section to avoid merge conflicts.
"""
from flask import Blueprint, flash, redirect, render_template, request, url_for
from flask_login import logout_user

from .decorators import role_required

bp = Blueprint('main', __name__)


# Home page and search

@bp.route('/')
def index():
    return render_template('index.html')


@bp.route('/events')
def events():
    # TODO: search/browse results (query string: q, state, category)
    return render_template('events.html')


# Event details and donations

@bp.route('/donations/<int:event_id>')
def donations(event_id):
    return render_template('donations.html')


# Campaign management (fundraisers)

@bp.route('/campaign')
@role_required('fundraiser')
def campaign():
    return render_template('campaign.html')


# Administrator dashboard

@bp.route('/admin_dashboard')
@role_required('admin')
def admin_dashboard():
    return render_template('admin_dashboard.html')


# Authentication

@bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        # TODO: validate credentials and log the user in.
        flash('Login is not implemented yet.', 'info')
    return render_template('login.html')


@bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        # TODO: validate the form and create the account.
        flash('Registration is not implemented yet.', 'info')
    return render_template('register.html')


@bp.route('/logout')
def logout():
    logout_user()
    flash('You have been logged out.', 'success')
    return redirect(url_for('main.index'))
