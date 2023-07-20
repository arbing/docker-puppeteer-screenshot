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
    CHROME_REVISION=1002410

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
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -r $APPLICATION_GROUP \
    && useradd -r -g $APPLICATION_GROUP -G audio,video $APPLICATION_USER \
    && mkdir -p /home/pptruser/Downloads \
    && mkdir -p /usr/local/share/.config/yarn/global/node_modules \
    && mkdir -p /screenshots \
    && mkdir -p /app

# RUN fix_permissions \
#     && yarn global add \
#         puppeteer@$PPTR_VERSION \
#     && yarn cache clean \
#     && fix_permissions

RUN sh -c 'echo "deb http://snapshot.debian.org/archive/debian-security/20220722T181415Z bullseye-security main" >> /etc/apt/sources.list' \
    && apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install -y chromium=103.0.5060.134-1~deb11u1 && apt-get clean

# RUN ARCH=${TARGETPLATFORM#linux/} && apt-get update \
#     && apt-get install -yq libxslt1.1 \
#     && wget https://snapshot.debian.org/archive/debian-security/20220722T181415Z/pool/updates/main/c/chromium/chromium-common_103.0.5060.134-1~deb11u1_$ARCH.deb \
#     && apt install -fy chromium-common_*.deb \
#     && rm -f chromium-common_*.deb \
#     && wget https://snapshot.debian.org/archive/debian-security/20220722T181415Z/pool/updates/main/c/chromium/chromium_103.0.5060.134-1~deb11u1_$ARCH.deb \
#     && apt install -fy chromium_*.deb \
#     && rm -f chromium_*.deb \
#     && apt-get clean

# ENV CHROME_BIN="/usr/local/share/.config/yarn/global/node_modules/puppeteer/.local-chromium/linux-${CHROME_REVISION}/chrome-linux/chrome"

ADD ./fonts /usr/share/fonts/msfonts

RUN yarn global add pm2 \
    && yarn cache clean \
    && mkdir -p /apps \
    && chown -R $APPLICATION_USER:$APPLICATION_GROUP /apps

RUN echo "Asia/Shanghai" > /etc/timezone

WORKDIR /app

USER pptruser

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "index.js"]
