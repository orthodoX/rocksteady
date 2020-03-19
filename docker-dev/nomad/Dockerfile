FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y unzip ca-certificates wget

ENV NOMAD_VERSION 0.10.4
RUN wget "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" \
  -O /tmp/nomad.zip

RUN unzip /tmp/nomad.zip -d /usr/local/bin && \
  chmod 0555 /usr/local/bin/* && \
  rm /tmp/nomad.zip

# We need to be able to communicate with the Docker engine
VOLUME ["/var/run/docker.sock"]

ENTRYPOINT ["/usr/local/bin/nomad"]
CMD ["agent", "--dev", "-bind=0.0.0.0"]
