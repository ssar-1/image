FROM ubuntu:22.04

ENV SWIFTLINT_VERSION=0.57.1
ENV SWIFT_VERSION=6.0.2
ENV SWIFT_BUILD_TARGET=ubuntu2204
ENV UBUNTU_VERSION=22.04

USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    python3-lldb-13 \
    wget \
    tzdata \
    zlib1g-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    binutils \
    git \
    libc6-dev \
    libcurl4 \
    libedit2 \
    libgcc-9-dev \
    libpython3.8 \
    libsqlite3-0 \
    libstdc++-9-dev \
    libxml2 \
    libz3-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://swift.org/builds/swift-${SWIFT_VERSION}-release/${SWIFT_BUILD_TARGET}/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu${UBUNTU_VERSION}.tar.gz && \
    mkdir /swift && \
    tar xzf swift-${SWIFT_VERSION}-RELEASE-ubuntu${UBUNTU_VERSION}.tar.gz --strip 1 -C /swift && \
    cp -r /swift/usr/* /usr/local && \
    rm swift-${SWIFT_VERSION}-RELEASE-ubuntu${UBUNTU_VERSION}.tar.gz

WORKDIR /opt

RUN git clone https://github.com/realm/SwiftLint.git && \
    cd SwiftLint && \
    git checkout tags/${SWIFTLINT_VERSION}

WORKDIR /opt/SwiftLint
RUN swift package update

ARG SWIFT_FLAGS="-c release -Xswiftc -static-stdlib -Xlinker -lcurl -Xlinker -lxml2 -Xswiftc -I. -Xlinker -fuse-ld=lld -Xlinker -L/usr/lib/swift/linux"
#ARG SWIFT_FLAGS="-c release -Xswiftc -static-stdlib -Xlinker -lCFURLSessionInterface -Xlinker -lCFXMLInterface -Xlinker -lcurl -Xlinker -lxml2 -Xswiftc -I. -Xlinker -fuse-ld=lld -Xlinker -L/usr/lib/swift/linux"
RUN swift build $SWIFT_FLAGS --product swiftlint
RUN install -v `swift build $SWIFT_FLAGS --show-bin-path`/swiftlint /usr/local/bin

WORKDIR /
RUN rm -rf /opt/SwiftLint /swift

RUN swiftlint version

WORKDIR /workspace

# Optional non-root user
# RUN useradd -m swiftuser
# USER swiftuser
