ARG NODE_VERSION=18

FROM satantime/puppeteer-node:${NODE_VERSION}-bullseye-slim

ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM

RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM, TARGETARCH=$TARGETARCH"

ENV PATH="/tools:${PATH}" \
    LANG="C.UTF-8"

COPY ./tools /tools

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
    && wget https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_$TARGETARCH.deb \
    && dpkg -i dumb-init_*.deb \
    && rm -f dumb-init_*.deb \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN echo "Asia/Shanghai" > /etc/timezone

ADD ./fonts /usr/share/fonts/msfonts

RUN npm install -g pnpm pm2 \
    && npm cache clean -force \
    && mkdir -p /screenshots \
    && mkdir -p /apps \
    && mkdir -p /app

ENV PPTR_VERSION=12.0.1 \
    CHROME_REVISION=938248 \
    CHROMIUM_VERSION=97.0.4692.99-1~deb11u2

RUN sh -c 'echo "deb http://snapshot.debian.org/archive/debian-security/20220124T070450Z bullseye-security main" >> /etc/apt/sources.list' \
    && apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install -y --no-install-recommends chromium-common=$CHROMIUM_VERSION chromium=$CHROMIUM_VERSION && apt-get clean

WORKDIR /app

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "index.js"]
