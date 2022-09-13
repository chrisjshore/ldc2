FROM opensuse/leap AS builder

WORKDIR /home

RUN zypper install -y gcc11 gcc11-32bit gcc11-c++ gcc11-c++-32bit libcurl4-32bit curl python3-base tar xz git cmake ninja libconfig++-devel zlib-devel zlib-devel-32bit libxml2-2-32bit libxml2-devel libxml2-devel-32bit

RUN curl -O https://s3.us-west-2.amazonaws.com/downloads.dlang.org/releases/2021/dmd-2.098.1-0.openSUSE.x86_64.rpm

# dmd package looks for gcc and gcc-32bit as dependencies, use --nodeps to ignore
RUN rpm --nodeps -i dmd-2.098.1-0.openSUSE.x86_64.rpm

# download and install llvm
RUN curl -OL https://github.com/ldc-developers/llvm-project/releases/download/ldc-v13.0.0/llvm-13.0.0-linux-x86_64.tar.xz
RUN tar -xf llvm-13.0.0-linux-x86_64.tar.xz && cp -r ./llvm-13.0.0-linux-x86_64/* /usr

# dmd looks for cc when running cmake
RUN ln -s /usr/bin/gcc-11 /usr/bin/cc

# clone ldc repo, build, and install
RUN git clone --recursive https://github.com/ldc-developers/ldc.git
RUN mkdir build-ldc install-ldc
WORKDIR /home/build-ldc
RUN cmake -G Ninja ../ldc -DCMAKE_C_COMPILER=/usr/bin/gcc-11 -DCMAKE_CXX_COMPILER=/usr/bin/g++-11 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PWD/../install-ldc
RUN ninja && ninja install


FROM opensuse/leap

RUN zypper install -y gcc11 gcc11-32bit libcurl4-32bit curl neovim

# ldc2 looks for cc when compiling
RUN ln -s /usr/bin/gcc-11 /usr/bin/cc

COPY --from=builder /home/install-ldc /usr
COPY ldc2.conf /usr/etc/