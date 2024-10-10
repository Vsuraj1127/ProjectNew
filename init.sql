DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'pgdb') THEN
        CREATE DATABASE pgdb;
    END IF;
END $$;
