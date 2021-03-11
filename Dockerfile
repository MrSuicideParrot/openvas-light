FROM debian:10

ARG BUILD_DATE
ARG VERSION
ARG OPENVAS_VERSION
ARG GVM_LIBS_VERSION
ARG GOCROND_VERSION
ARG ARCH


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
        wget \
        rsync \
	    nmap \ 
        gnutls-bin &&\
    cd /tmp &&\
    echo "Installing GVM Libraries" &&\
        wget https://github.com/greenbone/gvm-libs/archive/v${GVM_LIBS_VERSION}.tar.gz &&\
        tar -xvzf v${GVM_LIBS_VERSION}.tar.gz &&\
        cd gvm-libs-${GVM_LIBS_VERSION} &&\
        cmake . &&\
        make install &&\
        cd .. &&\
        ldconfig &&\
        rm v${GVM_LIBS_VERSION}.tar.gz &&\
    echo "Installing OpenVAS scanner" &&\
	wget https://github.com/greenbone/openvas-scanner/archive/v${OPENVAS_VERSION}.tar.gz &&\
  	tar -xvzf v${OPENVAS_VERSION}.tar.gz &&\
        cd openvas-scanner-${OPENVAS_VERSION} &&\
        cmake . &&\
        make install &&\
        cd .. &&\  
        ldconfig &&\
    echo "Installing ospd-openvas" &&\
        pip3 install ospd-openvas &&\
    echo "Configuring redis server" &&\
        mkdir -p /run/redis-openvas &&\
        cp openvas-scanner-${OPENVAS_VERSION}/config/redis-openvas.conf /etc/redis &&\
        chown redis:redis /etc/redis/redis-openvas.conf &&\
        echo "db_address = /run/redis-openvas/redis.sock" > /usr/local/etc/openvas/openvas.conf &&\
    echo "Installig go-crond" &&\
        wget -O /usr/local/bin/go-crond https://github.com/webdevops/go-crond/releases/download/$GOCROND_VERSION/go-crond-$ARCH-linux &&\
        chmod +x /usr/local/bin/go-crond &&\
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
COPY scripts/gvm-manage-certs /usr/local/bin/

VOLUME /usr/local/var/lib/openvas/plugins
VOLUME /usr/var/lib/gvm

ENV PORT 5149

ENTRYPOINT start-openvas
