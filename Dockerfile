ARG NODE_VERSION=18

FROM satantime/puppeteer-node:${NODE_VERSION}-bullseye-slim

ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM

RUN ARCH=${TARGETPLATFORM#linux/} && echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM, TARGETARCH=$TARGETARCH, ARCH=$ARCH"

ENV PATH="/tools:${PATH}" \
    LANG="C.UTF-8" \
    PPTR_VERSION=14.4.1 \
    CHROME_REVISION=1002410 \
    CHROMIUM_VERSION=103.0.5060.134-1~deb11u1

COPY ./tools /tools

RUN ARCH=${TARGETPLATFORM#linux/} && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
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
    && mkdir -p /screenshots \
    && mkdir -p /apps \
    && mkdir -p /app

WORKDIR /app

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "index.js"]
