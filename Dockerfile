# Container file for building up autotools versions as used by
# gcc and binutils-gdb. Actual magic is in autoregen.py.

FROM debian:stable-slim

# Run time deps
RUN set -eux; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
      autogen \
      git \
      m4 \
      perl \
      python3; \
    rm -rf /var/lib/apt/lists/*

# Build and install autoconf-2.69 and automake-1.15.1
RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      gzip \
      m4 \
      tar \
      wget \
    ; \
    rm -r /var/lib/apt/lists/*; \
    \
    builddir="$(mktemp -d)"; \
    cd "${builddir}"; \
    \
    wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz; \
    tar xf autoconf-2.69.tar.gz; \
    cd autoconf-2.69; \
    ./configure --program-suffix=-2.69; \
    make; \
    make install; \
    cd .. ;\
    rm -rf autoconf*; \
    cd /usr/local/bin; \
    ln -s autoconf-2.69 autoconf; \
    ln -s autoheader-2.69 autoheader; \
    ln -s autom4te-2.69 autom4te; \
    ln -s autoreconf-2.69 autoreconf; \
    ln -s autoscan-2.69 autoscan; \
    ln -s autoupdate-2.69 autoupdate; \
    \
    cd "${builddir}"; \
    wget https://ftp.gnu.org/gnu/automake/automake-1.15.1.tar.gz; \
    tar xf automake-1.15.1.tar.gz; \
    cd automake-1.15.1; \
    ./configure --program-suffix=-1.15.1; \
    make; \
    make install; \
    cd ..; \
    rm -rf automake*; \
    cd /usr/local/bin; \
    ln -s aclocal-1.15.1 aclocal-1.15; \
    ln -s aclocal-1.15.1 aclocal; \
    ln -s automake-1.15.1 automake-1.15; \
    ln -s automake-1.15.1 automake; \
    \
    rm -rf "${builddir}"; \
    \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# Get and install the autoregen.py script
COPY --chmod=0755 autoregen.py /usr/local/bin/autoregen.py
