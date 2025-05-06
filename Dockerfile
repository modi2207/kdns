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
        meson \
        gcc-12 \
        g++-12 \
        linux-headers-$(uname -r) \ 
        python3-pip \
        ca-certificates \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install pyelftools

ENV PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/pkgconfig
ENV CC=gcc-12
ENV CXX=g++-12
    # Clone the kdns repository
RUN git clone https://github.com/modi2207/kdns.git
WORKDIR /app/kdns
RUN make all

RUN mkdir -p /etc/kdns && \
    cp kdns.cfg /etc/kdns/kdns.cfg

CMD ["./src/build/kdns"]





