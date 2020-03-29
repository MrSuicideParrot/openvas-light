# openvas-light

[![](https://images.microbadger.com/badges/version/cirne/openvas-light.svg)](https://microbadger.com/images/cirne/openvas-light "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/cirne/openvas-light.svg)](https://microbadger.com/images/cirne/openvas-light "Get your own image badge on microbadger.com")

A dockerized version of openvas and totally independent of the greenbone stack.

## Obtaing this Docker image
### Pulling from the Docker Hub
```bash
$ docker pull cirne/openvas-light
```

### Building the Docker image locally
```bash
$ ./build.sh
```

## Quick Start

The quickest way to run this docker is to deploy it as a [docker-compose](docker-compose.yml) service.
The image consists of an openvas vulnerability scanner and an [ospd server](https://github.com/greenbone/ospd-openvas). To perform a scan, you will need to use the [OSP protocol](https://github.com/greenbone/ospd). By default the ospd server is listening on the port 5149.

To manually test openvas-scanner, you can use [gvm-tools](https://github.com/greenbone/gvm-tools) and specify the protocol as OSP. 

```
gvm-cli --protocol OSP tls --hostname localhost --port 5149 --certfile PATH/gvm/CA/clientcert.pem --keyfile PATH/gvm/private/CA/clientkey.pem --cafile PATH/gvm/CA/cacert.pem --xml "<get_version/>" 
```

Communication between the ospd server and the client is secure using TLS. If the required certificates are not found in `/usr/var/lib/gvm`, they will be created automatically. These certificates are generated using the [`gvm-manage-certs`](scripts/gvm-manage-certs) script.

Finally, the vulnerability database is updated regulary using the [`greenbone-nvt-sync`](scripts/greenbone-nvt-sync) script with [go-crond](https://github.com/webdevops/go-crond). If you want to disable the automatic update of this database, you can set the environment variable `NOT_CROND` as `true`.

### List of installed software:
* OpenVas 7.0
* GVM Libs 11.0
* ospd-openvas 1.0.0
* go-crond 0.6.1