#!/usr/bin/env bash

echo "[Log:::] Awaiting server bootup"
sleep 50

cd /var/opt/mssql/docker/ || exit

import_data() {
  echo "[Log:::] Attempt to create database and restore data"
  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "${SA_PASSWORD}" -i "data.sql"
}

import_data || (sleep 5 && import_data) || exit 1

echo "[Log:::] Server is up"