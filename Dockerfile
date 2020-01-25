FROM debian:10

ARG BUILD_DATE
ARG VERSION
ARG OPENVAS_VERSION
ARG GVM_LIBS_VERSION


RUN apt-get -y update &&\
    apt-get install -y \
        bison \
        cmake \
        gcc \
        libgcrypt20-dev \
        libglib2.0-dev \
        libgnutls28-dev \
        libgpgme-dev \
        libhiredis-dev \
        libksba-dev \
        libldap2-dev \
        libpcap-dev \
        libradcli-dev \
        libsnmp-dev \
        libssh-gcrypt-dev \
        libxml2-dev \
        pkg-config \
        python3-pip \
        redis-server \
        uuid-dev \
        wget &&\
    cd /tmp &&\
    echo "Installing GVM Libraries" &&\
        wget https://github.com/greenbone/gvm-libs/archive/v${GVM_LIBS_VERSION}.tar.gz &&\
        tar -xvzf v${GVM_LIBS_VERSION}.tar.gz &&\
        cd gvm-libs-${GVM_LIBS_VERSION} &&\
        cmake . &&\
        make install &&\
        cd .. &&\
        ldconfig &&\
    echo "Installing OpenVAS scanner" &&\
        wget https://github.com/greenbone/openvas/archive/v${OPENVAS_VERSION}.tar.gz &&\
        tar -xvzf v${OPENVAS_VERSION}.tar.gz &&\
        cd openvas-${OPENVAS_VERSION} &&\
        cmake . &&\
        make install &&\
        cd .. &&\  
        ldconfig &&\
    echo "Installing ospd-openvas" &&\
        pip3 install ospd-openvas &&\
    echo "Configuring redis server" &&\
        mkdir -p /run/redis-openvas &&\
        cp openvas-${OPENVAS_VERSION}/config/redis-openvas.conf /etc/redis &&\
        chown redis:redis /etc/redis/redis-openvas.conf &&\
        echo "db_address = /run/redis-openvas/redis.sock" > /usr/local/etc/openvas/openvas.conf &&\
    echo "Cleaning environment" &&\
        apt-get -y purge gcc cmake python3-pip &&\
        apt-get -y autoremove &&\
        rm -rf \
            /tmp/* \
            /var/lib/apt/lists/* \
            /var/tmp/*

COPY configs/ospd.conf /root/.config/
COPY scripts/greenbone-nvt-sync /usr/local/bin/
COPY scripts/start-openvas /usr/local/bin/

VOLUME /usr/local/var/lib/openvas/plugins

ENTRYPOINT start-openvas


    