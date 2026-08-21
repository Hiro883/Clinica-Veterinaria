FROM mysql:8.0

ENV MYSQL_DATABASE=clinica_veterinaria \
    MYSQL_ROOT_PASSWORD=root_password \
    MYSQL_USER=vet_user \
    MYSQL_PASSWORD=vet_password

COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306