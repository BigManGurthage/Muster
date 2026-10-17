from flask_wtf import FlaskForm
from wtforms import (BooleanField, DecimalField, PasswordField,  # noqa: F401
                     SelectField, StringField, SubmitField, TextAreaField)
from wtforms.validators import (DataRequired, Email, EqualTo,  # noqa: F401
                                Length, NumberRange, Optional, Regexp)


# Authentication
class LoginForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Log in')


class RegisterForm(FlaskForm):
    firstname = StringField('First name', validators=[DataRequired(), Length(max=80)])
    surname = StringField('Surname', validators=[DataRequired(), Length(max=80)])
    username = StringField('Username', validators=[
        DataRequired(), Length(min=3, max=50),
        Regexp(r'^[A-Za-z0-9_]+$', message='Letters, numbers and underscores only.')])
    email = StringField('Email', validators=[DataRequired(), Email(), Length(max=300)])
    # Admins are never created through the form.
    role = SelectField('I want to join as', choices=[('supporter', 'Supporter'),
                                                     ('fundraiser', 'Fundraiser')])
    password = PasswordField('Password', validators=[DataRequired(), Length(min=8)])
    confirm = PasswordField('Confirm password', validators=[
        DataRequired(), EqualTo('password', message='Passwords must match.')])
    submit = SubmitField('Create account')


# Home page and search


# Event details and donations


# Campaign management


# Administrator dashboard
