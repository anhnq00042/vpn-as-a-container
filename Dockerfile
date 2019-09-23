FROM alpine:latest

ARG server=ie33
ARG username=
ARG password=
ARG protocol=udp
ARG localnet="192.168.0.1/24"
ARG proxy_port=3128

RUN apk --update --no-cache add privoxy openvpn runit 

COPY vpn /vpn
RUN find /vpn -name run | xargs chmod u+x


ENV SERVER=${server} \
    USERNAME=${username} \
    PASSWORD=${password} \
    PROTOCOL=${protocol} \
    LOCAL_NETWORK=${localnet} \
    PROXY_PORT=${proxy_port}

CMD ["runsvdir", "/vpn"]
