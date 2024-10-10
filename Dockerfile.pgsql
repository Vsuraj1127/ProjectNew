FROM postgres:latest

# Set environment variables
ENV POSTGRES_USER=postgres1 \
    POSTGRES_PASSWORD=postgres@123 \
    POSTGRES_DB=pgdb \
    POSTGRES_PORT=5432 \
    DB_SSLMODE=disable

# Expose the PostgreSQL port
EXPOSE 5432

# Copy the initialization SQL script
#COPY init.sql /docker-entrypoint-initdb.d/
