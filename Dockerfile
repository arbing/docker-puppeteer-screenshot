FROM ghcr.io/puppeteer/puppeteer:20.8.2

ENV APPLICATION_USER=pptruser \
    APPLICATION_GROUP=pptruser \
    PPTR_VERSION=20.8.2 \
    PATH="/home/pptruser/tools:${PATH}"

COPY tools tools

RUN mkdir screenshots

RUN apt-get update \
    && apt-get install -yq \
        libgbm-dev \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

ADD ./fonts /usr/share/fonts/msfonts

RUN yarn global add pm2 \
    && yarn cache clean \
    && mkdir -p /apps \
    && chown -R $APPLICATION_USER:$APPLICATION_GROUP /apps

RUN echo "Asia/Shanghai" > /etc/timezone
