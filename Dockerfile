FROM golang:1.21-buster as builder

ARG NERDCTL_VERSION=v1.7.5

ENV NERDCTL_VERSION=${NERDCTL_VERSION}
ENV GOPROXY=https://goproxy.io

ARG WORKDIR=/opt/nerdctl

RUN set -ex; \
    git clone -b ${NERDCTL_VERSION} --depth=1 https://github.com/containerd/nerdctl ${WORKDIR}

WORKDIR ${WORKDIR}

ADD Makefile.patch /opt/Makefile.patch

RUN set -ex; \
    git apply /opt/Makefile.patch; \
    sed -i 's@github.com/cilium/ebpf v0.9.1@github.com/cilium/ebpf v0.12.3@g' go.mod; \
    go mod tidy

RUN set -ex; \
    make artifacts ; \
    ( cd _output; sha256sum nerdctl-* ) | tee /tmp/SHA256SUMS ; \
    mv /tmp/SHA256SUMS ${WORKDIR}/_output/SHA256SUMS

FROM debian:buster-slim

WORKDIR /opt/nerdctl

COPY --from=builder /opt/nerdctl/_output /opt/nerdctl/dist

VOLUME /dist

CMD cp -rf dist/* /dist/