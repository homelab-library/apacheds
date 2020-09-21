# Build stage
FROM adoptopenjdk:11-jdk-hotspot-bionic as builder

RUN apt-get update && apt-get install -yy curl && \
    mkdir -p /target/apacheds

ENV ADS_VERSION="2.0.0.AM26"
ENV DOWNLOAD_URL="http://apache.mirrors.pair.com//directory/apacheds/dist/${ADS_VERSION}/apacheds-${ADS_VERSION}.tar.gz"

RUN curl -sL "${DOWNLOAD_URL}" | tar xz --strip-components=1 -C /target/apacheds
RUN mv /target/apacheds/instances/default /target/data
RUN rm -rf /target/apacheds/instances

# # Target container
FROM homelabs/base:java11

COPY --from=builder /target/ /
COPY /rootfs/ /

RUN groupadd -g 1000 apacheds && \
    useradd -M -d /apacheds -u 1000 -g 1000 -s /sbin/nologin apacheds && \
    chown -R apacheds:apacheds /apacheds /data && \
    apt-get update && apt-get install -y ldap-utils && \
    rm -rf /var/lib/apt/lists/*

VOLUME [ "/data" ]
EXPOSE 10389 10636 60088 60464 8080 8443
