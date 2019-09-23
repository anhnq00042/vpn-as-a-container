# Proxy through VPN connection in a Docker container
An Alpine Linux container with 

- OpenVPN connection to NordVPN service
- Web proxy with Privoxy

You will need a [NordVPN](https://nordvpn.com) account. Additionally, you must download NordVPN ovpn files from [here](https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip) and extract it contents to `vpn/ovpn/config/`:

```Shell
$ curl -sSL -N https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip -o vpn/ovpn/ovpn.zip && unzip -o vpn/ovpn/ovpn.zip -d vpn/ovpn/config/ && rm vpn/ovpn/ovpn.zip

$ tree -d
vpn
└── ovpn
    └── config
        ├── ovpn_tcp # contains tcp ovpn config files
        └── ovpn_udp # contains udp ovpn config files
```

## Starting the VPN Proxy

```Shell
docker build -t jasper/vpncontainer .
docker run -d \
--cap-add=NET_ADMIN \
--device=/dev/net/tun \
--name=vpn_proxy \
--dns=103.86.96.100 --dns=103.86.99.100 \
--restart=always \
-e "SERVER=ie33" \
-e "USERNAME=<nordvpn_username>" \
-e "PASSWORD=<nordvpn_password>" \
-e "LOCAL_NETWORK=192.168.1.0/24" \
-e "PROTOCOL=udp" \
-e "PROXY_PORT=3128" \
-v /etc/localtime:/etc/localtime:ro \
-p 3128:3128 \
jasper/vpncontainer
```

Substitute the environment variables for `SERVER`, `USERNAME`, `PASSWORD`, `LOCAL_NETWORK`, `PROTOCOL` and `PROXY_PORT` as indicated. In my testing, `udp` gives much better performance.

A `docker-compose.yml` file is also provided. Edit `.env` to the values on your setup for `USERNAME` and `PASSWORD`, as well as your `LOCAL_NETWORK` cidr.

Then start the container:

```Shell
docker-compose up -d
```

### Environment Variables

`SERVER` is optional. The default server is set to `ie33`. `SERVER` should match the supported NordVPN `.opvn` server config. 

`USERNAME` / `PASSWORD` - Your NordVPN account details.

`LOCAL_NETWORK` - The CIDR mask of the local IP addresses (e.g. 192.168.0.1/24, 10.1.1.0/24) which will be acessing the proxy. This is so the response to a request can be returned to the client (i.e. your browser).

## Connecting to the VPN Proxy

Set your proxy to 127.0.0.1:${PROXY_PORT}.

## Tested environments
- Raspberry Pi 4 B+ (4GB model)
- WSL 2 + Docker WSL2 technical preview (2.1.2.0)