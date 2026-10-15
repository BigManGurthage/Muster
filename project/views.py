from flask import Blueprint, flash, redirect, render_template, request, url_for
from flask_login import current_user, login_user, logout_user
from werkzeug.security import check_password_hash, generate_password_hash

from .decorators import role_required
from .forms import LoginForm, RegisterForm
from .models import create_user, fetch_one, get_user_by_username, User

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


# Campaign management
@bp.route('/campaign')
def campaign():
    if not current_user.is_authenticated:
        flash('Register a Fundraiser account to start fundraising, or log in '
              'if you already have one.', 'info')
        return redirect(url_for('main.register', role='fundraiser'))
    if current_user.role != 'fundraiser':
        flash('Only fundraiser accounts can start fundraising. Log out and '
              'register a Fundraiser account.', 'info')
        return redirect(url_for('main.index'))
    return render_template('campaign.html')


# Administrator dashboard
@bp.route('/admin_dashboard')
@role_required('admin')
def admin_dashboard():
    return render_template('admin_dashboard.html')


# Authentication
@bp.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('main.index'))
    form = LoginForm()
    if form.validate_on_submit():
        row = get_user_by_username(form.username.data.strip())
        if row and check_password_hash(row['password_hash'], form.password.data):
            if not row['is_active']:
                flash('This account has been suspended.', 'danger')
            else:
                login_user(User(row['user_id'], row['username'], row['role']))
                flash('Welcome back, %s!' % row['firstname'], 'success')
                next_page = request.args.get('next', '')
                if next_page.startswith('/') and not next_page.startswith('//'):
                    return redirect(next_page)
                return redirect(url_for('main.index'))
        else:
            flash('Invalid username or password.', 'danger')
    return render_template('login.html', form=form)


@bp.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('main.index'))
    form = RegisterForm()
    if request.method == 'GET' and request.args.get('role') == 'fundraiser':
        form.role.data = 'fundraiser'
    if form.validate_on_submit():
        if get_user_by_username(form.username.data):
            form.username.errors.append('That username is already taken.')
        elif fetch_one('SELECT user_id FROM users WHERE email = %s', (form.email.data,)):
            form.email.errors.append('That email is already registered.')
        else:
            create_user(form.username.data, form.email.data,
                        generate_password_hash(form.password.data),
                        form.firstname.data, form.surname.data, form.role.data)
            flash('Account created. Please log in.', 'success')
            return redirect(url_for('main.login'))
    return render_template('register.html', form=form)


@bp.route('/logout', methods=['GET', 'POST'])
def logout():
    if request.method == 'POST':
        logout_user()
        flash('You have been logged out.', 'success')
    return redirect(url_for('main.index'))
