MUSTER - IFN582 Assessment 3
============================
A Flask + MySQL web application for charity event fundraising.

REQUIREMENTS
- Python 3.10 or newer
- MySQL 8 running locally

SETUP
1. Create and activate a virtual environment (keep it outside the project
   folder, or leave it out of any zip you submit):

     python3 -m venv venv
     source venv/bin/activate          (Windows: venv\Scripts\activate)

2. Install the dependencies:

     pip install -r requirements.txt

3. Create and populate the database (this drops and recreates `muster`):

     mysql -u root -p < project/database.sql

   (Or open project/database.sql in MySQL Workbench and run the whole script.)

4. The app connects as user "root" with an EMPTY password by default. If your
   MySQL root account has a password, either edit the default for
   MYSQL_PASSWORD in project/__init__.py, or set environment variables:

     export MYSQL_USER=root
     export MYSQL_PASSWORD=your_password
     (optional: MYSQL_HOST, MYSQL_DB, MUSTER_SECRET_KEY)

5. Run the application:

     python run.py

   Then open http://127.0.0.1:5000/ in Google Chrome.

TEST LOGINS
The test accounts for each role (Administrator, Fundraiser, Supporter) are
listed on the login page under "Test Login Credentials For Assessment".

PROJECT LAYOUT
run.py                  starts the app
project/__init__.py     application factory, configuration, error handlers
project/views.py        routes
project/models.py       database queries
project/forms.py        WTForms forms
project/decorators.py   role-based access control
project/database.sql    creates and populates the database
project/templates/      Jinja templates (base.html with navbar/footer, one per page)
project/static/         CSS and images
