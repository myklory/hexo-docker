FROM mhart/alpine-node:latest
LABEL authors="myklory <myklory@163.com>"
RUN apk add --update git  \
    && npm install -g hexo-cli \
    && mkdir -p /opt/hexo /var/lib/hexo \
    && cd /opt/hexo \
    

WORKDIR /opt/hexo

COPY ./deploy/index.js /var/lib/hexo/index.js
COPY ./deploy/deploy.sh /var/lib/hexo/deploy.sh
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /var/lib/hexo/deploy.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
