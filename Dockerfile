ARG BUILD_FROM=mcr.microsoft.com/mssql/server:2019-latest
FROM ${BUILD_FROM} AS builder

ARG SA_PASSWORD
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=${SA_PASSWORD}

USER root

COPY data.sql      /var/opt/mssql/docker/data.sql
COPY restore_db.sh /var/opt/mssql/docker/restore_db.sh
COPY entrypoint.sh /entrypoint.sh

RUN tr -d '\r' < /var/opt/mssql/docker/restore_db.sh > /tmp/restore_db.sh \
    && mv /tmp/restore_db.sh /var/opt/mssql/docker/restore_db.sh \
    && tr -d '\r' < /entrypoint.sh > /tmp/entrypoint.sh \
    && mv /tmp/entrypoint.sh /entrypoint.sh \
    && chmod +x /var/opt/mssql/docker/restore_db.sh \
    && chmod +x /entrypoint.sh

RUN mkdir -p /opt/mssql-tools/bin \
    && printf '#!/bin/bash\n/opt/mssql-tools18/bin/sqlcmd -No "$@"\n' > /opt/mssql-tools/bin/sqlcmd \
    && chmod +x /opt/mssql-tools/bin/sqlcmd

RUN /entrypoint.sh & \
    bash /var/opt/mssql/docker/restore_db.sh && \
    rm /var/opt/mssql/docker/restore_db.sh

HEALTHCHECK --interval=10s --timeout=5s --start-period=60s --retries=10 \
    CMD /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "${SA_PASSWORD}" -No -Q "SELECT 1" || exit 1

ENTRYPOINT ["/entrypoint.sh"]