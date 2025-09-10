-- init_db.sql

-- Langflow Database and User
CREATE USER langflow WITH PASSWORD 'langflow' SUPERUSER;
CREATE DATABASE langflow OWNER langflow;

-- Create the table 'country_data'.
-- The columns are named based on the headers in your CSV file.
CREATE TABLE country_data (
    country VARCHAR(255) PRIMARY KEY,
    "2020" NUMERIC,
    "2021" NUMERIC,
    "2022" NUMERIC,
    "2023" NUMERIC,
    "2024" NUMERIC,
    "2025" NUMERIC
);

-- 2. Import data from the '2020-2025.csv' file using the COPY command.
-- This command reads the CSV file, ignores the header, and inserts the data
-- into the newly created 'country_data' table.
COPY country_data FROM '/docker-entrypoint-initdb.d/2020-2025.csv' DELIMITER ',' CSV HEADER;
