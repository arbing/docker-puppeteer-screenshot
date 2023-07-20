ARG NODE_VERSION=16

FROM node:${NODE_VERSION}-bullseye-slim

ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN ARCH=${TARGETPLATFORM#linux/} && echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM, ARCH=$ARCH"

ENV APPLICATION_USER=pptruser \
    APPLICATION_GROUP=pptruser \
    NODE_PATH="/usr/local/share/.config/yarn/global/node_modules:${NODE_PATH}" \
    PATH="/tools:${PATH}" \
    LANG="C.UTF-8" \
    PPTR_VERSION=14.4.1 \
    CHROME_REVISION=1002410 \
    CHROMIUM_VERSION=103.0.5060.134-1~deb11u1

COPY ./tools /tools

RUN ARCH=${TARGETPLATFORM#linux/} && apt-get update \
    && apt-get install -yq \
        gconf-service \
        libasound2 \
        libatk1.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libfontconfig1 \
        libgbm-dev \
        libgcc1 \
        libgconf-2-4 \
        libgdk-pixbuf2.0-0 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        fonts-ipafont-gothic \
        fonts-wqy-zenhei \
        fonts-thai-tlwg \
        fonts-kacst \
        ca-certificates \
        fonts-liberation \
        libappindicator1 \
        libnss3 \
        lsb-release \
        xdg-utils \
        wget \
    && wget https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_$ARCH.deb \
    && dpkg -i dumb-init_*.deb \
    && rm -f dumb-init_*.deb \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN sh -c 'echo "deb http://snapshot.debian.org/archive/debian-security/20220722T181415Z bullseye-security main" >> /etc/apt/sources.list' \
    && apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install -yq chromium-common=$CHROMIUM_VERSION chromium=$CHROMIUM_VERSION --no-install-recommends && apt-get clean

RUN echo "Asia/Shanghai" > /etc/timezone

ADD ./fonts /usr/share/fonts/msfonts

RUN npm install -g pnpm pm2 \
    && npm cache clean -force \
    && mkdir -p /apps \
    && mkdir -p /app

WORKDIR /app

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "index.js"]
