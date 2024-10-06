FROM postgres:latest
ENV POSTGRES_USER=postgres1
ENV POSTGRES_PASSWORD=postgres@123
ENV POSTGRES_DB_NAME=pgdb
COPY init.sql /docker-entrypoint-initdb.d/