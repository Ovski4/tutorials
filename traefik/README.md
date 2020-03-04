Traefik v1.7 vs v2.1 configurations
===================================

[Detailed tutorial here.](https://baptiste.bouchereau.pro/tutorial/configuration-differences-between-traefik-v1-and-v2-with-the-docker-provider/)

Some traefik configurations to see differences between v1.7 and v2.1

Usage
-----

```bash
# v1
docker-compose -f traefik-v1.7-dashboard-https.yml up
docker-compose -f traefik-v1.7-dashboard-with-basic-auth.yml up
docker-compose -f traefik-v1.7-dashboard.yml up
docker-compose -f traefik-v1.7-letsencrypt.yml up
docker-compose -f traefik-v1.7-nginx-backend-https.yml up
docker-compose -f traefik-v1.7-nginx-backend.yml up
docker-compose -f traefik-v1.7-swarm-mode.yml up

# v2
docker-compose -f traefik-v2.1-dashboard-https.yml up
docker-compose -f traefik-v2.1-dashboard-with-basic-auth.yml up
docker-compose -f traefik-v2.1-dashboard.yml up
docker-compose -f traefik-v2.1-letsencrypt.yml up
docker-compose -f traefik-v2.1-nginx-backend-https.yml up
docker-compose -f traefik-v2.1-nginx-backend.yml up
docker-compose -f traefik-v2.1-swarm-mode.yml up
```
