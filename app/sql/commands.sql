psql -h <your_postgres_host> -p <your_postgres_port> -U <your_postgres_username> -c 'CREATE DATABASE kandula'
psql -h <your_postgres_host> -p <your_postgres_port> -U <your_postgres_username> -d kandula -c 'CREATE SCHEMA IF NOT EXISTS kandula_schema'
psql -h <your_postgres_host> -p <your_postgres_port> -U <your_postgres_username> -d kandula -c "CREATE USER kandula_user WITH PASSWORD 'your_password'"
psql -h <your_postgres_host> -p <your_postgres_port> -U <your_postgres_username> -d kandula -c "GRANT USAGE, SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA kandula_schema TO kandula_user"
psql -h <your_postgres_host> -p <your_postgres_port> -U <your_postgres_username> -d kandula -c 'CREATE TABLE kandula_schema.instances_scheduler (
