FROM ubuntu:22.04

# Install git
RUN apt-get update
RUN apt-get -y install git

# As dev
RUN adduser dev
USER dev

WORKDIR /home/dev

WORKDIR /home/dev/grpc
RUN git clone --recurse-submodules -b v1.66.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc



# Cmake and build deps
USER root
RUN apt-get -y install cmake build-essential autoconf libtool pkg-config



ARG NATIVE_GRPC_INSTALL_DIR=/home/dev/local_native_grpc
ARG THREADS=16


# Build grpc
# Note: this build is under user root, sadly
WORKDIR /home/dev/grpc/grpc
RUN mkdir -p build/cmake/native \
    && cd build/cmake/native \
    && cmake -DgRPC_INSTALL=ON \
             -DgRPC_BUILD_TESTS=OFF \
             -DCMAKE_INSTALL_PREFIX=${NATIVE_GRPC_INSTALL_DIR} \
             ../../.. \
    && make -j ${THREADS}

RUN cd build/cmake/native && make install

# Patch the build that was done
RUN chown -R dev:dev build \
    && chown -R dev:dev ${NATIVE_GRPC_INSTALL_DIR}


# Install cross compiler
RUN apt-get install -y g++-aarch64-linux-gnu

USER dev

# get the toolchain cmake file
COPY aarch64-toolchain.cmake /home/dev/
