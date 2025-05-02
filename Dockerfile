FROM ubuntu:22.04
WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
        git \
        wget \
        build-essential \
        libtool \
        libtool-bin \
        libpcap-dev \
        texinfo \
        libnuma-dev \
        linux-headers-generic \
        m4 \
        autoconf \
        automake \
        ca-certificates \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz && \
    tar xzvf pkg-config-0.29.2.tar.gz && \
    cd pkg-config-0.29.2 && \
    ./configure --with-internal-glib && \
    make && \
    make install && \
    mv /usr/bin/pkg-config /usr/bin/pkg-config.bak && \
    ln -s /usr/local/bin/pkg-config /usr/bin/pkg-config && \
    cd .. && rm -rf pkg-config-0.29.2*  

ENV PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig

    # Clone the kdns repository
RUN git clone https://github.com/modi2207/kdns.git

WORKDIR /app/kdns

RUN make all


RUN mkdir -p /etc/kdns && \
    cp kdns.cfg /etc/kdns/kdns.cfg

CMD ["./src/build/kdns"]





