-- Create the "kandula" schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS kandula;

-- Create the "instances_scheduler" table if it doesn't exist
CREATE TABLE IF NOT EXISTS kandula.instances_scheduler (
    instance_id VARCHAR(50) NOT NULL PRIMARY KEY,
    shutdown_time VARCHAR(10)
);

-- Create the "kandula_user" application user if it doesn't already exist
DO $$BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'kandula_user') THEN
        CREATE USER kandula_user WITH PASSWORD '!ytER753';
    END IF;
END$$;

-- Grant SELECT, INSERT, UPDATE, DELETE privileges on all tables in the "kandula" schema to the "kandula_user" application user
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA kandula TO kandula_user;
