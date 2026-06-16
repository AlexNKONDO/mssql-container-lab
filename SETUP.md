# Setup

## Prérequis
- Docker Desktop avec BuildKit
- Fichier `.env` à la racine (c'est le password du user sa de sql server):
```
  SA_PASSWORD=VotreMotDePasse123!
```

## Build

SQL Server 2019 :
```powershell
docker build  --no-cache `
  --build-arg SA_PASSWORD=$env:SA_PASSWORD `
  -t nectari.repository.io/datasources/mssql:2019-latest .
```

SQL Server 2017 :
```powershell
docker build  --no-cache `
  --build-arg BUILD_FROM=mcr.microsoft.com/mssql/server:2017-latest `
  -t nectari.repository.io/datasources/mssql:2017-latest .
```

## Run
### Run via docker compose
```powershell
docker compose up -d
```

### Run via docker run
```powershell
docker run -d --name mssql-2019 `
    -e SA_PASSWORD=$env:SA_PASSWORD -e ACCEPT_EULA=Y -p 1433:1433 `
    nectari.repository.io/datasources/mssql:2019-latest
```

## Comment le restore fonctionne

Le restore se fait **au build** en deux étapes parallèles dans un `RUN` :
1. `entrypoint.sh` qui démarre SQL Server en arrière-plan
2. `restore_db.sh` qui attend 50s que SQL Server soit prêt, et exécute `data.sql` via `sqlcmd`
3. `restore_db.sh` est supprimé, car il doit être absent de l'image finale

Au runtime, `entrypoint.sh` redémarre SQL Server qui trouve la base `INTERVIEW_TEST` déjà en place.

## Notes
- `SA_PASSWORD` est injecté via BuildKit secret au build — non visible dans `docker history`
- `restore_db.sh` appelle `/opt/mssql-tools/bin/sqlcmd`, le chemin de SQL Server 2017. Sur 2019, `sqlcmd` est dans `/opt/mssql-tools18/bin/`. Le Dockerfile crée un wrapper transparent dans `/opt/mssql-tools/bin/sqlcmd` qui redirige vers la bonne version.
- Sur Windows, les fichiers `.sh` avaient des fins de ligne CRLF, on corrige ca dans Dockerfile via `tr -d '\r'`
- Le `HEALTHCHECK` vérifie que SQL Server accepte les connexions toutes les 10s après un délai initial de 60s
- Idéalement, `SA_PASSWORD` devrait être injecté via un BuildKit secret (`--mount=type=secret`) pour ne jamais apparaître dans les layers de l'image. Cependant, `restore_db.sh` utilise `${SA_PASSWORD}` comme variable d'environnement directe et ne peut pas être modifié (contrainte de l'exercice). On passe donc par `ARG` + `--build-arg`, ce qui rend la valeur visible dans `docker history --no-trunc`. En production, utiliser un mot de passe de build dédié différent du mot de passe de production.
 