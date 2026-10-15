import os

from flask import Flask, render_template
from flask_bootstrap import Bootstrap5
from flask_login import LoginManager
from flask_mysqldb import MySQL
from flask_wtf.csrf import CSRFProtect

# Extensions are created once here and attached to the app inside create_app().
mysql = MySQL()
login_manager = LoginManager()
csrf = CSRFProtect()
bootstrap = Bootstrap5()


def create_app():
    app = Flask(__name__)

    # Defaults work for local development; override with environment variables.
    app.config.from_mapping(
        SECRET_KEY=os.environ.get('MUSTER_SECRET_KEY', 'dev-secret-change-me'),
        MYSQL_HOST=os.environ.get('MYSQL_HOST', 'localhost'),
        MYSQL_USER=os.environ.get('MYSQL_USER', 'root'),
        MYSQL_PASSWORD=os.environ.get('MYSQL_PASSWORD', ''),
        MYSQL_DB=os.environ.get('MYSQL_DB', 'muster'),
        MYSQL_CURSORCLASS='DictCursor',
    )

    mysql.init_app(app)
    csrf.init_app(app)
    bootstrap.init_app(app)

    login_manager.init_app(app)
    login_manager.login_view = 'main.login'
    login_manager.login_message = 'Please log in to access that page.'
    login_manager.login_message_category = 'warning'

    # Imported here because these modules import the extensions defined above.
    from . import models  # noqa: F401
    from .views import bp
    app.register_blueprint(bp)

    register_error_handlers(app)
    return app


def register_error_handlers(app):
    """Application-level handlers: every error renders the shared error.html."""
    errors = {
        400: ('Bad request', 'The request could not be processed. If you were '
                             'submitting a form, please go back and try again.'),
        403: ('Access denied', 'You do not have permission to view this page.'),
        404: ('Page not found', 'Sorry, we could not find the page you were '
                                'looking for.'),
        500: ('Something went wrong', 'An unexpected error occurred on our '
                                      'side. Please try again later.'),
    }

    def make_handler(code, title, message):
        def handler(error):
            return render_template('error.html', code=code, title=title,
                                   message=message), code
        return handler

    for code, (title, message) in errors.items():
        app.register_error_handler(code, make_handler(code, title, message))
