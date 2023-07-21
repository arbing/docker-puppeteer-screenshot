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
    && apt-get install -y --force-yes --no-install-recommends \
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

ENV PPTR_VERSION=19.11.1 \
    CHROME_REVISION=1108766 \
    CHROMIUM_VERSION=112.0.5615.138-1~deb11u1

RUN sh -c 'echo "deb http://snapshot.debian.org/archive/debian-security/20230423T032736Z bullseye-security main" >> /etc/apt/sources.list' \
    && apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install -y --force-yes --no-install-recommends chromium-common=$CHROMIUM_VERSION chromium=$CHROMIUM_VERSION && apt-get clean

RUN apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install -y --force-yes --no-install-recommends firefox-esr=102.10.0esr-1~deb11u1 && apt-get clean

WORKDIR /app

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "index.js"]
