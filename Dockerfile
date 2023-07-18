# https://github.com/puppeteer/puppeteer/blob/main/docker/Dockerfile
FROM ghcr.io/puppeteer/puppeteer:20.8.2

ENV APPLICATION_USER=pptruser \
    APPLICATION_GROUP=pptruser \
    PPTR_VERSION=20.8.2 \
    PATH="/home/pptruser/tools:${PATH}"

COPY tools tools

RUN mkdir screenshots

#RUN apt-get install -y libgbm-dev

#RUN echo "Asia/Shanghai" > /etc/timezone

RUN yarn global add pm2 \
    && yarn cache clean \
    && mkdir -p /home/pptruser/apps

ADD ./fonts /usr/share/fonts/msfonts
