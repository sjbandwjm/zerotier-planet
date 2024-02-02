## NOTE: to retain configuration; mount a Docker volume, or use a bind-mount, on /var/lib/zerotier-one

FROM ubuntu:20.04 as builder

ENV TZ=Asia/Shanghai

WORKDIR /app
ADD ./entrypoint.sh /app/entrypoint.sh
ADD ./mkmoonworld-x86_64 /app/mkmoonworld-x86_64

## Supports x86_64, x86, arm, and arm64
# 设置为中国国内源
RUN set -x;apt-get update && apt-get install -y curl gnupg
# RUN set -x;apt-key adv --keyserver pgp.mit.edu --recv-keys 0x1657198823e52a61 && \
#     echo "deb http://download.zerotier.com/debian/buster buster main" > /etc/apt/sources.list.d/zerotier.list

RUN set -x; curl -s https://install.zerotier.com | bash

# #make ztncui
# RUN set -x \
#     && mkdir /app -p \
#     &&  cd /app \
#     && git clone --progress https://ghproxy.markxu.online/https://github.com/key-networks/ztncui.git\
#     && cd /app/ztncui/src \
#     && npm config set registry https://registry.npmmirror.com\
#     && npm install -g node-gyp\
#     && npm install

FROM ubuntu:20.04

WORKDIR /app

ENV IP_ADDR4=''
ENV IP_ADDR6=''
ENV ZT_PORT=9994
ENV GH_MIRROR="https://ghproxy.markxu.online/"
ENV FILE_KEY=''
ENV TZ=Asia/Shanghai

COPY --from=builder /var/lib/zerotier-one /bak/zerotier-one
COPY --from=builder /usr/sbin/zerotier-cli /usr/sbin/zerotier-cli
COPY --from=builder /usr/sbin/zerotier-idtool /usr/sbin/zerotier-idtool
COPY --from=builder /usr/sbin/zerotier-one /usr/sbin/zerotier-one
COPY --from=builder /app/entrypoint.sh /app/entrypoint.sh
COPY --from=builder /app/mkmoonworld-x86_64 /app/mkmoonworld-x86_64

RUN set -x; apt update && \
    apt install -y curl jq openssl && \
    mkdir -p /app/config


VOLUME [ "/app/dist","/var/lib/zerotier-one","/app/config"]

CMD ["/bin/bash","/app/entrypoint.sh"]
