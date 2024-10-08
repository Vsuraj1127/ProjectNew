FROM postgres:latest
ENV POSTGRES_USER=postgres1 POSTGRES_PASSWORD=postgres@123 POSTGRES_DB_NAME=pgdb POSTGRES_PORT= 5432 DB_SSLMODE=disable
EXPOSE 5432
COPY init.sql /docker-entrypoint-initdb.d/
