ARG image=public.ecr.aws/ubuntu/ubuntu:22.04

FROM ${image}

WORKDIR /agent-go

RUN apt-get update -y \
    && apt-get install -y software-properties-common \
    && apt update -y \
    && add-apt-repository universe \
    && apt-get install -y build-essential \
        ca-certificates \
        gnupg2 \
        wget \
        git \
        findutils \
        unzip \
        make \
        curl \
        musl-dev \
        cmake


ENV CLANG_VERSION="17"
ENV CXX=clang++-"$CLANG_VERSION"
ENV CC=clang-"$CLANG_VERSION"
RUN wget -O - https://apt.llvm.org/llvm.sh | bash -s ${CLANG_VERSION} \
    && echo "export CXX=clang++-$CLANG_VERSION" >> /root/.bashrc \
    && echo "export CC=clang-$CLANG_VERSION" >> /root/.bashrc

COPY go.mod /tmp/go.mod
# Extract Go version from go.mod
RUN GO_VERSION=$(grep -oPm1 '^go \K([[:digit:].]+)' /tmp/go.mod) && \
    GOARCH=$(uname -m) && if [ "$GOARCH" = "x86_64" ]; then GOARCH=amd64; elif [ "$GOARCH" = "aarch64" ]; then GOARCH=arm64; fi && \
    wget https://golang.org/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz && \
    tar -C /usr/local -xvzf ./go${GO_VERSION}.linux-${GOARCH}.tar.gz && \
    rm -rf ./go${GO_VERSION}.linux-${GOARCH}.tar.gz

# Set Go environment variables
ENV GOPATH="/agent-go"
ENV GOCACHE="$GOPATH/.cache"
ENV GOBIN="$GOPATH/bin"
# not addin GOBIN on purpose, see entrypoint
ENV PATH="/usr/local/go/bin:$PATH"

# gRPC dependencies
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.31.0
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0
RUN go install github.com/jcchavezs/porto/cmd/porto@v0.6.0
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.63.4

RUN                                                                                \
  PB_URL="https://github.com/protocolbuffers/protobuf/releases/download/v24.4/";   \
  PB_FILE="protoc-24.4-linux-x86_64.zip";                                          \
  INSTALL_DIR="/usr/local";                                                        \
                                                                                   \
  wget -nv "$PB_URL/$PB_FILE"                                                       \
    && unzip "$PB_FILE" -d "$INSTALL_DIR" 'bin/*' 'include/*'                      \
    && chmod +xr "$INSTALL_DIR/bin/protoc"                                         \
    && find "$INSTALL_DIR/include" -type d -exec chmod +x {} \;                    \
    && find "$INSTALL_DIR/include" -type f -exec chmod +r {} \;                    \
    && rm "$PB_FILE"

# Append to /etc/profile for login shells
RUN echo 'export PATH="$PATH"' >> /etc/profile

# Create rust related directories in /usr/local
RUN mkdir -p /usr/local/cargo /usr/local/rustup

# Set environment variable before rustup installation
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup

# Install rustup and cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain 1.77

# Add rust related environment variables
RUN echo 'export PATH="/usr/local/cargo/bin:$PATH"' >> /etc/profile     \
    && echo 'export CARGO_HOME="/usr/local/cargo"' >> /etc/profile      \
    && echo 'export RUSTUP_HOME="/usr/local/rustup"' >> /etc/profile

ENV PATH="$PATH:/usr/local/cargo/bin"

# Set mode bits
RUN chmod -R a+w /usr/local/rustup      \
    && chmod -R a+w /usr/local/cargo

WORKDIR /agent

COPY docker-image/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]