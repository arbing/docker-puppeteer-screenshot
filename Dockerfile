ARG NODE_VERSION=18

FROM node:${NODE_VERSION}-bullseye-slim

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="${PATH}:${PNPM_HOME}"

RUN npm install -g pnpm \
    && npm cache clean -force

ENV APPLICATION_USER=pptruser \
    APPLICATION_GROUP=pptruser \
    NODE_PATH="/usr/local/share/.config/yarn/global/node_modules:${NODE_PATH}" \
    PATH="/tools:${PATH}" \
    LANG="C.UTF-8" \
    PPTR_VERSION=14.4.1 \
    CHROME_REVISION=1002410

COPY ./tools /tools

RUN apt-get update \
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
    && wget https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64.deb \
    && dpkg -i dumb-init_*.deb \
    && rm -f dumb-init_*.deb \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /screenshots \
    && mkdir -p /app \
    && pnpm add -g \
        puppeteer@$PPTR_VERSION \
    && pnpm store prune

ENV CHROME_BIN="/usr/local/share/.config/yarn/global/node_modules/puppeteer/.local-chromium/linux-${CHROME_REVISION}/chrome-linux/chrome"

ADD ./fonts /usr/share/fonts/msfonts

RUN pnpm add -g pm2 \
    && pnpm store prune \
    && mkdir -p /apps

RUN echo "Asia/Shanghai" > /etc/timezone

WORKDIR /app

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "index.js"]
