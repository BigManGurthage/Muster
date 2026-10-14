-- Muster database: creates and populates everything the app needs.
-- Run with:  mysql -u root -p < project/database.sql

DROP DATABASE IF EXISTS muster;
CREATE DATABASE muster CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE muster;

-- TODO: tables (parents first), then sample data.
