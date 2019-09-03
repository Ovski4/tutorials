Run your own ngrok with docker
==============================

[Detailed tutorial here.](https://baptiste.bouchereau.pro/tutorial/running-your-own-ngrok-with-docker/)

Usage
-----

### On your server

Create and copy the content of the files from the server directory somewhere on your server.

Edit the password line 5 of **Dockerfile_sshd**.

Run

```bash
docker-compose up
```

### On your client

Have a local application running. You can run the following to get running quickly:

```bash
docker run --rm -p 8888:80 rothgar/microbot:v1
```

Then run:

```bash
ssh -N -R 0.0.0.0:3333:localhost:8888 root@your.server.net -p 2222
```

Update the ports if needed as well as the server IP / domain name.

Type the password. That's it, browse http://your.server.net:8082