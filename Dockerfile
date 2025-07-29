FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SWIFTLINT_VERSION=0.57.1
ENV SWIFT_VERSION=6.0.2
ENV SWIFT_BUILD_TARGET=ubuntu2204
ENV UBUNTU_VERSION=22.04
ENV SWIFT_FLAGS="-c release -Xswiftc -static-stdlib -Xlinker -lCFURLSessionInterface -Xlinker -lCFXMLInterface -Xlinker -lcurl -Xlinker -lxml2 -Xswiftc -I. -Xlinker -fuse-ld=lld -Xlinker -L/usr/lib/swift/linux"

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    binutils \
    git \
    wget \
    curl \
    tzdata \
    ca-certificates \
    gnupg2 \
    libcurl4 \
    libedit2 \
    libsqlite3-0 \
    libxml2 \
    zlib1g-dev \
    pkg-config \
    libpython3.8 \
    libstdc++-9-dev \
    libgcc-9-dev \
    libz3-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    python3-lldb-13 \
    && rm -rf /var/lib/apt/lists/*

# Install Swift
WORKDIR /opt
RUN wget https://swift.org/builds/swift-${SWIFT_VERSION}-release/${SWIFT_BUILD_TARGET}/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu${UBUNTU_VERSION}.tar.gz && \
    mkdir /swift && \
    tar xzf swift-${SWIFT_VERSION}-RELEASE-ubuntu${UBUNTU_VERSION}.tar.gz --strip 1 -C /swift && \
    cp -r /swift/usr/* /usr/local && \
    rm -rf /swift swift-${SWIFT_VERSION}-RELEASE-ubuntu${UBUNTU_VERSION}.tar.gz

# Install SwiftLint
WORKDIR /opt
RUN git clone --branch ${SWIFTLINT_VERSION} --depth 1 https://github.com/realm/SwiftLint.git
WORKDIR /opt/SwiftLint
RUN swift package update && \
    swift build $SWIFT_FLAGS --product swiftlint && \
    install -v $(swift build $SWIFT_FLAGS --show-bin-path)/swiftlint /usr/local/bin

# Cleanup
WORKDIR /
RUN rm -rf /opt/SwiftLint && \
    swiftlint version

# Default work directory
WORKDIR /workspace
