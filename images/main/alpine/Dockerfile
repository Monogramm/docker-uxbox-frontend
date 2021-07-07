FROM monogramm/docker-penpot-builder:develop as builder
# TODO Use official devenv as builder
#FROM penpotapp/devenv:latest as builder

ARG PENPOT_VERSION=main
ARG PENPOT_THEME=default

ENV PENPOT_BACKEND_URI=http://penpot-backend:6060 \
    PENPOT_EXPORTER_URI=http://penpot-exporter:6061 \
    TAG=${PENPOT_VERSION}

# Download source from github
ADD https://github.com/penpot/penpot/archive/${PENPOT_VERSION}.tar.gz /tmp/penpot.tar.gz
# or copy frontend from source and build release
#COPY . /home/penpot/penpot-${PENPOT_VERSION}/frontend

WORKDIR /home/penpot

RUN set -ex; \
    tar -xzf /tmp/penpot.tar.gz --strip=1; \
    rm -f /tmp/penpot.tar.gz;

WORKDIR /home/penpot/frontend

RUN set -ex; \
    sed -i -e "s|CURRENT_HASH=.*|CURRENT_HASH=${PENPOT_VERSION}|g" ./scripts/build; \
    export CURRENT_HASH=${PENPOT_VERSION}; \
    ./scripts/build "${PENPOT_VERSION}"


# Once application has been built, prepare production image
FROM nginx:1.21-alpine

ENV LANG=en_US.UTF-8 \
    LC_ALL=C.UTF-8

# Copy built app to www root
COPY --from=builder /home/penpot/frontend/target/dist /var/www/app

# Frontend configurations
COPY ./config.js /var/www/app/js/config.js

# NGINX configurations
COPY ./nginx/conf.d /etc/nginx/conf.d

# Add entrypoint
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["start"]

ARG VERSION=main
ARG VCS_REF
ARG BUILD_DATE

LABEL maintainer="Monogramm Maintainers <opensource at monogramm dot io>" \
    version=$VERSION \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/Monogramm/docker-penpot-frontend" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="PENPOT (frontend) - The Open-Source prototyping tool" \
    org.label-schema.description="The open-source solution for design and prototyping" \
    org.label-schema.url="https://www.penpot.io/" \
    org.label-schema.vendor="PENPOT" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"
