DROP DATABASE IF EXISTS muster;

CREATE DATABASE IF NOT EXISTS muster;

USE muster;

CREATE TABLE IF NOT EXISTS organisations(
    organisation_id INT AUTO_INCREMENT PRIMARY KEY,
    org_name VARCHAR(150) NOT NULL UNIQUE,
    abn CHAR(11) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    contact_email VARCHAR(200) NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (abn REGEXP '^[0-9]{11}$'),
    CHECK (contact_email LIKE '%_@%._%')
);

CREATE TABLE IF NOT EXISTS event_categories(
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255) NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS locations(
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    venue_name VARCHAR(150) NOT NULL,
    street_address VARCHAR(200) NOT NULL,
    suburb VARCHAR(120) NOT NULL,
    postcode CHAR(4) NOT NULL,
    state ENUM('ACT', 'NSW', 'NT', 'QLD', 'SA', 'TAS', 'VIC', 'WA') NOT NULL,
    CHECK(postcode REGEXP '^[0-9]{4}$')
);

CREATE TABLE IF NOT EXISTS users(
    user_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
        CHECK (LENGTH(username) >= 3 AND username REGEXP '^[A-Za-z0-9_]+$'),
    email VARCHAR(300) NOT NULL UNIQUE,
        CHECK (email LIKE '%_@%._%'),
    password_hash VARCHAR(300) NOT NULL,
    firstname VARCHAR(80) NOT NULL,
    surname VARCHAR(80) NOT NULL,
    phone VARCHAR(20) NULL,
        CHECK(phone REGEXP '^(Tel:)?[0-9 +()\-]{8,20}$'),
    role ENUM('supporter', 'fundraiser', 'admin') NOT NULL DEFAULT 'supporter',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS administrators(
    user_id INT PRIMARY KEY,
    admin_level ENUM('moderator', 'manager', 'super') NOT NULL DEFAULT 'moderator',
    last_audit_date DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS organisers(
    user_id INT PRIMARY KEY,
    organisation_id INT NOT NULL,
    position_title VARCHAR(100) NOT NULL,
    work_phone VARCHAR(20) NULL
        CHECK (work_phone REGEXP '^(Tel:)?[0-9 +()\-]{8,20}$'),
    FOREIGN KEY(user_id) REFERENCES users(user_id) on DELETE CASCADE,
    FOREIGN KEY(organisation_id) REFERENCES organisations(organisation_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS supporters(
    user_id INT PRIMARY KEY,
    postcode CHAR(4) NULL,
    newsletter_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    CHECK (postcode REGEXP '^[0-9]{4}$'),
    FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS campaigns( 
    campaign_id INT AUTO_INCREMENT PRIMARY KEY, 
    fundraiser_id INT NOT NULL, 
    organisation_id INT NOT NULL, 
    category VARCHAR(50) NOT NULL, 
    location_id INT NOT NULL, 
    approved_by INT NULL, 
    approved_at DATETIME NULL, 
    title VARCHAR(200) NOT NULL, 
    description TEXT NOT NULL, 
    charity_name VARCHAR(100) NOT NULL, 
    goal_amount DECIMAL(12,2) NOT NULL, 
        CHECK(goal_amount > 0), 
    event_date DATE NOT NULL, 
    start_time TIME NULL, 
    end_time TIME NULL, 
        CHECK(end_time > start_time), 
    is_online BOOLEAN NOT NULL DEFAULT FALSE, 
    status ENUM('draft', 'pending', 'active','paused', 'completed', 'rejected', 'suspended', 'deleted') NOT NULL DEFAULT 'draft', 
    featured BOOLEAN NOT NULL DEFAULT FALSE, 
    image_filename VARCHAR(255) NOT NULL DEFAULT 'event1.jpg', 
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
        CHECK(featured = 0 OR status = 'active'), 
    FOREIGN KEY (fundraiser_id) REFERENCES organisers(user_id) ON DELETE RESTRICT, 
    FOREIGN KEY (organisation_id) REFERENCES organisations(organisation_id) ON DELETE RESTRICT, 
    FOREIGN KEY (category) REFERENCES event_categories(category_name) ON UPDATE CASCADE ON DELETE RESTRICT, 
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE RESTRICT, 
    FOREIGN KEY (approved_by) REFERENCES administrators(user_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS milestones(
    milestone_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    target_amount DECIMAL(12,2) NOT NULL,
        CHECK (target_amount > 0),
    reward_description VARCHAR(500) NOT NULL DEFAULT '',
    UNIQUE (campaign_id, target_amount),
    FOREIGN KEY(campaign_id) REFERENCES campaigns(campaign_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS match_pledges( 
    pledge_id INT AUTO_INCREMENT PRIMARY KEY, 
    milestone_id INT NOT NULL UNIQUE, 
    sponsor_name VARCHAR(150) NOT NULL, 
    sponsor_email VARCHAR(200) NOT NULL, 
    pledge_amount DECIMAL(12,2) NOT NULL, 
    status ENUM('pending', 'active', 'applied', 'cancelled') NOT NULL DEFAULT 'pending', 
    CHECK (pledge_amount > 0), 
    CHECK (sponsor_email LIKE '%_@_%._%'), 
    FOREIGN KEY (milestone_id) REFERENCES milestones(milestone_id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS teams( 
    team_id INT AUTO_INCREMENT PRIMARY KEY, 
    campaign_id INT NOT NULL, 
    team_name VARCHAR(100) NOT NULL, 
    slogan VARCHAR(200) NOT NULL DEFAULT '', 
    team_goal DECIMAL(12,2) NOT NULL, 
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Team.createdDate 
    CHECK (team_goal > 0), 
    UNIQUE (campaign_id, team_name), 
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS participants( 
    participant_id INT AUTO_INCREMENT PRIMARY KEY, 
    campaign_id INT NOT NULL, 
    supporter_id INT NOT NULL, 
    team_id INT NULL, 
    join_date DATE NOT NULL, 
    personal_goal DECIMAL(12,2) NOT NULL, 
    page_slug VARCHAR(120) NOT NULL UNIQUE, 
    story TEXT NOT NULL, 
    status ENUM('active', 'withdrawn') NOT NULL DEFAULT 'active', 
    CHECK (personal_goal > 0), 
    CHECK (page_slug REGEXP '^[a-z0-9]+(-[a-z0-9]+)*$'), 
    UNIQUE (campaign_id, supporter_id),
    UNIQUE (participant_id, campaign_id), 
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE RESTRICT, 
    FOREIGN KEY (supporter_id) REFERENCES supporters(user_id) ON DELETE RESTRICT, 
    FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE SET NULL
);


CREATE TABLE IF NOT EXISTS interest_registrations( 
    registration_id INT AUTO_INCREMENT PRIMARY KEY, 
    campaign_id INT NOT NULL, 
    supporter_id INT NOT NULL, 
    date_registered DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    status ENUM('registered', 'confirmed', 'cancelled', 'converted') NOT NULL DEFAULT 'registered', 
    notes VARCHAR(500) NOT NULL DEFAULT '', 
    UNIQUE (campaign_id, supporter_id), 
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE RESTRICT, 
    FOREIGN KEY (supporter_id) REFERENCES supporters(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS donations( 
    donation_id INT AUTO_INCREMENT PRIMARY KEY, 
    campaign_id INT NOT NULL,
    participant_id INT NULL, 
    user_id INT NULL, 
    amount DECIMAL(12,2) NOT NULL, 
    message VARCHAR(700) NOT NULL DEFAULT '', 
    anonymous BOOLEAN NOT NULL DEFAULT FALSE, 
    receipt_number VARCHAR(100) UNIQUE, 
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    CHECK (amount > 0), 
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE RESTRICT, 
    FOREIGN KEY (participant_id, campaign_id) REFERENCES participants(participant_id, campaign_id) ON DELETE RESTRICT, 
    FOREIGN KEY (user_id) REFERENCES supporters(user_id) ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS payments( 
    payment_id INT AUTO_INCREMENT PRIMARY KEY, 
    donation_id INT NOT NULL UNIQUE, 
    method ENUM('Credit or debit card', 'PayPal', 'Bank transfer', 'Apple Pay', 'Google Pay') NOT NULL, 
    transaction_ref VARCHAR(100) NOT NULL UNIQUE, 
    status ENUM('pending', 'succeeded', 'failed', 'refunded') NOT NULL DEFAULT 'pending', 
    processed_at DATETIME NULL, 
    CHECK (status = 'pending' OR processed_at IS NOT NULL), 
    FOREIGN KEY (donation_id) REFERENCES donations(donation_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS posts( 
    post_id INT AUTO_INCREMENT PRIMARY KEY, 
    campaign_id INT NOT NULL, 
    title VARCHAR(150) NOT NULL, 
    body TEXT NOT NULL, 
    image_filename VARCHAR(300) NULL, 
    status ENUM('draft', 'published', 'removed') NOT NULL DEFAULT 'draft', 
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    published_at DATETIME NULL, 
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reports( 
    report_id INT AUTO_INCREMENT PRIMARY KEY, 
    campaign_id INT NULL, 
    post_id INT NULL, 
    reported_by INT NULL, 
    reason VARCHAR(255) NOT NULL, 
    status ENUM('open', 'kept', 'removed') NOT NULL DEFAULT 'open', 
    reviewed_by INT NULL, 
    reviewed_at DATETIME NULL, 
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    CHECK ((campaign_id IS NOT NULL AND post_id IS NULL) -- exactly one target 
    OR (campaign_id IS NULL AND post_id IS NOT NULL)), 
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE RESTRICT, 
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE RESTRICT, 
    FOREIGN KEY (reported_by) REFERENCES users(user_id) ON DELETE SET NULL, 
    FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL
);


-- =====================================
--   Sample Data
-- =====================================
INSERT INTO organisations (organisation_id, org_name, abn, description, contact_email, is_verified) VALUES
(1, 'Community Events Collective', '12345678901', 
'A volunteer network that helps local organizers run fundraising events.', 
'hello@cec.example.org', 1),
(2, 'Neighborhood Giving Network', '98765432109', 
'Neighborhood groups organizing bake sales, walks and morning teas for charity.', 
'contact@ngn.example.org', 1);

INSERT INTO event_categories (category_id, category_name, description) VALUES
(1, 'Morning Tea', 'Tea, coffee and homemade food shared with the community.'),
(2, 'Walk or run', 'Walking or running events with sponsored participants.'),
(3, 'Bake Sale', 'Stalls selling home-baked goods.'),
(4, 'Head shave', 'Participants shave their heads to raise funds.');

INSERT INTO locations (location_id, venue_name, street_address, suburb, postcode, state) VALUES
(1, 'Coorparoo Community Hall', '12 Hall Street', 'Coorparoo', '4151', 'QLD'),
(2, 'Riverside Park Entrance', '1 River Terrace', 'West End', '4101', 'QLD'),
(3, 'Ipswich Depot Staff Room', '40 Depot Road', 'Ipswich', '4305', 'QLD'),
(4, 'Esplanade Market Stalls', '25 Esplanade', 'Cairns', '4870', 'QLD'),
(5, 'Balmain Town Square', '3 Darling Street', 'Balmain', '2041', 'NSW'),
(6, 'Melbourne Neighborhood Hall', '88 Collins Lane', 'Melbourne', '3000', 'VIC'),
(7, 'Swan River Foreshore', '2 Riverside Drive', 'Perth', '6000', 'WA'),
(8, 'Courtyard Cafe Garden', '15 Rundle Lane', 'Adelaide', '5000', 'SA'),
(9, 'Hobart Primary School Hall', '7 School Road', 'Hobart', '7000', 'TAS'),
(10, 'Lake Shore Path', '1 Lakeside Avenue', 'Canberra', '2601', 'ACT'),
(11, 'Darwin Community Centre', '10 Smith Street', 'Darwin', '0800', 'NT'),
(12, 'Toowoomba Showgrounds Pavilion','50 Show Road', 'Toowoomba', '4350', 'QLD'),
(13, 'Newcastle Foreshore Markets', '5 Wharf Road', 'Newcastle', '2300', 'NSW'),
(14, 'Geelong School Library', '21 Learning Street', 'Geelong', '3220', 'VIC'),
(15, 'Fremantle Esplanade Stage', '9 Marine Terrace', 'Fremantle', '6160', 'WA');

INSERT INTO users (user_id, username, email, password_hash, firstname, surname, phone, role) VALUES
(1, 'supporter1', 'supporter1@example.com', 'scrypt:32768:8:1$YfUzlCuIF2Jookgq$7e93c441b9a36179c7fbf069244269fbe03306b539d4515b97110119b2bac5b04020b025693cca2264839ab4a98549fc9530baa08810043fdad35fe15376ee27', 
'Alex', 'Supporter', '0491 570 156', 'supporter'),
(2, 'supporter2', 'supporter2@example.com', 
'scrypt:32768:8:1$UjyFWI7pref0o2jO$37ebf1166d8a68addd40a1a9786fd5089d96482a5c29ceb03ee9e6f6502f1efafc85fec9eedd2162ebe0e7f2b833554eafd1c4b074ade09fcdf11ae58b315865', 
'Sam', 'Supporter', '0491 570 157', 'supporter'),
(3, 'fundraiser1', 'fundraiser1@example.com', 'scrypt:32768:8:1$2leiebh9g3x7gLm8$39ae04106a16102003e78e2df1693dcd9c5f135dcee5c6cb8554b90a98f262d251a83607c6333b049af3e7a1decbd2ecf6a22044d0d37e3b3ef561deac20415d', 
'Jamie', 'Organiser', '0491 570 158', 'fundraiser'),
(4, 'fundraiser2', 'fundraiser2@example.com', 
'scrypt:32768:8:1$kJAzzbzZ4t6TvdNr$3d1ef7c19f135626b6a527ec377f605a2f61c345d95740d12e5bb6d81512369bbae7e87801ba67950c3019ca00233a3167d27962524d9d465d962e1b5667595a', 
'Taylor', 'Organiser', '0491 570 159', 'fundraiser'),
(5, 'admin1', 'admin1@example.com', 'scrypt:32768:8:1$80eGOwxAVGMs5CMq$3a695e06152fee6b903ae7c7dbc517d0299abfb5f8b02667fd4bd9cd5a6b4c1a87ebc067828eb084dd9ff33860fcd8c2dd14f4c6057631b0dd968a70f4377d30', 
'Morgan', 'Administrator', NULL, 'admin'),
(6, 'admin2', 'admin2@example.com', 
'scrypt:32768:8:1$HQJh8uz6GwC8XLWC$74a451995c28e4dfcf2e90065b1990c38a184c2dcea42b5f7123dec79cad90a52457b38cb8dc8443d75188bd7d9cdd0e02380418b3472df56c13276453982584', 
'Jordan', 'Administrator', NULL, 'admin');

INSERT INTO administrators (user_id, admin_level, last_audit_date) VALUES
(5, 'super', DATE_SUB(NOW(), INTERVAL 7 DAY)),
(6, 'moderator', NULL);

INSERT INTO organisers (user_id, organisation_id, position_title, work_phone) VALUES
(3, 1, 'Event Coordinator', '07 5550 1234'),
(4, 2, 'Community Organizer', '02 5550 5678');

INSERT INTO supporters (user_id, postcode, newsletter_opt_in) VALUES
(1, '4151', 1),
(2, '4101', 0);

INSERT INTO campaigns ( 
campaign_id, fundraiser_id, organisation_id, category, location_id, 
approved_by, approved_at, 
title, description, charity_name,
goal_amount, event_date, start_time, end_time, is_online, 
status, featured, image_filename
)VALUES

(1, 3, 1, 'Morning Tea', 1, 5, DATE_SUB(NOW(), INTERVAL 10 DAY), 
'Coorparoo Biggest Morning Tea', 
'A community morning tea with cakes and a raffle.', 
'Cancer Council Queensland', 
8000.00, DATE_ADD(CURDATE(), INTERVAL 3 DAY), '10:00', '12:00', 0, 
'active', 1, 'event1.jpg'),

(2, 4, 2, 'Walk or run', 2, 5, DATE_SUB(NOW(), INTERVAL 12 DAY), 
'Riverside Twilight Walk', 
'Walk along the river and support mental health services.', 
'Beyond Blue', 
25000.00, DATE_ADD(CURDATE(), INTERVAL 5 DAY), '17:30', '19:30', 0, 
'active', 1, 'event2.jpg'),

(3, 3, 1, 'Head shave', 3, 6, DATE_SUB(NOW(), INTERVAL 9 DAY), 
'Shave the Shift', 
'Our workplace team is taking on a head shave challenge.', 
'Leukaemia Foundation', 
10000.00, DATE_ADD(CURDATE(), INTERVAL 7 DAY), '12:00', '14:00', 0, 
'active', 0, 'event3.jpg'),

(4, 4, 2, 'Bake Sale', 4, 6, DATE_SUB(NOW(), INTERVAL 8 DAY), 
'Great Northern Bake Sale', 
'Local bakers share their favorite recipes for a community fundraiser.', 
'Foodbank Australia', 
6000.00, DATE_ADD(CURDATE(), INTERVAL 14 DAY), '08:00', '12:00', 0, 
'active', 0, 'event4.jpg'),

(5, 4, 2, 'Bake Sale', 5, NULL, NULL, 
'Bakers of Balmain', 
'A weekend bake sale proposed by our neighborhood group.', 
'OzHarvest', 
3500.00, DATE_ADD(CURDATE(), INTERVAL 18 DAY), '09:00', '13:00', 0, 
'pending', 0, 'event4.jpg'),
(6, 3, 1, 'Bake Sale', 6, 5, DATE_SUB(NOW(), INTERVAL 6 DAY), 
'Melbourne Community Bake Sale', 
'Bring homemade cakes and share an afternoon with neighbours.', 
'Beyond Blue', 
5000.00, DATE_ADD(CURDATE(), INTERVAL 21 DAY), '13:00', '16:00', 0, 
'active', 0, 'event4.jpg'),

(7, 4, 2, 'Walk or run', 7, 5, DATE_SUB(NOW(), INTERVAL 5 DAY), 
'Perth River Walk', 
'Our walking club is raising funds with a supervised community walk.', 
'Cancer Council WA', 
12000.00, DATE_ADD(CURDATE(), INTERVAL 30 DAY), '07:00', '09:00', 0, 
'active', 0, 'event2.jpg'),

(8, 3, 1, 'Morning Tea', 8, 6, DATE_SUB(NOW(), INTERVAL 15 DAY), 
'Adelaide Courtyard Tea', 
'This afternoon tea is paused while organizers confirm the venue.', 
'Foodbank SA', 
4000.00, DATE_ADD(CURDATE(), INTERVAL 24 DAY), '14:00', '16:00', 0, 
'paused', 0, 'event1.jpg'),

(9, 4, 2, 'Morning Tea', 9, 5, DATE_SUB(NOW(), INTERVAL 4 DAY), 
'Hobart School Morning Tea', 
'Families are organizing a school morning tea with homemade treats.', 
'Australian Red Cross', 
7000.00, DATE_ADD(CURDATE(), INTERVAL 28 DAY), '10:00', '11:30', 0, 
'active', 0, 'event1.jpg'),

(10, 3, 1, 'Walk or run', 10, NULL, NULL, 
'Canberra Charity Walk', 
'A proposed walking event waiting for administrator approval.', 
'Rural Aid', 
9000.00, DATE_ADD(CURDATE(), INTERVAL 35 DAY), '08:00', '10:00', 0, 
'pending', 0, 'event2.jpg'),

(11, 4, 2, 'Morning Tea', 11, 6, DATE_SUB(NOW(), INTERVAL 3 DAY), 
'Darwin Community Morning Tea', 
'Neighbors gather for tea and homemade treats.', 
'Australian Red Cross', 
3000.00, DATE_ADD(CURDATE(), INTERVAL 16 DAY), '09:30', '11:30', 0, 
'active', 0, 'event1.jpg'),

(12, 3, 1, 'Head shave', 12, 5, DATE_SUB(NOW(), INTERVAL 20 DAY), 
'Toowoomba Shave for a Cure', 
'Registrations are paused while the team reschedules activities.', 
'Leukaemia Foundation', 
6000.00, DATE_ADD(CURDATE(), INTERVAL 12 DAY), '11:00', '13:00', 0, 
'paused', 0, 'event3.jpg'),

(13, 4, 2, 'Bake Sale', 13, 6, DATE_SUB(NOW(), INTERVAL 40 DAY), 
'Newcastle Community Bake Sale', 
'Thank you to everyone who attended our completed bake sale.', 
'OzHarvest', 
4500.00, DATE_SUB(CURDATE(), INTERVAL 14 DAY), '09:00', '13:00', 0, 
'completed', 0, 'event4.jpg'),

(14, 3, 1, 'Morning Tea', 14, NULL, NULL, 
'Geelong School Morning Tea', 
'An early draft of a school community morning tea.', 
'Foodbank Victoria', 
5500.00, DATE_ADD(CURDATE(), INTERVAL 42 DAY), '10:00', '12:00', 0, 
'draft', 0, 'event1.jpg'),

(15, 4, 2, 'Head shave', 15, NULL, NULL, 
'Fremantle Head Shave Fundraiser', 
'This proposal needs revised details before it can be approved.', 
'Cancer Council WA', 
11000.00, DATE_ADD(CURDATE(), INTERVAL 40 DAY), '12:00', '14:00', 0, 
'rejected', 0, 'event3.jpg');

INSERT INTO milestones (milestone_id, campaign_id, title, target_amount, reward_description) VALUES
(1, 1, 'Halfway there', 4000.00, 'Organisers will add a second raffle prize.'),
(2, 1, 'Goal reached', 8000.00, 'Every donor receives a handwritten thank-you card.'),
(3, 2, 'First $10,000', 10000.00, 'A local sponsor matches the next round of donations.'),
(4, 3, 'Halfway there', 5000.00, 'The team leader dyes their hair pink before the shave.');

INSERT INTO match_pledges (pledge_id, milestone_id, sponsor_name, sponsor_email, pledge_amount, status) VALUES
(1, 3, 'Riverside Physio', 'sponsor@riversidephysio.example.com', 2000.00, 'active'),
(2, 2, 'Coorparoo Bakery', 'orders@coorparoobakery.example.com', 1000.00, 'pending');

INSERT INTO teams (team_id, campaign_id, team_name, slogan, team_goal) VALUES
(1, 2, 'River Striders', 'One step at a time', 5000.00),
(2, 3, 'Night Shift Crew', 'Bald is brave', 4000.00);

INSERT INTO participants (participant_id, campaign_id, supporter_id, team_id, join_date, personal_goal, page_slug, story, status) VALUES
(1, 3, 1, 2, DATE_SUB(CURDATE(), INTERVAL 6 DAY), 1500.00, 'alex-shave-the-shift', 
'I am shaving my head for my aunt, who was supported by the Leukaemia Foundation.', 'active'),
(2, 2, 2, 1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 1000.00, 'sam-riverside-walk', 
'Walking for better mental health support in our community.', 'active'),
(3, 2, 1, 1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 500.00, 'alex-riverside-walk', 
'Joining my friends for the twilight walk.', 'active');

INSERT INTO interest_registrations (registration_id, campaign_id, supporter_id, status, notes) VALUES
(1, 7, 2, 'registered', 'Interested in walking with a friend.'),
(2, 9, 1, 'confirmed', 'Can bring a plate of scones.'),
(3, 4, 1, 'cancelled', 'Away that weekend.');

INSERT INTO donations ( 
donation_id, campaign_id, participant_id, user_id, 
amount, message, anonymous, receipt_number
)VALUES
(1, 1, NULL, 1, 250.00, 'For our community.', 0, 'DEMO-MUSTER-001'),
(2, 1, NULL, 2, 75.00, 'Go the school bakers!', 0, 'DEMO-MUSTER-002'),
(3, 1, NULL, 1, 500.00, 'With best wishes.', 1, 'DEMO-MUSTER-003'),
(4, 2, 2, 1, 50.00, 'Enjoy the walk.', 0, 'DEMO-MUSTER-004'),
(5, 2, 3, 2, 125.00, '', 1, 'DEMO-MUSTER-005'),
(6, 3, 1, 2, 100.00, 'Good luck to the team.', 0, 'DEMO-MUSTER-006'),
(7, 4, NULL, 1, 25.00, 'Looking forward to the cakes.', 0, 'DEMO-MUSTER-007'),
(8, 6, NULL, 2, 80.00, 'Enjoy the bake sale.', 0, 'DEMO-MUSTER-008'),
(9, 7, NULL, 1, 150.00, 'A great challenge.', 0, 'DEMO-MUSTER-009'),
(10, 9, NULL, 2, 200.00, 'Good luck with the morning tea.', 0, 'DEMO-MUSTER-010'),
(11, 3, 1, NULL, 60.00, 'From your colleagues at the depot.', 0, 'DEMO-MUSTER-011');

INSERT INTO payments (payment_id, donation_id, method, transaction_ref, status, processed_at) VALUES
(1, 1, 'Credit or debit card', 'TXN-DEMO-0001', 'succeeded', NOW()),
(2, 2, 'Apple Pay', 'TXN-DEMO-0002', 'succeeded', NOW()),
(3, 3, 'Bank transfer', 'TXN-DEMO-0003', 'succeeded', NOW()),
(4, 4, 'PayPal', 'TXN-DEMO-0004', 'succeeded', NOW()),
(5, 5, 'Google Pay', 'TXN-DEMO-0005', 'succeeded', NOW()),
(6, 6, 'Credit or debit card', 'TXN-DEMO-0006', 'succeeded', NOW()),
(7, 7, 'PayPal', 'TXN-DEMO-0007', 'succeeded', NOW()),
(8, 8, 'Apple Pay', 'TXN-DEMO-0008', 'succeeded', NOW()),
(9, 9, 'Google Pay', 'TXN-DEMO-0009', 'succeeded', NOW()),
(10, 10, 'Bank transfer', 'TXN-DEMO-0010', 'pending', NULL),
(11, 11, 'Credit or debit card', 'TXN-DEMO-0011', 'succeeded', NOW());

INSERT INTO posts (post_id, campaign_id, title, body, image_filename, status, published_at) VALUES
(1, 1, 'Morning tea preparations are under way', 
'Our volunteers have confirmed the cake stalls and raffle table. Thank you to everyone helping with the event.', 
'event1.jpg', 'published', CURRENT_TIMESTAMP),
(2, 2, 'Walking route and meeting point confirmed', 
'The group will meet at the park entrance before following the riverside route. Please bring water and comfortable walking shoes.', 
'event2.jpg', 'published', CURRENT_TIMESTAMP),
(3, 3, 'The workplace team is ready', 
'Our volunteers are preparing for the head shave challenge. Friends and colleagues are welcome to support the team.', 
NULL, 'published', CURRENT_TIMESTAMP),
(4, 4, 'More bakers welcome', 
'Draft update: confirm stall availability before publishing an invitation for additional bakers.', 
NULL, 'draft', NULL);

INSERT INTO reports (report_id, campaign_id, post_id, reported_by, reason, status) VALUES
(1, 1, NULL, 1, 'Please check whether the event details are accurate.', 'open'),
(2, 7, NULL, 2, 'Please check the charity information displayed on this campaign.', 'open'),
(3, NULL, 2, 1, 'Please review the wording in this public update.', 'open');

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


