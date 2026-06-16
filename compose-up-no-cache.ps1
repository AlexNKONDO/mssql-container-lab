docker compose down
#docker rmi mssql-test:2019
docker build --no-cache -t mssql-test:2019 .
docker compose up -d