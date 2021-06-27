FROM python:3-slim-buster

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        git g++ gcc autoconf automake \
        m4 libtool qt4-qmake make libqt4-dev libcurl4-openssl-dev \
        libcrypto++-dev libsqlite3-dev libc-ares-dev \
        libsodium-dev libnautilus-extension-dev \
        libssl-dev libfreeimage-dev swig \
    && apt-get -y autoremove

# Installing Mega sdk Python binding
ENV MEGA_SDK_VERSION '3.9.1'
RUN git clone https://github.com/meganz/sdk.git sdk && cd sdk \
    && git checkout v$MEGA_SDK_VERSION \
    && ./autogen.sh && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl

RUN apt-get -qq update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    apt-add-repository non-free && \
    apt-get -qq update && \
    apt-get -qq install -y unzip p7zip-full mediainfo p7zip-rar aria2 wget curl pv jq ffmpeg locales python3-lxml xz-utils && \
    apt-get purge -y software-properties-common && \
    wget https://cli-assets.heroku.com/heroku-linux-x64.tar.gz -O heroku.tar.gz && \
    tar -xvzf heroku.tar.gz && rm -rf *.tar.gz && \
    mkdir -p /usr/local/lib /usr/local/bin && \
    mv heroku /usr/local/lib/heroku && \
    ln -s /usr/local/lib/heroku/bin/heroku /usr/local/bin/heroku


RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8 \
    LANGUAGE en_US:en \
    LC_ALL en_US.UTF-8
