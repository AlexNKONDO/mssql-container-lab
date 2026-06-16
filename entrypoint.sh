#!/usr/bin/env bash

echo ""
echo "[Log:::] The password to use is ======>    ${SA_PASSWORD}    <======"
echo ""

echo "[Log:::] Starting the server"
/opt/mssql/bin/sqlservr
