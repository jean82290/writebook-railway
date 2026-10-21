# Writebook on Railway
# Wraps the official, unmodified Writebook image from 37signals (MIT licence)
# with the few settings Railway needs. Change WRITEBOOK_VERSION to upgrade.
ARG WRITEBOOK_VERSION=1.2.4
FROM ghcr.io/basecamp/writebook:${WRITEBOOK_VERSION}

# Railway mounts volumes as root while Writebook runs as uid 1000.
# The entrypoint starts as root, fixes ownership, then drops to uid 1000 with gosu.
USER root
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y gosu \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

COPY railway/ /railway/
# Writebook sizes its job workers from the host's CPU count, which on Railway
# is the whole machine. This file caps them with JOB_CONCURRENCY instead.
COPY railway/resque-pool.yml /rails/config/resque-pool.yml
RUN chmod 755 /railway/entrypoint.sh

# HTTP_PORT: port Writebook's built-in proxy listens on (Railway routes to PORT).
# WEB_CONCURRENCY / JOB_CONCURRENCY: process counts, kept small to keep the bill small.
ENV HTTP_PORT=8080 \
    PORT=8080 \
    WEB_CONCURRENCY=1 \
    JOB_CONCURRENCY=1 \
    RAILS_MAX_THREADS=3

EXPOSE 8080
ENTRYPOINT ["/railway/entrypoint.sh"]
CMD ["bin/boot"]
