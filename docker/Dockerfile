# TLC (the TLA+ model checker) on a Java runtime, so the host needs no Java.
# Built by scripts/docker-java on first use as the image `statechart-tlc:1.7.4`.
FROM eclipse-temurin:21-jre
ADD --checksum=sha256:936a262061c914694dfd669a543be24573c45d5aa0ff20a8b96b23d01e050e88 \
    https://github.com/tlaplus/tlaplus/releases/download/v1.7.4/tla2tools.jar \
    /opt/tla/tla2tools.jar
RUN chmod 0644 /opt/tla/tla2tools.jar
ENV LC_ALL=C.UTF-8 HOME=/tmp
