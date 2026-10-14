"""WTForms definitions. Add your forms inside your own marked section."""
from flask_wtf import FlaskForm  # noqa: F401
from wtforms import (BooleanField, DecimalField, PasswordField,  # noqa: F401
                     SelectField, StringField, SubmitField, TextAreaField)
from wtforms.validators import (DataRequired, Email, EqualTo,  # noqa: F401
                                Length, NumberRange, Optional)


# ===== Authentication =====


# ===== Home page and search =====


# ===== Event details and donations =====


# ===== Campaign management =====


# ===== Administrator dashboard =====
