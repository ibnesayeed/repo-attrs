FROM       debian

RUN        RUN apt update && apt install -y \
               git \
             && rm -rf /var/lib/apt/lists/*

COPY       entrypoint.sh /
RUN        chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
