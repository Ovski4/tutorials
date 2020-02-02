
docker-compose -f traefik-v1.7-dashboard.yml up
docker-compose -f traefik-v2.1-dashboard.yml up
docker-compose -f traefik-v1.7-dashboard-with-basic-auth.yml up
docker-compose -f traefik-v2.1-dashboard-with-basic-auth.yml up
docker-compose -f traefik-v1.7-nginx-backend.yml up
docker-compose -f traefik-v2.1-nginx-backend.yml up