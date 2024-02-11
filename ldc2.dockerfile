FROM opensuse/leap AS builder

WORKDIR /home

RUN zypper update -y
RUN zypper install -y gcc13 gcc13-32bit gcc13-c++ gcc13-c++-32bit libcurl4-32bit curl python3-base tar xz git cmake ninja libconfig++-devel zlib-devel zlib-devel-32bit libxml2-2-32bit libxml2-devel libxml2-devel-32bit

RUN curl -O https://downloads.dlang.org/releases/2024/dmd-2.106.1-0.openSUSE.x86_64.rpm

# dmd package looks for gcc and gcc-32bit as dependencies, use --nodeps to ignore
RUN rpm --nodeps -i dmd-2.106.1-0.openSUSE.x86_64.rpm

# download and install llvm
RUN curl -OL https://github.com/ldc-developers/llvm-project/releases/download/ldc-v17.0.6/llvm-17.0.6-linux-x86_64.tar.xz
RUN tar -xf llvm-17.0.6-linux-x86_64.tar.xz && cp -r ./llvm-17.0.6-linux-x86_64/* /usr

# dmd looks for cc when running cmake
RUN ln -s /usr/bin/gcc-13 /usr/bin/cc

# clone ldc repo, build, and install
RUN git clone --recursive https://github.com/ldc-developers/ldc.git
RUN mkdir build-ldc install-ldc
WORKDIR /home/ldc
RUN git checkout tags/v1.36.0 -b v1.36.0
WORKDIR /home/build-ldc
RUN cmake -G Ninja ../ldc -DCMAKE_C_COMPILER=/usr/bin/gcc-13 -DCMAKE_CXX_COMPILER=/usr/bin/g++-13 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PWD/../install-ldc
RUN ninja && ninja install


FROM opensuse/leap

RUN zypper update -y && zypper install -y gcc13 gcc13-32bit libcurl4-32bit curl neovim make gdb

# ldc2 looks for cc when compiling
RUN ln -s /usr/bin/gcc-13 /usr/bin/cc

COPY --from=builder /home/install-ldc /usr
COPY ldc2.conf /usr/etc/
