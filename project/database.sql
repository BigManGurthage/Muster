-- Muster database: creates and populates everything the app needs.
-- Run with:  mysql -u root -p < project/database.sql

DROP DATABASE IF EXISTS muster;
CREATE DATABASE muster CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE muster;

-- TODO: tables (parents first), then sample data.

-----------------------------------------------------------

CREATE DATABASE IF NOT EXISTS muster;

USE muster;

CREATE TABLE IF NOT EXISTS users(
    user_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
        CHECK (LENGTH(username) >= 3 AND username REGEXP '^[A-Za-z0-9_]+$'),
    email VARCHAR(300) NOT NULL UNIQUE,
    password_hash VARCHAR(300) NOT NULL,
    firstname VARCHAR(80) NOT NULL,
    surname VARCHAR(80) NOT NULL,
    role ENUM('supporter', 'fundraiser', 'admin') NOT NULL DEFAULT 'supporter',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS campaigns(
    campaign_id INT AUTO_INCREMENT PRIMARY KEY,
    fundraiser_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    charity_name VARCHAR(100) NOT NULL,
    location VARCHAR(120) NOT NULL,
    state ENUM('ACT', 'NSW', 'NT', 'QLD', 'SA', 'TAS', 'VIC', 'WA') NOT NULL,
    goal_amount DECIMAL(12,2) NOT NULL CHECK(goal_amount > 0),
    event_date DATE NOT NULL,
    status ENUM('draft', 'pending', 'active','paused', 'completed', 'rejected', 'suspended', 'deleted') NOT NULL DEFAULT 'draft',
    category ENUM('Morning Tea', 'Walk or run', 'Bake Sale', 'Head shave') NOT NULL,
    featured BOOLEAN NOT NULL DEFAULT FALSE,
    image_filename VARCHAR(255) NOT NULL DEFAULT 'event1.jpg',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK(featured = 0 OR status = 'active'),
    FOREIGN KEY (fundraiser_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS donations(
    donation_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK(amount > 0),
    message VARCHAR(700) NOT NULL DEFAULT '',
    anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    receipt_number VARCHAR(100) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Credit or debit card', 'Paypel', 'Bank transfer', 'Apple Pay','Google Pay') NOT NULL,
    FOREIGN KEY (campaign_id) REFERENCES campaigns (campaign_id) ON DELETE RESTRICT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS posts(
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    body TEXT NOT NULL,
    image_filename VARCHAR(300) NULL,
    status ENUM(
        'draft', 'published', 'removed'
    ) NOT NULL DEFAULT 'draft',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    published_at DATETIME NULL,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS reports(
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_id INT NULL,
    post_id INT NULL,
    reported_by INT NULL,
    reason VARCHAR(255) NOT NULL,
    status ENUM(
        'open', 'kept', 'removed'
    )NOT NULL DEFAULT 'open',
    reviewed_by INT NULL,
    reviewed_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(campaign_id) REFERENCES campaigns(campaign_id) ON DELETE RESTRICT,
    FOREIGN KEY(post_id) REFERENCES posts(post_id) ON DELETE RESTRICT,
    FOREIGN KEY(reported_by) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY(reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL
);

START TRANSACTION;
 
INSERT INTO users (user_id, username, email, password_hash, firstname, surname, role) VALUES
(1, 'supporter1', 'supporter1@example.com',
 'scrypt:32768:8:1$YfUzlCuIF2Jookgq$7e93c441b9a36179c7fbf069244269fbe03306b539d4515b97110119b2bac5b04020b025693cca2264839ab4a98549fc9530baa08810043fdad35fe15376ee27',
 'Alex', 'Supporter', 'supporter'),
(2, 'supporter2', 'supporter2@example.com',
 'scrypt:32768:8:1$UjyFWI7pref0o2jO$37ebf1166d8a68addd40a1a9786fd5089d96482a5c29ceb03ee9e6f6502f1efafc85fec9eedd2162ebe0e7f2b833554eafd1c4b074ade09fcdf11ae58b315865',
 'Sam', 'Supporter', 'supporter'),
(3, 'fundraiser1', 'fundraiser1@example.com',
 'scrypt:32768:8:1$2leiebh9g3x7gLm8$39ae04106a16102003e78e2df1693dcd9c5f135dcee5c6cb8554b90a98f262d251a83607c6333b049af3e7a1decbd2ecf6a22044d0d37e3b3ef561deac20415d',
 'Jamie', 'Organiser', 'fundraiser'),
(4, 'fundraiser2', 'fundraiser2@example.com',
 'scrypt:32768:8:1$kJAzzbzZ4t6TvdNr$3d1ef7c19f135626b6a527ec377f605a2f61c345d95740d12e5bb6d81512369bbae7e87801ba67950c3019ca00233a3167d27962524d9d465d962e1b5667595a',
 'Taylor', 'Organiser', 'fundraiser'),
(5, 'admin1', 'admin1@example.com',
 'scrypt:32768:8:1$80eGOwxAVGMs5CMq$3a695e06152fee6b903ae7c7dbc517d0299abfb5f8b02667fd4bd9cd5a6b4c1a87ebc067828eb084dd9ff33860fcd8c2dd14f4c6057631b0dd968a70f4377d30',
 'Morgan', 'Administrator', 'admin'),
(6, 'admin2', 'admin2@example.com',
 'scrypt:32768:8:1$HQJh8uz6GwC8XLWC$74a451995c28e4dfcf2e90065b1990c38a184c2dcea42b5f7123dec79cad90a52457b38cb8dc8443d75188bd7d9cdd0e02380418b3472df56c13276453982584',
 'Jordan', 'Administrator', 'admin');


INSERT INTO campaigns (
    campaign_id,
    fundraiser_id,
    title,
    description,
    charity_name,
    location,
    state,
    category,
    goal_amount,
    event_date,
    status,
    featured,
    image_filename
) VALUES

(1, 3, 'Coorparoo Biggest Morning Tea',
 'A community morning tea with cakes and a raffle.',
 'Cancer Council Queensland',
 'Coorparoo', 'QLD', 'Morning tea', 8000.00,
 DATE_ADD(CURDATE(), INTERVAL 3 DAY),
 'active', 1, 'event1.jpg'),

(2, 4, 'Riverside Twilight Walk',
 'Walk along the river and support mental health services.',
 'Beyond Blue',
 'West End', 'QLD', 'Walk or run', 25000.00,
 DATE_ADD(CURDATE(), INTERVAL 5 DAY),
 'active', 1, 'event2.jpg'),

(3, 3, 'Shave the Shift',
 'Our workplace team is taking on a head shave challenge.',
 'Leukaemia Foundation',
 'Ipswich', 'QLD', 'Head shave', 10000.00,
 DATE_ADD(CURDATE(), INTERVAL 7 DAY),
 'active', 0, 'event3.jpg'),

(4, 4, 'Great Northern Bake Sale',
 'Local bakers share their favourite recipes for a community fundraiser.',
 'Foodbank Australia',
 'Cairns', 'QLD', 'Bake Sale', 6000.00,
 DATE_ADD(CURDATE(), INTERVAL 14 DAY),
 'active', 0, 'event4.jpg'),

(5, 4, 'Bakers of Balmain',
 'A weekend bake sale proposed by our neighbourhood group.',
 'OzHarvest',
 'Balmain', 'NSW', 'Bake Sale', 3500.00,
 DATE_ADD(CURDATE(), INTERVAL 18 DAY),
 'pending', 0, 'event4.jpg'),

(6, 3, 'Melbourne Community Bake Sale',
 'Bring homemade cakes and share an afternoon with neighbours.',
 'Beyond Blue',
 'Melbourne', 'VIC', 'Bake Sale', 5000.00,
 DATE_ADD(CURDATE(), INTERVAL 21 DAY),
 'active', 0, 'event4.jpg'),

(7, 4, 'Perth River Walk',
 'Our walking club is raising funds with a supervised community walk.',
 'Cancer Council WA',
 'Perth', 'WA', 'Walk or run', 12000.00,
 DATE_ADD(CURDATE(), INTERVAL 30 DAY),
 'active', 0, 'event2.jpg'),

(8, 3, 'Adelaide Courtyard Tea',
 'This afternoon tea is paused while organisers confirm the venue.',
 'Foodbank SA',
 'Adelaide', 'SA', 'Morning tea', 4000.00,
 DATE_ADD(CURDATE(), INTERVAL 24 DAY),
 'paused', 0, 'event1.jpg'),

(9, 4, 'Hobart School Morning Tea',
 'Families are organising a school morning tea with homemade treats.',
 'Australian Red Cross',
 'Hobart', 'TAS', 'Morning tea', 7000.00,
 DATE_ADD(CURDATE(), INTERVAL 28 DAY),
 'active', 0, 'event1.jpg'),

(10, 3, 'Canberra Charity Walk',
 'A proposed walking event waiting for administrator approval.',
 'Rural Aid',
 'Canberra', 'ACT', 'Walk or run', 9000.00,
 DATE_ADD(CURDATE(), INTERVAL 35 DAY),
 'pending', 0, 'event2.jpg'),

(11, 4, 'Darwin Community Morning Tea',
 'Neighbours gather for tea and homemade treats.',
 'Australian Red Cross',
 'Darwin', 'NT', 'Morning tea', 3000.00,
 DATE_ADD(CURDATE(), INTERVAL 16 DAY),
 'active', 0, 'event1.jpg'),

(12, 3, 'Toowoomba Shave for a Cure',
 'Registrations are paused while the team reschedules activities.',
 'Leukaemia Foundation',
 'Toowoomba', 'QLD', 'Head shave', 6000.00,
 DATE_ADD(CURDATE(), INTERVAL 12 DAY),
 'paused', 0, 'event3.jpg'),

(13, 4, 'Newcastle Community Bake Sale',
 'Thank you to everyone who attended our completed bake sale.',
 'OzHarvest',
 'Newcastle', 'NSW', 'Bake Sale', 4500.00,
 DATE_SUB(CURDATE(), INTERVAL 14 DAY),
 'completed', 0, 'event4.jpg'),

(14, 3, 'Geelong School Morning Tea',
 'An early draft of a school community morning tea.',
 'Foodbank Victoria',
 'Geelong', 'VIC', 'Morning tea', 5500.00,
 DATE_ADD(CURDATE(), INTERVAL 42 DAY),
 'draft', 0, 'event1.jpg'),

(15, 4, 'Fremantle Head Shave Fundraiser',
 'This proposal needs revised details before it can be approved.',
 'Cancer Council WA',
 'Fremantle', 'WA', 'Head shave', 11000.00,
 DATE_ADD(CURDATE(), INTERVAL 40 DAY),
 'rejected', 0, 'event3.jpg');

 INSERT INTO donations (
    donation_id,
    campaign_id,
    user_id,
    amount,
    message,
    anonymous,
    receipt_number,
    payment_method
) VALUES

(1, 1, 1, 250.00,
 'For our community.',
 0, 'DEMO-MUSTER-001', 'Credit or debit card'),

(2, 1, 2, 75.00,
 'Go the school bakers!',
 0, 'DEMO-MUSTER-002', 'Apple Pay'),

(3, 1, 1, 500.00,
 'With best wishes.',
 1, 'DEMO-MUSTER-003', 'Bank transfer'),

(4, 2, 1, 50.00,
 'Enjoy the walk.',
 0, 'DEMO-MUSTER-004', 'PayPal'),

(5, 2, 2, 125.00,
 '',
 1, 'DEMO-MUSTER-005', 'Google Pay'),

(6, 3, 2, 100.00,
 'Good luck to the team.',
 0, 'DEMO-MUSTER-006', 'Credit or debit card'),

(7, 4, 1, 25.00,
 'Looking forward to the cakes.',
 0, 'DEMO-MUSTER-007', 'PayPal'),

(8, 6, 2, 80.00,
 'Enjoy the bake sale.',
 0, 'DEMO-MUSTER-008', 'Apple Pay'),

(9, 7, 1, 150.00,
 'A great challenge.',
 0, 'DEMO-MUSTER-009', 'Google Pay'),

(10, 9, 2, 200.00,
 'Good luck with the morning tea.',
 0, 'DEMO-MUSTER-010', 'Bank transfer');

 INSERT INTO posts (
    post_id,
    campaign_id,
    title,
    body,
    image_filename,
    status,
    published_at
) VALUES

(1, 1, 'Morning tea preparations are under way',
 'Our volunteers have confirmed the cake stalls and raffle table. Thank you to everyone helping with the event.',
 'event1.jpg',
 'published',
 CURRENT_TIMESTAMP),

(2, 2, 'Walking route and meeting point confirmed',
 'The group will meet at the park entrance before following the riverside route. Please bring water and comfortable walking shoes.',
 'event2.jpg',
 'published',
 CURRENT_TIMESTAMP),

(3, 3, 'The workplace team is ready',
 'Our volunteers are preparing for the head shave challenge. Friends and colleagues are welcome to support the team.',
 NULL,
 'published',
 CURRENT_TIMESTAMP),

(4, 4, 'More bakers welcome',
 'Draft update: confirm stall availability before publishing an invitation for additional bakers.',
 NULL,
 'draft',
 NULL);

 INSERT INTO reports (
    report_id,
    campaign_id,
    post_id,
    reported_by,
    reason,
    status
) VALUES

(1, 1, NULL, 1,
 'Please check whether the event details are accurate.',
 'open'),

(2, 7, NULL, 2,
 'Please check the charity information displayed on this campaign.',
 'open'),

(3, NULL, 2, 1,
 'Please review the wording in this public update.',
 'open');
 
COMMIT;

SELECT
    user_id,
    username,
    email,
    firstname,
    surname,
    role,
    is_active
FROM muster.users
ORDER BY user_id;


