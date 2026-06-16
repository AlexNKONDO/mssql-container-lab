# Question 3 — Docker / MSSQL Image

We want our own SQL Server image in our private registry.

**Task**
Create a `Dockerfile` that builds a SQL Server image with data preloaded.

**Requirements**
- Base image must be configurable:
  - Default: `mcr.microsoft.com/mssql/server:2019-latest`
  - Use an `ARG` like `BUILD_FROM` and `FROM ${BUILD_FROM} as BUILDER`.
- Add a health check that validates the DB is running.
- Restore the database using the provided `restore_db.sh` and `data.sql`.
- The final image should be clean (do not keep `restore_db.sh` in the final layer).
- The container entrypoint must be `entrypoint.sh` (provided).
- Image name must be: `nectari.repository.io/datasources/mssql:{2017|2019}-latest`.
- Do **not** modify the provided script files.

**Expected build command**
```
docker build -t nectari.repository.io/datasources/mssql:2019-latest .
```

**Deliverables**
- `Dockerfile`
- Optional: `docker-compose.yml` showing how to run it
- A short note explaining how you restore the data
